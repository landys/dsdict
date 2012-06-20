//
//  ImageRecognizer.m
//  tcidsd
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageRecognizer.h"
#import "CharCode.h"

#define CHARS_IMAGE @"chars.png"
#define CHARS2_IPOD_IMAGE @"chars2_ipod.png"

#define CHARS_NUM 26
#define STD_CHAR_TOP_PADDING 18
#define STD_CHAR_LEFT_PADDING 18
#define STD_CHAR_WIDTH 72
#define STD_CHAR_HEIGHT 71
#define COMP_WIDTH 42
#define COMP_HEIGHT 38
#define COMP_AREA (COMP_WIDTH * COMP_HEIGHT)

#define SIMILAR_LIMIT 0.99
#define PURE_COLOR_LIMIT 0.9

// the min limit is not important now. just for save.
#define MIN_SIMILAR_LIMIT 0.5

// iphone/ipod
#define CHAR_TOP_PADDING 18
#define CHAR_LEFT_PADDING 18
#define CHAR_WIDTH 72
#define CHAR_HEIGHT 71

#define GUESS_CHARS_INTERVAL 6
#define GUESS_CHARS_TOP 680

#define CHOSEN_CHARS_INTERVAL 12
#define CHOSEN_CHARS_WIDTH_LIMIT 518
#define CHOSEN_CHARS_LINE1_TOP 782
#define CHOSEN_CHARS_LINE2_TOP 868

#define SNAPSHOT_WIDTH 640
#define SNAPSHOT_HEIGHT 960

// ipad
#define CHAR_TOP_PADDING_IPAD 21
#define CHAR_LEFT_PADDING_IPAD 21
#define CHAR_WIDTH_IPAD 77
#define CHAR_HEIGHT_IPAD 75

#define GUESS_CHARS_INTERVAL_IPAD 6
#define GUESS_CHARS_TOP_IPAD 725

#define CHOSEN_CHARS_INTERVAL_IPAD 13
#define CHOSEN_CHARS_WIDTH_LIMIT_IPAD 666
#define CHOSEN_CHARS_LINE1_TOP_IPAD 834 // 832
#define CHOSEN_CHARS_LINE2_TOP_IPAD 925

#define SNAPSHOT_WIDTH_IPAD 768
#define SNAPSHOT_HEIGHT_IPAD 1024

#define DOUBLE_CHECK_PIXELS_ONE_SIDE 18
//#define DOUBLE_CHECK_PERCENT 0.8
#define DOUBLE_CHECK_CORRECT_PIXELS (DOUBLE_CHECK_PIXELS_ONE_SIDE * 2 + 1 - 2)//(DOUBLE_CHECK_PERCENT * (DOUBLE_CHECK_PIXELS_ONE_SIDE * 2 + 1))

//#define GUESSING_BAR_BEG_X_ODD 50
//#define GUESSING_BAR_BEG_X_EVEN 11
#define GUESSING_BAR_WORD_X_SPACE 78
//#define GUESSING_BAR_BEG_X_ODD_IPAD 54
//#define GUESSING_BAR_BEG_X_EVEN_IPAD 96
#define GUESSING_BAR_WORD_X_SPACE_IPAD 83

#define LETTERS_IN_LINE 6

static const int gXCoords[LETTERS_IN_LINE] = {27, 111, 195, 278, 362, 446};

static const int gXCoordsIpad[LETTERS_IN_LINE] = {70, 160, 250, 341, 431, 521};

static const int gXCoordsIpad2[LETTERS_IN_LINE] = {69, 159, 249, 339, 429, 519};

#define MAX_WORD_LENGTH 8
static const int gGuessingBegXCoords[MAX_WORD_LENGTH] = {284, 245, 206, 167, 128, 89, 50, 11};
static const int gGuessingBegXCoordsIpad[MAX_WORD_LENGTH] = {345, 303, 262, 220, 179, 137, 96, 54};

typedef enum {IRIPhone, IRIPad} ImageResolution;

@interface ImageRecognizer (Private)

// return 1 if error.
- (char)recognizeChar:(ImageCore*)ipImage leftTop:(CGPoint)iLeftTop ir:(ImageResolution)iIR;
//- (int)recognizeCharLine:(ImageCore*)ipImage oCharts:(NSMutableString *)opChars begY:(int)iBegY isGuessBar:(BOOL)iIsGuessBar ir:(ImageResolution)iIR;
- (int)calcWordLength:(ImageCore*)ipImage begY:(int)iBegY ir:(ImageResolution)iIR;
- (int)recognizeCharLineByCoords:(ImageCore*)ipImage oCharts:(NSMutableString *)opChars xCoords:(const int*)xCoords nCoords:(int)nCoords begY:(int)iBegY ir:(ImageResolution)iIR;
@end

@implementation ImageRecognizer

#define MIN_SEG_PIXELS 2
#define REPEAT_LIMIT 5
#define CHAR_INNER_PADDING 0
#define LONG_SEG_PERCENT 0.8
#define MAX_VERTICAL_CODES 3
#define LONG_SEG_VALUE 8

- (int)scanLine:(BOOL[STD_CHAR_HEIGHT][STD_CHAR_WIDTH])iCharBmp size:(CGSize)iSize pos:(int)iOff vertical:(BOOL)iVertical {
    BOOL lIsLong = NO;
    int lNSegs = 0;
    BOOL lWhiteBeg = NO;
    int lNWhite = 0;
    int lNPixels = (iVertical ? iSize.height : iSize.width);
    int lNLongSegPixels = lNPixels * LONG_SEG_PERCENT;

    for (int i=0; i<lNPixels; ++i) {
        BOOL lIsWhite = (iVertical ? iCharBmp[i][iOff] : iCharBmp[iOff][i]);
        
        if (lWhiteBeg) {
            if (lIsWhite) {
                ++lNWhite;
            }
            else {
                if (lNWhite >= lNLongSegPixels) {
                    lIsLong = YES;
                    break;
                }
                else if (lNWhite >= MIN_SEG_PIXELS) {
                    ++lNSegs;
                }
                lWhiteBeg = NO;
                lNWhite = 0;
            }
        }
        else {
            if (lIsWhite) {
                ++lNWhite;
                lWhiteBeg = YES;
            }
        }
    }
    
    if (lWhiteBeg && !lIsLong) {
        if (lNWhite >= lNLongSegPixels) {
            lIsLong = YES;
        }
        else if (lNWhite >= MIN_SEG_PIXELS) {
            ++lNSegs;
        }
    }
    
    return lIsLong ? LONG_SEG_VALUE : (lNSegs > 0 ? lNSegs : -1);
}

//- (int)encodeCharByPos:(BOOL[STD_CHAR_HEIGHT][STD_CHAR_WIDTH])iCharBmp size:(CGSize)iSize vertical:(BOOL)iVertical pos:(int[])iPos npos:(int)iNPos {
//    int lCode = 0;
//    for (int i=0; i<iNPos; ++i) {
//        int lNSegs = [self scanLine:iCharBmp size:iSize pos:iPos[i] vertical:iVertical];
//        
//        lCode = lCode * 10 + lNSegs;
//    }
//    
//    return lCode;
//}
//
//- (int)encodeCharHorizontal:(BOOL[STD_CHAR_HEIGHT][STD_CHAR_WIDTH])iCharBmp size:(CGSize)iSize {
//    int lNPos = 2;
//    int lPos[] = {iSize.height / 2, iSize.height * 2 / 3};
//    
//    return [self encodeCharByPos:iCharBmp size:iSize vertical:NO pos:lPos npos:lNPos];
//}

- (int)encodeChar:(BOOL[STD_CHAR_HEIGHT][STD_CHAR_WIDTH])iCharBmp size:(CGSize)iSize vertical:(BOOL)iVertical {
    int lCode = 0;
    int lNCurSegs = -1;
    int lLastEncode = -1;
    int lNRepeat = 0;
    int lSide = (iVertical ? iSize.width : iSize.height);
    for (int i=0; i<lSide; ++i) {
        int lNSegs = [self scanLine:iCharBmp size:iSize pos:i vertical:iVertical];
        if (lNSegs >= 0) {
            if (lNCurSegs == lNSegs) {
                ++lNRepeat;
                if (lNRepeat == REPEAT_LIMIT && lLastEncode != lNSegs) {
                    lCode = lCode * 10 + lNSegs;
                    if (lCode >= 100) {
                        break;
                    }
                    lLastEncode = lNSegs;
                }
            }
            else {
                lNCurSegs = lNSegs;
                lNRepeat = 1;
            }
        }
        else {
            lNCurSegs = -1;
            lNRepeat = 0;
        }
    }
    
    int iPos = -1;
    if (V_HMNU == lCode || V_VWY == lCode || V_CQ == lCode || V_DP == lCode) {
        iPos = iSize.height / 2; 
    }
    else if (V_AO == lCode || V_FR == lCode || V_SZ == lCode || V_QG == lCode) {
        iPos = iSize.height - 2;
    }
    
    if (iPos >= 0) {
        int lNSegs = [self scanLine:iCharBmp size:iSize pos:iPos vertical:NO];
        lCode += 1000 * lNSegs;
    }
    
    if (V2_MN == lCode) {
        int lNSegs = 3;
        for (int i=iSize.height / 2 - 7; i<iSize.height / 2; ++i) {
            lNSegs = [self scanLine:iCharBmp size:iSize pos:i vertical:NO];
            if (lNSegs == LONG_SEG_VALUE) {
                break;
            }
        }

        lCode += 10000 * lNSegs;
    }
    
    return lCode;
}

- (CGSize)convertToCharBmp:(ImageCore*)ipImage leftTop:(CGPoint)iLeftTop padding:(int)iPadding charBmp:(BOOL[STD_CHAR_HEIGHT][STD_CHAR_WIDTH])oCharBmp {
    if (!ipImage) return CGSizeZero;
    
    int lTop = -1;
    int lBottom = -1;
    int lLeft = -1;
    int lRight = -1;
    for (int y=16; y<CHAR_HEIGHT && lTop == -1; ++y) {
        int lY = y + iLeftTop.y;
        for (int x=6; x<CHAR_WIDTH-6; ++x) {
            if ([ColorUtil isCharWhite:[ipImage getPixelColor:x+iLeftTop.x y:lY]]) {
                lTop = lY;
                break;
            }
        }
    }
    
    for (int y=CHAR_HEIGHT-10; y>=0 && lBottom == -1; --y) {
        int lY = y + iLeftTop.y;
        for (int x=6; x<CHAR_WIDTH-6; ++x) {
            if ([ColorUtil isCharWhite:[ipImage getPixelColor:x+iLeftTop.x y:lY]]) {
                lBottom = lY + 1;
                break;
            }
        }
    }
    
    for (int x=6; x<CHAR_WIDTH && lLeft == -1; ++x) {
        int lX = x + iLeftTop.x;
        for (int y=16; y<CHAR_HEIGHT-10; ++y) {
            if ([ColorUtil isCharWhite:[ipImage getPixelColor:lX y:y+iLeftTop.y]]) {
                lLeft = lX;
                break;
            }
        }
    }
    
    for (int x=CHAR_WIDTH-6; x>=0 && lRight == -1; --x) {
        int lX = x + iLeftTop.x;
        for (int y=16; y<CHAR_HEIGHT-10; ++y) {
            if ([ColorUtil isCharWhite:[ipImage getPixelColor:lX y:y+iLeftTop.y]]) {
                lRight = lX + 1;
                break;
            }
        }
    }
    
    lLeft += iPadding;
    lRight -= iPadding;
    lTop += iPadding;
    lBottom -= iPadding;
    
    int lWidth = lRight - lLeft;
    int lHeight = lBottom - lTop;
    
    for (int i=0; i<lHeight; ++i) {
        int lY = i + lTop;
        for (int j=0; j<lWidth; ++j) {
            oCharBmp[i][j] = [ColorUtil isCharWhite:[ipImage getPixelColor:j+lLeft y:lY]];
        }
    }
    
    return CGSizeMake(lWidth, lHeight);
}

- (void)encodeCharImages {
    NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:CHARS_IMAGE ofType:@""];
    UIImage* lpCharsImage = [[UIImage alloc] initWithContentsOfFile:lpFinalPath];
    ImageCore* lpImage = [[ImageCore alloc] initWithUIImage:lpCharsImage];
    [lpCharsImage release];
    
    lpFinalPath = [[NSBundle mainBundle] pathForResource:CHARS2_IPOD_IMAGE ofType:@""];
    lpCharsImage = [[UIImage alloc] initWithContentsOfFile:lpFinalPath];
    ImageCore* lpImage2 = [[ImageCore alloc] initWithUIImage:lpCharsImage];
    [lpCharsImage release];
    
    BOOL lCharBmp[STD_CHAR_HEIGHT][STD_CHAR_WIDTH];
    for (int i=0; i<CHARS_NUM; ++i) {
        CGSize lSize = [self convertToCharBmp:lpImage leftTop:CGPointMake(STD_CHAR_WIDTH * i, 0) padding:CHAR_INNER_PADDING charBmp:lCharBmp];
        
//        NSMutableString* lpCharStr = [NSMutableString stringWithCapacity:0];
//        for (int j=0; j<lSize.height; ++j) {
//            for (int t=0; t<lSize.width; ++t) {
//                [lpCharStr appendFormat:@"%d ", (lCharBmp[j][t] ? 1 : 0)];
//            }
//            [lpCharStr appendString:@"\n"];
//        }
//        NSLog(@"%c: \n%@", (char)(i+'A'), lpCharStr);
        
        int lCode = [self encodeChar:lCharBmp size:lSize vertical:YES];
        //int lCode = [self encodeCharHorizontal:lCharBmp size:lSize];
        lSize = [self convertToCharBmp:lpImage2 leftTop:CGPointMake(STD_CHAR_WIDTH * i, 0) padding:CHAR_INNER_PADDING charBmp:lCharBmp];
        
        int lCode2 = [self encodeChar:lCharBmp size:lSize vertical:YES];
        //int lCode2 = [self encodeCharHorizontal:lCharBmp size:lSize];
        
        printf("#define %c %d\n", (char)(i+'A'), lCode);
        if (lCode != lCode2) {
            printf("#define %c %d\n", (char)(i+'A'), lCode2);
        }
        
//        if ([lpEncode compare:lpEncode2] != NSOrderedSame) {
//            NSLog(@"%c %d ** %d", (char)(i+'A'), lpEncode, lpEncode2);
//        }
//        else {
//            NSLog(@"%c %d -- %d", (char)(i+'A'), lpEncode, lpEncode2);
//        }
    }
}

- (id)init {
    self = [super init];
    if (self) {
        NSString* lpFinalPath = [[NSBundle mainBundle] pathForResource:CHARS_IMAGE ofType:@""];
        UIImage* lpCharsImage = [[UIImage alloc] initWithContentsOfFile:lpFinalPath];
        mpChars = [[ImageCore alloc] initWithUIImage:lpCharsImage];
        
        //***
        [self encodeCharImages];
        
        [lpCharsImage release];
    }
    return self;
}

- (char)recognizeChar:(ImageCore*)ipImage leftTop:(CGPoint)iLeftTop ir:(ImageResolution)iIR {
    if (!ipImage) return 0;
    
    int lCharTopPadding = CHAR_TOP_PADDING;
    int lCharLeftPadding = CHAR_LEFT_PADDING;
    if (iIR == IRIPad) {
        lCharTopPadding = CHAR_TOP_PADDING_IPAD;
        lCharLeftPadding = CHAR_LEFT_PADDING_IPAD;
    }
    
    int lY = iLeftTop.y + lCharTopPadding;
    int lX = iLeftTop.x + lCharLeftPadding;
    
    // check the white pixel number first.
    int lNWhite = 0;
    for (int x=0; x<COMP_WIDTH; ++x) {
        for (int y=0; y<COMP_HEIGHT; ++y) {
            BOOL lIsWhite = [ColorUtil isCharWhite:[ipImage getPixelColor:(lX + x) y:(lY + y)]];
            if (lIsWhite) {
                ++lNWhite;
            }
        }
    }
    
    if (lNWhite >= PURE_COLOR_LIMIT * COMP_AREA || lNWhite <= (1.0 - PURE_COLOR_LIMIT) * COMP_AREA) {
        return 0;
    }
    
    // recognize the character.
    int lYStd = STD_CHAR_TOP_PADDING;
    int lSimilarNumLimit = SIMILAR_LIMIT * COMP_AREA;
    
    int lMaxNMatched = 0;
    char lMaxMatchedChar = 0;
    for (int i=0; i<CHARS_NUM; ++i) {
        int lXStd = i * STD_CHAR_WIDTH + STD_CHAR_LEFT_PADDING;
        
        int lNMatched = 0;
        for (int x=0; x<COMP_WIDTH; ++x) {
            for (int y=0; y<COMP_HEIGHT; ++y) {
                BOOL lIsWhite = [ColorUtil isCharWhite:[ipImage getPixelColor:(lX + x) y:(lY + y)]];
                BOOL lIsWhiteStd = [ColorUtil isCharWhite:[mpChars getPixelColor:(lXStd + x) y:(lYStd + y)]];
                if ((lIsWhite && lIsWhiteStd) || (!lIsWhite && !lIsWhiteStd)) {
                    ++lNMatched;
                }
            }
        }
        
        if (lNMatched > lMaxNMatched) {
            lMaxNMatched = lNMatched;
            lMaxMatchedChar = 'a' + i;
        }
        
        if (lMaxNMatched >= lSimilarNumLimit) {
            break;
        }
    }
    
    return (lMaxNMatched < MIN_SIMILAR_LIMIT * COMP_AREA ? 0 : lMaxMatchedChar);
}

- (int)calcWordLength:(ImageCore*)ipImage begY:(int)iBegY ir:(ImageResolution)iIR {
    if (!ipImage) return 0;

    int lSnapshotWidth = SNAPSHOT_WIDTH;
    int lCharHeight = CHAR_HEIGHT;
    int lCharWidth = CHAR_WIDTH;
    if (iIR == IRIPad) {
        lSnapshotWidth = SNAPSHOT_WIDTH_IPAD;
        lCharHeight = CHAR_HEIGHT_IPAD;
        lCharWidth = CHAR_WIDTH_IPAD;
    }
    
    int lWidthLimit = lSnapshotWidth;
    
    int lYMid = iBegY + lCharHeight / 2;
    int lCheckYBeg = lYMid - DOUBLE_CHECK_CORRECT_PIXELS;
    int lCheckYEnd = lYMid + DOUBLE_CHECK_CORRECT_PIXELS;
    int lWordLength = 0;
    for (int x=0; x<lWidthLimit; ++x) {
        int y = lYMid;
        Pixel lPixel = [ipImage getPixelColor:x y:y];
        BOOL lIsWhite = [ColorUtil isCharWhite:lPixel];
        if (lIsWhite) {
            // find a new letter or an empty square.
            ++lWordLength;
            
            int lWhiteBlockPixelCount = 1;
            while (++x < lWidthLimit) {
                // we check the pixel next to currect one first.
                lPixel = [ipImage getPixelColor:x y:y];
                lIsWhite = [ColorUtil isCharWhite:lPixel];
                if (!lIsWhite) {
                    // check the whole vertical line to see if there's white color
                    for (y=lCheckYBeg; y<=lCheckYEnd; ++y) {
                        lPixel = [ipImage getPixelColor:x y:y];
                        lIsWhite = [ColorUtil isCharWhite:lPixel];
                        if (lIsWhite) {
                            break;
                        }
                    }
                }
                
                if (!lIsWhite) {
                    // end of a letter or an empty square.
                    break;
                }
                
                ++lWhiteBlockPixelCount;
            }
            
            // check to see if it's actually not a screenshot
            if (lWhiteBlockPixelCount > lCharWidth) {
                lWordLength = 0;
                break;
            }
        }
    }
    
    return lWordLength;
}

//- (int)recognizeCharLine:(ImageCore*)ipImage oCharts:(NSMutableString *)opChars begY:(int)iBegY isGuessBar:(BOOL)iIsGuessBar ir:(ImageResolution)iIR {
//    if (!ipImage || !opChars) return 0;
//    
//    int lGuessCharsInterval = GUESS_CHARS_INTERVAL;
//    int lChosenCharsInterval = CHOSEN_CHARS_INTERVAL;
//    int lSnapshotWidth = SNAPSHOT_WIDTH;
//    int lChosenCharsWidthLimit = CHOSEN_CHARS_WIDTH_LIMIT;
//    int lCharHeight = CHAR_HEIGHT;
//    int lCharWidth = CHAR_WIDTH;
//    if (iIR == IRIPad) {
//        lGuessCharsInterval = GUESS_CHARS_INTERVAL_IPAD;
//        lChosenCharsInterval = CHOSEN_CHARS_INTERVAL_IPAD;
//        lSnapshotWidth = SNAPSHOT_WIDTH_IPAD;
//        lChosenCharsWidthLimit = CHOSEN_CHARS_WIDTH_LIMIT_IPAD;
//        lCharHeight = CHAR_HEIGHT_IPAD;
//        lCharWidth = CHAR_WIDTH_IPAD;
//    }
//    
//    int lInterval = (iIsGuessBar ? lGuessCharsInterval : lChosenCharsInterval);
//    int lWidthLimit = (iIsGuessBar ? lSnapshotWidth : lChosenCharsWidthLimit);
//    
//    int lY = iBegY + lCharHeight / 2;
//    int lNChars = 0;
//    for (int x=0; x<lWidthLimit; ++x) {
//        Pixel lPixel = [ipImage getPixelColor:x y:lY];
//        BOOL lIsBg = (iIsGuessBar ? [ColorUtil isBgBlueGreenRed:lPixel] : [ColorUtil isBgGray:lPixel]);
//        
//        if (!lIsBg) {
//            // double check the character border.
//            int lNotBgCount = 0;
//            for (int y=lY-DOUBLE_CHECK_PIXELS_ONE_SIDE; y<=lY+DOUBLE_CHECK_PIXELS_ONE_SIDE; ++y) {
//                lPixel = [ipImage getPixelColor:x y:y];
//                if (!(iIsGuessBar ? [ColorUtil isBgBlueGreenRed:lPixel] : [ColorUtil isBgGray:lPixel])) {
//                    ++lNotBgCount;
//                }
//            }
//            
//            if (lNotBgCount >= DOUBLE_CHECK_CORRECT_PIXELS) {
//                char lC = [self recognizeChar:ipImage leftTop:CGPointMake(x, iBegY) ir:iIR];
//                ++lNChars;
//                if (lC != 0) {
//                    [opChars appendFormat:@"%c", lC];
//                }
//                
//                // - 2 to allow 2 pixel difference.
//                x += lCharWidth + lInterval - 2;
//            }
//        }
//    }
//    
//    return lNChars;
//}

- (int)recognizeCharLineByCoords:(ImageCore*)ipImage oCharts:(NSMutableString *)opChars xCoords:(const int*)xCoords nCoords:(int)nCoords begY:(int)iBegY ir:(ImageResolution)iIR {
    int lNChars = 0;
    for (int i=0; i<nCoords; ++i) {
        char lC = [self recognizeChar:ipImage leftTop:CGPointMake(xCoords[i], iBegY) ir:iIR];
        if (lC != 0) {
            [opChars appendFormat:@"%c", lC];
            ++lNChars;
        }
    }
    return lNChars;
}

- (int)recognizeImage:(UIImage*)ipImage oCharts:(NSMutableString*)opChars {
    // ***
    [self encodeCharImages];
    
    if (!ipImage || !opChars || !mpChars) return 0;
    
    UIImage* lpImage = ipImage;
    CGSize lImgSize = lpImage.size;
    
    // Get the most suitable image size for recognition.
    ImageResolution lIR;
    if (lImgSize.width == SNAPSHOT_WIDTH && lImgSize.height == SNAPSHOT_HEIGHT) {
        lIR = IRIPhone;
    }
    else if (lImgSize.width == SNAPSHOT_WIDTH_IPAD && lImgSize.height == SNAPSHOT_HEIGHT_IPAD) {
        lIR = IRIPad;
    }
    else {
        CGRect lNewRect = CGRectMake(0, 0, SNAPSHOT_WIDTH, SNAPSHOT_HEIGHT);
        lIR = IRIPhone;
        
        float lHWRatio = lImgSize.height * 1.0f / lImgSize.width;
        if (fabsf(lHWRatio - SNAPSHOT_HEIGHT * 1.0f / SNAPSHOT_WIDTH) > fabsf(lHWRatio - SNAPSHOT_HEIGHT_IPAD * 1.0f / SNAPSHOT_WIDTH_IPAD)) {
            lNewRect = CGRectMake(0, 0, SNAPSHOT_WIDTH_IPAD, SNAPSHOT_HEIGHT_IPAD);
            lIR = IRIPad;
        }
        
        lpImage = [ImageCore resizeImage:lpImage newRect:lNewRect];
        if (!lpImage) return 0;
    }
    
    ImageCore* lpSnapshot = [[ImageCore alloc] initWithUIImage:lpImage];
    if (!lpSnapshot) return 0;
    
    int lGuessCharsTop = GUESS_CHARS_TOP;
    int lChosenCharsLine1Top = CHOSEN_CHARS_LINE1_TOP;
    int lChosenCharsLine2Top = CHOSEN_CHARS_LINE2_TOP;
    if (lIR == IRIPad) {
        lGuessCharsTop = GUESS_CHARS_TOP_IPAD;
        lChosenCharsLine1Top = CHOSEN_CHARS_LINE1_TOP_IPAD;
        lChosenCharsLine2Top = CHOSEN_CHARS_LINE2_TOP_IPAD;
    }
    
    // recognize the characters in chosen character bar.
    //[self recognizeCharLine:lpSnapshot oCharts:opChars begY:lChosenCharsLine1Top isGuessBar:NO ir:lIR];
    //[self recognizeCharLine:lpSnapshot oCharts:opChars begY:lChosenCharsLine2Top isGuessBar:NO ir:lIR];
    NSMutableString* lpLetters = [[NSMutableString alloc] initWithCapacity:0];
    const int* lpXCoords = (lIR == IRIPad ? gXCoordsIpad : gXCoords);
    int lNCandidateChars = 0;
    lNCandidateChars += [self recognizeCharLineByCoords:lpSnapshot oCharts:lpLetters xCoords:lpXCoords nCoords:LETTERS_IN_LINE begY:lChosenCharsLine1Top ir:lIR];
    lNCandidateChars += [self recognizeCharLineByCoords:lpSnapshot oCharts:lpLetters xCoords:lpXCoords nCoords:LETTERS_IN_LINE begY:lChosenCharsLine2Top ir:lIR];
    
    
    // recognize the characters in guessing bar.
    //int lNGuessChars = [self recognizeCharLine:lpSnapshot oCharts:opChars begY:lGuessCharsTop isGuessBar:YES ir:lIR];
    
    // recognize the word length
    int lNGuessChars = [self calcWordLength:lpSnapshot begY:lGuessCharsTop ir:lIR];
    // save check.
    if (lNGuessChars > MAX_WORD_LENGTH) lNGuessChars = MAX_WORD_LENGTH;
    
    int lNLettersInGuessing = LETTERS_IN_LINE * 2 - lNCandidateChars;
    // save check
    //if (lNLettersInGuessing > lNGuessChars) lNLettersInGuessing = lNGuessChars;
    
    if (lNLettersInGuessing > 0 && lNGuessChars > 0) {
        // some letters are in guessing bar.
        int lGuessingXBeg = (lIR == IRIPad ? gGuessingBegXCoordsIpad[lNGuessChars - 1] : gGuessingBegXCoords[lNGuessChars - 1]);
        int lGuessingLetterWidth = (lIR == IRIPad ? GUESSING_BAR_WORD_X_SPACE_IPAD : GUESSING_BAR_WORD_X_SPACE);
        int lGuessingXCoords[MAX_WORD_LENGTH];
        lGuessingXCoords[0] = lGuessingXBeg;
        for (int i=1; i<lNGuessChars; ++i) {
            lGuessingXCoords[i] = lGuessingXCoords[i - 1] + lGuessingLetterWidth;
        }
        
        [self recognizeCharLineByCoords:lpSnapshot oCharts:opChars xCoords:lGuessingXCoords nCoords:lNGuessChars begY:lGuessCharsTop ir:lIR];        
    }
    
    // merge the letters from guessing bar and letters bar.
    [opChars appendString:lpLetters];
    
    [lpSnapshot release];
    [lpLetters release];
    
    return lNGuessChars;
}

- (void)dealloc {
    [mpChars release];
    [super dealloc];
}

@end
