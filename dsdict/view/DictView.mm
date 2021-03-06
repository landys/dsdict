//
//  DictView.m
//  dsdict
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictView.h"
#import "Word.h"
#import "DictUtil.h"
#import "Global.h"

#define DEFAULT_WORD_LENGTH 5
#define MIN_WORD_LENGTH 2
#define MAX_WORD_LENGTH 9

#define BG_TOP_COLOR 0x40c5f2 //0x3b6dcd
#define BG_BOTTOM_COLOR 0xe1f9ff //0x9be1f9 //0xffffff

#define LENGTH_ONLY_NUMBER_ALLOWED @"Only numbers are allowed in \"Word Length\" field, and the value should be bigger than 0."
#define NO_WORDS_FOR_LENGTH @"Word length must NOT be bigger than 9."
#define CANNOT_FIND_WORDS @"No results for current search. Please enter more letters.\n\nIf you have finished your input, sorry that the word is not in our library. :("
#define LETTERS_ONLY_LETTER_ALLOWED @"Only letters are allowed in \"Enter Letters\" field."
#define SCREENSHOT_CANNOT_RECOGNIZE @"The screenshot cannot be recognized. You may try to input letters manually.\n\nPlease check if it's really a screenshot of your \"Draw Something\" game. It should have the candidate letters at the bottom.\n\nAnd it doesn't support \"Draw Something 2\" yet. :("

#define LOADING_DICTIONARY @"Loading Dictionaries..."

@interface DictView (Private)

- (void)createSubViews;
- (void)searchWords;
- (void)searchWordsWithImage:(UIImage*)ipImage;
- (void)chooseSnapshotImage;
//- (void)changeSettings;
- (void)resetViews;
- (void)releaseFocusInTextFields;

- (UILabel*)addLabel:(NSString*)ipText frame:(CGRect)iFrame;
- (UITextField*)addTextField:(CGRect)iFrame;
- (void)removeTooltipView;

- (void)initHintsText;
- (void)displayHints:(NSString*)iHints textColor:(UIColor*)ipColor;

- (void)setWordLength:(int)iLength;
//- (void)sliderChanged:(UISlider*)ipSlider;
- (void)sliderTouchesBegan:(UISlider*)ipSlider;
- (void)sliderTouchesMoved:(UISlider*)ipSlider;
- (void)sliderTouchesEnd:(UISlider*)ipSlider;

- (void)prepareForSearch;
- (void)loadDictAndRefresh:(NSString*)mpLanguage;

@end

@implementation DictView

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)ipVC {
    self = [super initWithFrame:frame];
    if (self) {
        mpMainVC = ipVC;
        
        // init the hints text displayed at the beginning.
        [self initHintsText];
        
        // create subviews
        [self createSubViews];
        
        // show hints at the beginning.
        [self displayHints:mpHintsText textColor:[Global getHintInfoColor]];
    }
    return self;
}

- (void)initForSearch {
    [Global showWaitView:mpMainVC.view text:LOADING_DICTIONARY bgMask:NO iconBgMask:YES];
    
    [self performSelector:@selector(prepareForSearch) withObject:nil afterDelay:0];
}

- (void)prepareForSearch {
    mpDictCore = [[DictCore alloc] init];
//        // currently, we always load the whole dictionary.
//        [mpDictCore reInitDicts:NO];
    [mpDictCore reInitDicts:[Global isLanguageNone]];
    
    // image recognizer
    mpImageRecognizer = [[ImageRecognizer alloc] init];
    
    // image chooser
    mpImageChooser = [[ImageChooser alloc] initWithMainViewController:mpMainVC popRect:mpBtnChooseImage.frame];
    mpImageChooser.mpDelegate = self;
    
    [Global hideWaitView];
}

- (UILabel*)addLabel:(NSString*)ipText frame:(CGRect)iFrame{
    UILabel* lpLabel = [[UILabel alloc] initWithFrame:iFrame];
    lpLabel.text = ipText;
    lpLabel.font = [Global getCommonBoldFont:([DictUtil isIPad] ? 44 : 22)];
    lpLabel.backgroundColor = [UIColor clearColor];
    lpLabel.textColor = [UIColor whiteColor];//[ColorUtil colorFromInteger:0xfbfbfb];
    [self addSubview:lpLabel];
    
    return lpLabel;
}

- (UITextField*)addTextField:(CGRect)iFrame {
    UITextField* lpTextField = [[UITextField alloc] initWithFrame:iFrame];
    lpTextField.font = [Global getCommonFont:([DictUtil isIPad] ? 34 : 17)];//lpTextField.font.pointSize)];
    lpTextField.textColor = [Global getDarkTextColor];
    lpTextField.backgroundColor = [Global getTextBgColor];;
    lpTextField.borderStyle = UITextBorderStyleRoundedRect;
    //lpTextField.textAlignment = UITextAlignmentCenter;
    [lpTextField addTarget:self action:@selector(searchWords) forControlEvents:UIControlEventEditingChanged];
    lpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    lpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    lpTextField.returnKeyType = UIReturnKeyDone;
    lpTextField.delegate = self;
    lpTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [self addSubview:lpTextField];
    
    return lpTextField;
}

- (void)createSubViews {
    // ipod/iphone=320*460. iphone5=320*548, ipad=768*1004, because the title out of our application takes 20 points.
    // Notes: here, it's the points but not pixels.
    // For pixels, iphone 5=1136*640, retina iphone/ipod is 640*960, ...
    // For the position and side values below, we define frame size from photoshop,
    // for iphone/ipod, assume size is 320*460;
    // for iphone 5, assume size is 320*548.
    // for ipad, assume size is 360*460.
    CGRect lChooseImageFrame = CGRectMake(2, 2, 120, 174);
    CGRect lTitleFrame = CGRectMake(129, 5, 144, 36);
    CGRect lSettingFrame = CGRectMake(276, 5, 37, 36);
    CGRect lSldLengthFrame = CGRectMake(127, 46, 166, 36);
    CGRect lLblLengthFrame = CGRectMake(296, 45, 23, 36);
    CGRect lTxtLettersFrame = CGRectMake(127, 83, 191, 36);
    CGRect lResetFrame = CGRectMake(184, 132, 74, 36);
    CGRect lResultAreaFrame = CGRectMake(2, 178, 316, 281);
    
    CGSize lViewSize = self.bounds.size;
    float lWidthRatio = lViewSize.width / 320.0;
    float lHeightRatio = lViewSize.height / 460.0;
    
    if ([DictUtil isIPad]) {
        lTitleFrame.size.width += 40;
        lSettingFrame.origin.x += 40;
        //lLblLengthFrame.origin.y += 4;
        //lTxtLengthFrame.origin.x -= 10;
        //lTxtLengthFrame.size.width += 90;
        lSldLengthFrame.size.width += 40;
        lLblLengthFrame.origin.x += 40;
        lTxtLettersFrame.size.width += 40;
        lResetFrame.origin.x += 40 / 2;
        lResultAreaFrame.size.width += 40;
        
        lWidthRatio = lViewSize.width / 360.0;
    }
    else if (isIPhone5) {
        lResultAreaFrame.size.height += 88;
        lHeightRatio = lViewSize.height / 548.0;
    }
    
//    // resizing according to self.frame;
//    CGRect lFrame = self.frame;
//    float lSizeRatio = lFrame.size.height / lFrame.size.width;
//    float lWidthRatio = 0;
//    float lHeightRatio = lFrame.size.height / 960.0;
//    if (fabsf(lSizeRatio - 960.0 / 640.0) < fabsf(lSizeRatio - 960.0 / 720.0)) {
//        // ipod/iphone
//        lWidthRatio = lFrame.size.width / 640.0;
//    }
//    else {
//        // ipad
//        lWidthRatio = lFrame.size.width / 720.0;
//    }
    
    // resize frames.
    if (lWidthRatio != 1 || lHeightRatio != 1) {
        lChooseImageFrame = [DictUtil resizeFrame:lChooseImageFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lTitleFrame = [DictUtil resizeFrame:lTitleFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lSettingFrame = [DictUtil resizeFrame:lSettingFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lLblLengthFrame = [DictUtil resizeFrame:lLblLengthFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        //lTxtLengthFrame = [DictUtil resizeFrame:lTxtLengthFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lSldLengthFrame = [DictUtil resizeFrame:lSldLengthFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];        
        lTxtLettersFrame = [DictUtil resizeFrame:lTxtLettersFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lResetFrame = [DictUtil resizeFrame:lResetFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lResultAreaFrame = [DictUtil resizeFrame:lResultAreaFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
    }
    
    mResultAreaFrameNoAd = lResultAreaFrame;
    
    // some colors
    UIColor* lpBtnColor = [UIColor whiteColor];
    UIColor* lpBtnHoverColor = [ColorUtil colorFromInteger:0x808080];
    
    // add views
    // choose snapshot button
    mpBtnChooseImage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mpBtnChooseImage.frame = lChooseImageFrame;
    UIImage* lpImgChooseImage = [ColorUtil newImage:@"btnsnapshot.png"];
    UIImage* lpImgChooseImageHover = [ColorUtil newImage:@"btnsnapshothover.png"];
    [mpBtnChooseImage setBackgroundImage:lpImgChooseImage forState:UIControlStateNormal];
    [mpBtnChooseImage setBackgroundImage:lpImgChooseImageHover forState:UIControlStateHighlighted];
    mpBtnChooseImage.titleLabel.textAlignment = UITextAlignmentCenter;
    mpBtnChooseImage.titleLabel.font = [Global getCommonBoldFont:([DictUtil isIPad] ? 44 : 22)];
    mpBtnChooseImage.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [mpBtnChooseImage setTitle:@"Import Screenshot" forState:UIControlStateNormal];
    [mpBtnChooseImage setTitleColor:lpBtnColor forState:UIControlStateNormal];
    [mpBtnChooseImage setTitleColor:lpBtnHoverColor forState:UIControlStateHighlighted];
    [mpBtnChooseImage addTarget:self action:@selector(chooseSnapshotImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mpBtnChooseImage];
    
    // create title view
    UIImageView* lpTitleView = [[UIImageView alloc] initWithFrame:lTitleFrame];
    UIImage* lpTitleImage = [ColorUtil newImage:@"title.png"];//([DictUtil isIPad] ? @"title_shadow.png" : @"title.png")];
    lpTitleView.image = lpTitleImage;
    [self addSubview:lpTitleView];
    
    // create setting button
    mpBtnSetting = [[DropDownButton alloc] initWithFrame:lSettingFrame mainVC:mpMainVC popRect:lSettingFrame];
     UIImage* lpSettingImage = [ColorUtil newImage:@"settings.png"];
    [mpBtnSetting setImage:lpSettingImage forState:UIControlStateNormal];
    
    int lLangStatus = 0;
    NSString* lpLanguageCode = [Global getLanguageSetting];
    if (lpLanguageCode == nil) {
        // the default language is read from the device reference.
        lLangStatus = ([DictUtil isChinesePreferred] ? 1 : 0);
    }
    else {
        lLangStatus = ([lpLanguageCode compare:LANGUAGE_NONE] == NSOrderedSame ? 0 : 1);
    }

    [mpBtnSetting refleshStatus:lLangStatus];
    [Global setLanguageSetting:(lLangStatus == 1 ? LANGUAGE_CHINESE : LANGUAGE_NONE)];
    //[mpBtnSetting addTarget:self action:@selector(changeSettings) forControlEvents:UIControlEventTouchUpInside];
    mpBtnSetting.mDelegate = self;
    [self addSubview:mpBtnSetting];
    
    // add labels of word length.
    //[self addLabel:@"Word Length:" frame:lLblLengthFrame];    
    
    // input text field for length
    //mpTxtLength = [self addTextField:lTxtLengthFrame];
    //mpTxtLength.clearsOnBeginEditing = YES;
    //mpTxtLength.keyboardType = UIKeyboardTypeNumberPad;
//    mSlider = [[UISlider alloc] initWithFrame:CGRectZero];
//	UIImage * thumb = [UIImage imageNamed:@"FinalBundle.bundle/Contents/Resources/SliderRangeHandle.png"];
//	UIImage* track = [[[UIImage imageNamed:@"FinalBundle.bundle/Contents/Resources/SliderTrack"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
//    
//	[mSlider setThumbImage:thumb forState:UIControlStateNormal];
//	[mSlider setMinimumTrackImage:track forState:UIControlStateNormal];
//	[mSlider setMaximumTrackImage:track forState:UIControlStateNormal];
//	[track release];
//	
//	[mSlider addTarget:self action:@selector(sliderTouchesMoved:) forControlEvents:UIControlEventValueChanged];
//	[mSlider addTarget:self action:@selector(sliderTouchesBegan:) forControlEvents:UIControlEventTouchDown];
//	[mSlider addTarget:self action:@selector(sliderTouchesEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    mpSldLength = [[UISlider alloc] initWithFrame:lSldLengthFrame];
    mpSldLength.minimumValue = MIN_WORD_LENGTH;
    mpSldLength.maximumValue = MAX_WORD_LENGTH;
    //mpSldLength.continuous = NO;
    //[mpSldLength addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [mpSldLength addTarget:self action:@selector(sliderTouchesMoved:) forControlEvents:UIControlEventValueChanged];
    [mpSldLength addTarget:self action:@selector(sliderTouchesBegan:) forControlEvents:UIControlEventTouchDown];
    [mpSldLength addTarget:self action:@selector(sliderTouchesEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [self addSubview:mpSldLength];
    
    // add number lable for word length
    mpLblLength = [self addLabel:@"" frame:lLblLengthFrame];
    
    [self setWordLength:DEFAULT_WORD_LENGTH];
    
    // input text field for letters
    mpTxtChars = [self addTextField:lTxtLettersFrame];
    mpTxtChars.placeholder = @"Enter Letters...";
    mpTxtChars.clearButtonMode = UITextFieldViewModeWhileEditing;
    mpTxtChars.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    mpTxtChars.keyboardType = UIKeyboardTypeAlphabet;
    
    // reset button
    mpBtnReset = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mpBtnReset.frame = lResetFrame;
    UIImage* lpImgReset = [ColorUtil newImage:@"reset.png"];
    UIImage* lpImgResetHover = [ColorUtil newImage:@"resethover.png"];
    [mpBtnReset setBackgroundImage:lpImgReset forState:UIControlStateNormal];
    [mpBtnReset setBackgroundImage:lpImgResetHover forState:UIControlStateHighlighted];
    mpBtnReset.titleLabel.textAlignment = UITextAlignmentCenter;
    mpBtnReset.titleLabel.font = [Global getCommonBoldFont:[DictUtil isIPad] ? 38 : 18];
    mpBtnReset.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [mpBtnReset setTitle:@"Reset" forState:UIControlStateNormal];
    [mpBtnReset setTitleColor:lpBtnColor forState:UIControlStateNormal];
    [mpBtnReset setTitleColor:lpBtnHoverColor forState:UIControlStateHighlighted]; 
    [mpBtnReset addTarget:self action:@selector(resetViews) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mpBtnReset];
    
    // hint text of result area
    mpTxtHint = [[UITextView alloc] initWithFrame:lResultAreaFrame];
    mpTxtHint.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.7];
    mpTxtHint.editable = NO;
    mpTxtHint.font = [Global getCommonLightFont:[DictUtil isIPad] ? 16 : 14];
    //mpTxtHint.textColor = [Global getDarkTextColor];
    [self addSubview:mpTxtHint];
    
    // text result area
    mpResultWordsView = [[ResultWordsView alloc] initWithFrame:lResultAreaFrame style:UITableViewStylePlain];
    mpResultWordsView.hidden = YES;
    mpResultWordsView.mDelegate = self;
    [self addSubview:mpResultWordsView];
    
    // waiting indicator
//    mpActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    mpActivityIndicator.frame = CGRectMake(0, 0, 32, 32);
//    [mpActivityIndicator setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
//    [mpMainVC.view addSubview:mpActivityIndicator];
//    [mpActivityIndicator release];
    
    // hide UIs for screenshot to get default lauch image.
#if defined (UI_HIDDEN)
    mpBtnChooseImage.hidden = YES;
    mpBtnSetting.hidden = YES;
    mpTxtChars.hidden = YES;
    mpSldLength.hidden = YES;
    mpLblLength.hidden = YES;
    mpBtnReset.hidden = YES;
    mpResultWordsView.hidden = YES;
#endif
}

- (void)initHintsText {
    NSMutableString* lpHintsText = [[NSMutableString alloc] initWithCapacity:0];
    if ([DictUtil isIPad]) {
        [lpHintsText appendString:@"Hints:\n\n"];
//        [lpHintsText appendString:@"The app provides two input ways:\n"];
//        [lpHintsText appendString:@"1. Import a screenshot from your \"Draw Something\" game. It will recognize the screenshot automatically and return candidate words in an instant.\n"];
//        [lpHintsText appendString:@"2. Enter the word length and the candidate letters manually. It will search the words after every typing immediately.\n"];
    }
    else {
        [lpHintsText appendString:@"Hints:\n"];
//        [lpHintsText appendString:@"1. The app can automatically recognize the screenshot from your \"Draw Something\" game, and also the letters entered by you manually.\n"];
//        [lpHintsText appendString:@"2. The app provides candidate words in an instant, with or without Chinese explanations configured by the top-right \"Setting\" button.\n"];
    }
    
    [lpHintsText appendString:@"1. The app can automatically recognize the screenshot of your \"Draw Something\" game.\n"];
    [lpHintsText appendString:@"2. It also supports entering letters manumally if the recognizer fails. The screenshots of \"Draw Something 2\" are not supported yet.\n\n"];
    [lpHintsText appendString:@"Please rate me if you like it. :)"];
    
    mpHintsText = lpHintsText;
}

- (void)setWordLength:(int)iLength {
    mpSldLength.value = iLength;
    mpLblLength.text = [NSString stringWithFormat:@"%d", iLength];
}

- (void)resizeForAds:(CGSize)iAdSize showAd:(BOOL)iShowAd animation:(BOOL)doAnimation {
    BOOL lNeedResize = false;
    CGRect lNewFrame = mResultAreaFrameNoAd;
    if (iShowAd && mpResultWordsView.frame.size.height != mResultAreaFrameNoAd.size.height - iAdSize.height) {
        lNeedResize = true;
        lNewFrame.size.height -= iAdSize.height;
    }
    else if (!iShowAd && mpResultWordsView.frame.size.height != mResultAreaFrameNoAd.size.height) {
        lNeedResize = true;
    }
    
    if (lNeedResize) {
        if (doAnimation) {
            if (!mpResultWordsView.hidden) {
                mpTxtHint.frame = lNewFrame;
                
                [UIView animateWithDuration:1.0 animations:^ {
                    mpResultWordsView.frame = lNewFrame;
                }];
            }
            else {
                mpResultWordsView.frame = lNewFrame;
                
                [UIView animateWithDuration:1.0 animations:^ {
                    mpTxtHint.frame = lNewFrame;
                }];
            }
        }
        else {
            mpTxtHint.frame = lNewFrame;
            mpResultWordsView.frame = lNewFrame;
        }
    }
}

- (void)displayHints:(NSString*)iHints textColor:(UIColor*)ipColor {
#if !defined (UI_HIDDEN)
    mpTxtHint.text = iHints;
#endif
    mpTxtHint.textColor = ipColor;
    
    mpResultWordsView.hidden = YES;
    mpTxtHint.hidden = NO;
}

- (void)chooseSnapshotImage {
    [self releaseFocusInTextFields];
    
    [mpImageChooser displayImagePickerWindow];
}

//- (void)changeSettings {
//    
//}

- (void)resetViews {
    [self releaseFocusInTextFields];
    
#if defined (FREE_VERSION)
    AdManager* lpAdManager = [Global getAdManager];
    NSString* lpText = mpTxtChars.text;
    // get super privilege.
    NSString* lpPrivilegeKey = [Global getPrivilegeKey];
    if (lpPrivilegeKey != nil) {
        if ([lpPrivilegeKey compare:lpText] == NSOrderedSame) {
            [Global saveSuperPrivilege];
            [self resizeForAds:CGSizeZero showAd:NO animation:NO];
            [lpAdManager performSelector:@selector(unloadAdBannerView)];
        }
    }
    // or remove super privilege
    NSString* lpRemovePrivilegeKey = [Global getRemovePrivilegeKey];
    if (lpRemovePrivilegeKey != nil) {
        if ([lpRemovePrivilegeKey compare:lpText] == NSOrderedSame) {
            [Global removeSuperPrivilege];
            [lpAdManager performSelector:@selector(reloadAdBannerView)];
        }
    }
#endif
    
    // do real reset work.
    mpTxtChars.text = @"";
    [self setWordLength:DEFAULT_WORD_LENGTH];
    //mpTxtLength.text = @"";
    [mpBtnChooseImage setImage:nil forState:UIControlStateNormal];
    [self displayHints:mpHintsText textColor:[Global getHintInfoColor]];
    mpTxtHint.hidden = NO;
    mpResultWordsView.hidden = YES;
}

- (void)searchWords {
    NSString* lpChars = mpTxtChars.text;
    if (!lpChars || lpChars.length == 0) return;
    
    int lLen = [mpLblLength.text intValue];
    if (lLen <= 0) {
        [self displayHints:LENGTH_ONLY_NUMBER_ALLOWED textColor:[Global getHintErrorColor]];
        return;
    }
    
    if (lLen > 9) {
        [self displayHints:NO_WORDS_FOR_LENGTH textColor:[Global getHintErrorColor]];
        return;
    }
    
    @autoreleasepool {
        NSArray* lpResultWords = [mpDictCore lookupWords:lpChars length:lLen];
        //    NSMutableString* lpStrResults = [[NSMutableString alloc] initWithCapacity:0];
        //    for (int i=0; i<lpResultWords.count; ++i) {
        //        if (i > 0) {
        //            [lpStrResults appendString:@"\n"];
        //        }
        //        
        //        Word* lpWord = [lpResultWords objectAtIndex:i];
        //        [lpStrResults appendString:lpWord.mpWord];
        //    }
        //    mpTxtHint.text = lpResultWords;
        //    [lpStrResults release];
        
        if (lpResultWords.count > 0) {
            NSMutableArray* lpDividedWords = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray* lpPriorityMap = [Global getPriorityMap];
            for (int i=0; i<lpPriorityMap.count; ++i) {
                NSMutableArray* lpItems = [[NSMutableArray alloc] initWithCapacity:0];
                [lpDividedWords addObject:lpItems];
            }
            
            // divide words by priority.
            for (Word* lpWord in lpResultWords) {
                int lIndex = (lpWord.mPriority < lpDividedWords.count ? lpWord.mPriority : lpDividedWords.count - 1);
                NSMutableArray* lpItems = [lpDividedWords objectAtIndex:lIndex];
                [lpItems addObject:lpWord];
            }
            
            // construct data from mpResultWordsView.
            NSMutableDictionary* lpItemMap = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray* lpItemKeys = [[NSMutableArray alloc] initWithCapacity:0];
            // we should display sections for higher priority first (bigger value).
            for (int i=lpDividedWords.count-1; i>=0; --i) {
                NSMutableArray* lpItems = [lpDividedWords objectAtIndex:i];
                if (lpItems.count > 0) {
                    NSString* lpItemKey = [lpPriorityMap objectAtIndex:i];
                    [lpItemKeys addObject:lpItemKey];
                    [lpItemMap setObject:lpItems forKey:lpItemKey];
                }
            }
            
            [mpResultWordsView refreshData:lpItemMap dataKeys:lpItemKeys];
            
            mpTxtHint.hidden = YES;
            mpResultWordsView.hidden = NO;
        }
        else {
            // Cannot find any words. Ooops.
            [self displayHints:CANNOT_FIND_WORDS  textColor:[Global getHintWarningColor]];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    float redTop, greenTop, blueTop;
    [ColorUtil intToRGB2:BG_TOP_COLOR withRed:&redTop andGreen:&greenTop andBlue:&blueTop];
    
    float redBottom, greenBottom, blueBottom;
    [ColorUtil intToRGB2:BG_BOTTOM_COLOR withRed:&redBottom andGreen:&greenBottom andBlue:&blueBottom];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef gradientColorSpace=CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {redTop, greenTop, blueTop, 1.0, redBottom, greenBottom, blueBottom,1.0};
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(gradientColorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint, myEndPoint;
    myStartPoint=CGPointMake(0, 0);
    myEndPoint.x = 0;
    myEndPoint.y = rect.size.height;
    CGContextDrawLinearGradient (ctx, myGradient, myStartPoint, myEndPoint, 0);	
    CGColorSpaceRelease(gradientColorSpace);
    CGGradientRelease(myGradient);
}


- (void)releaseFocusInTextFields {
    if ([mpTxtChars isFirstResponder]) {
        [mpTxtChars resignFirstResponder];
    }
    
//    if ([mpTxtLength isFirstResponder]) {
//        [mpTxtLength resignFirstResponder];
//    }
}

- (void)removeTooltipView {
    if (mpTooltipView) {
        [mpTooltipView fadeOut];
        [mpTooltipView removeFromSuperview];
        mpTooltipView = nil;
    }
}

//- (void)sliderChanged:(UISlider*)ipSlider {
//    mpLblLength.text = [NSString stringWithFormat:@"%d", (int)(ipSlider.value + 0.5)];
//    
//    [self searchWords];
//}

- (void)sliderTouchesBegan:(UISlider*)ipSlider {
    [self releaseFocusInTextFields];
}

- (void)sliderTouchesMoved:(UISlider*)ipSlider {
    if (mpLblLength.text.intValue != (int)(ipSlider.value + 0.5)) {
        mpLblLength.text = [NSString stringWithFormat:@"%d", (int)(ipSlider.value + 0.5)];
    }
}

- (void)sliderTouchesEnd:(UISlider*)ipSlider {
    [self searchWords];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self removeTooltipView];
//}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* lpTouchedView = [super hitTest:point withEvent:event];
    
    if (mpTooltipView) {
        [self removeTooltipView];
        [mpResultWordsView deselectAll];
//        [mpTooltipView removeFromSuperview];
//        mpTooltipView = nil;
    }
    
//    if (lpTouchedView != mpTxtChars && lpTouchedView != mpTxtLength) {
//        [self releaseFocusInTextFields];
//	}
    
    //NSSet* touches = [event allTouches];
    // handle touches if you need
    return lpTouchedView;
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	UITouch *lpTouch = [touches anyObject];
	UIView* lpView = [lpTouch view];
	if (lpView != mpTxtChars) {
        [self releaseFocusInTextFields];
	}
}

#pragma mark - ImageChooserDelegate methods
- (void)searchWordsWithImage:(UIImage*)ipImage {
    NSMutableString* lpChars = [[NSMutableString alloc] initWithCapacity:0];
    int lNGuessChars = [mpImageRecognizer recognizeImage:ipImage oCharts:lpChars];
    if (lNGuessChars >= MIN_WORD_LENGTH && lNGuessChars <= MAX_WORD_LENGTH && lpChars.length >= lNGuessChars) {
        mpTxtChars.text = [lpChars uppercaseString];
        [self setWordLength:lNGuessChars];
        //mpTxtLength.text = [NSString stringWithFormat:@"%d", lNGuessChars];
        [self searchWords];
    }
    else {
        // not correct pic.
        //mpTxtLength.text = @"";
        
        mpTxtChars.text = @"";
        [self displayHints:SCREENSHOT_CANNOT_RECOGNIZE textColor:[Global getHintErrorColor]];
    }
    
    [Global hideWaitView];
}

- (void)handleChosenImage:(UIImage*)ipImage {
    if (!ipImage) return;
    
    [Global showWaitView:mpMainVC.view text:nil bgMask:YES iconBgMask:NO];

    [mpBtnChooseImage setImage:ipImage forState:UIControlStateNormal];
    
    //[self searchWordsWithRetainedImage:[ipImage retain]];
    [self performSelector:@selector(searchWordsWithImage:) withObject:ipImage afterDelay:0];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL lAllowed = YES;
    @autoreleasepool {
//        if (textField == mpTxtLength) {
//            lAllowed = [DictUtil stringInCharSet:string charSet:[Global getNumbersCharSet]];
//            if (!lAllowed) {
//                if (!mpTxtHint.hidden) {
//                    [self displayHints:LENGTH_ONLY_NUMBER_ALLOWED textColor:[Global getHintErrorColor]];
//                }
//            }
//        }
//        else 
        if (textField == mpTxtChars) {
            lAllowed = [DictUtil stringInCharSet:string charSet:[Global getAlphaCharSet]];
            if (!lAllowed) {
                if (!mpTxtHint.hidden) {
                    [self displayHints:LETTERS_ONLY_LETTER_ALLOWED textColor:[Global getHintErrorColor]];
                }
            }
        }
    }
    
    return lAllowed;
}

#pragma mark - ResultWordsViewDelegate methods
- (void)didSelectItem:(Word*)ipWord cellFrame:(CGRect)iCellFrame {
    [self removeTooltipView];
    [self releaseFocusInTextFields];

    CGRect lFrame = mpResultWordsView.frame;
    CGRect lCellFrame = iCellFrame;
    lCellFrame.origin.x += lFrame.origin.x;
    lCellFrame.origin.y += lFrame.origin.y;
    
    mpTooltipView = [[TooltipView alloc] initWithAvailFrameInContainer:self.frame withDataElementFrame:lCellFrame data:ipWord];
    [self addSubview:mpTooltipView];
}

#pragma mark - DropDownButtonDelegate methods
- (void)didSelectItem:(NSString*)mpLanguage {
    if (![mpDictCore isCnDictLoaded] && mpLanguage != nil && [mpLanguage compare:LANGUAGE_NONE] != NSOrderedSame) {
        [Global showWaitView:mpMainVC.view text:LOADING_DICTIONARY bgMask:NO iconBgMask:YES];
        [self performSelector:@selector(loadDictAndRefresh:) withObject:mpLanguage afterDelay:0];
    }
    else {
        [Global setLanguageSetting:mpLanguage];
        [mpResultWordsView reloadData];
    }
}

- (void)loadDictAndRefresh:(NSString*)mpLanguage {
    [mpDictCore reInitDicts:NO];

    [Global setLanguageSetting:mpLanguage];
    
    [self searchWords];
    
    [Global hideWaitView];
}

#if defined (FREE_VERSION)
#pragma mark - AdManagerDelegate methods
- (void)adViewDidReceiveAd:(CGSize)iAdViewSize {
    [self resizeForAds:iAdViewSize showAd:YES animation:YES];
}
#endif

@end
