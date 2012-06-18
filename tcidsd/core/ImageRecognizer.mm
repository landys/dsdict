//
//  ImageRecognizer.m
//  tcidsd
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageRecognizer.h"

#define CHARS_IMAGE @"chars2_ipod.png" //@"chars.png"
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

#define MIN_SEG_PIXELS 5

- (int)scanLine:(CGRect)iRect pos:(CGFloat)iPos vertical:(BOOL)iVertical {
    if ((iVertical && (iPos < iRect.origin.y || iPos >= iRect.origin.y + iRect.size.height)) || (!iVertical && (iPos < iRect.origin.x || iPos >= iRect.origin.x + iRect.size.width))) return -1;
    
    int lSegs = -1;
    BOOL lWhiteBeg = false;
    int lNWhite = 0;
    if (iVertical) {
        for (int i=0; i<iRect.size.height; i+=2) {
            CGFloat ly = i + iRect.origin.y;
            Pixel lPixel = [mpChars getPixelColor:iPos y:ly];
            BOOL lIsWhite = [ColorUtil isCharWhite:lPixel];
            if (lWhiteBeg) {
                if (lIsWhite) {
                    ++lNWhite;
                }
            }
        }
    }
    else {
        for (int i=0; i<iRect.size.width; ++i) {
            
        }
    }
}

- (void)encodeCharImages {
    
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
