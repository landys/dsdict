//
//  DictView.m
//  tcidsd
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictView.h"
#import "Word.h"
#import "DictUtil.h"
#import "Global.h"

#define BG_TOP_COLOR 0x40c5f2 //0x3b6dcd
#define BG_BOTTOM_COLOR 0xe1f9ff //0x9be1f9 //0xffffff

#define LENGTH_ONLY_NUMBER_ALLOWED @"Only numbers are allowed in \"Word Length\" field, and the value should be bigger than 0."
#define NO_WORDS_FOR_LENGTH @"No results for word length bigger than 8, since it's designed only for \"Draw Something\". :)"
#define CANNOT_FIND_WORDS @"No results for current word length and candidate letters. Please enter more.\n\nIf you have finished your input, I'd to say the word is not in our library. :("
#define LETTERS_ONLY_LETTER_ALLOWED @"Only letters are allowed in \"Enter Letters\" field."
#define SCREENSHOT_CANNOT_RECOGNIZE @"Sorry, the imported \"Screenshot\" cannot be recognized.\n\nPlease check if it's really a screenshot of your \"Draw Something\" game. It should have the candidate letters at the bottom. :)"

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

@end

@implementation DictView

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)ipVC {
    self = [super initWithFrame:frame];
    if (self) {
        mpMainVC = ipVC;
        
        // init the hints text displayed at the beginning.
        [self initHintsText];
        
        mpDictCore = [[DictCore alloc] init];
        [mpDictCore initDicts];
        
        // image recognizer
        mpImageRecognizer = [[ImageRecognizer alloc] init];
        
        // create subviews
        [self createSubViews];
        
        // show hints at the beginning.
        [self displayHints:mpHintsText textColor:[Global getHintInfoColor]];
        
        // image chooser
        mpImageChooser = [[ImageChooser alloc] initWithMainViewController:mpMainVC popRect:mpBtnChooseImage.frame];
        mpImageChooser.mpDelegate = self;
       //mpImageChooser.mpActivityIndicator = mpActivityIndicator;
    }
    return self;
}

- (UILabel*)addLabel:(NSString*)ipText frame:(CGRect)iFrame{
    UILabel* lpLabel = [[UILabel alloc] initWithFrame:iFrame];
    lpLabel.text = ipText;
    lpLabel.font = [Global getCommonFont:([DictUtil isIPad] ? 33 : 17)];//lpLabel.font.pointSize)];
    lpLabel.backgroundColor = [UIColor clearColor];
    lpLabel.textColor = [ColorUtil colorFromInteger:0xfbfbfb];//[UIColor whiteColor];//[Global getLightTextColor];
    [self addSubview:lpLabel];
    [lpLabel release];
    
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
    [lpTextField release];
    
    return lpTextField;
}

- (void)createSubViews {
    // ipod=320*460. ipad=768*1004, because the title out of our application takes 20 pixels.
    // define frame size from photoshop, for iphone/ipod, assume size is 640*960;
    // for ipad, assume size is 720*960.
    CGRect lChooseImageFrame = CGRectMake(5, 3, 240, 360);
    CGRect lTitleFrame = CGRectMake(258, 10, 288, 72);
    CGRect lSettingFrame = CGRectMake(552, 10, 74, 72);
    CGRect lLblLengthFrame = CGRectMake(260, 90, 224, 72);
    CGRect lTxtLengthFrame = CGRectMake(485, 96, 150, 72);
    CGRect lTxtLettersFrame = CGRectMake(258, 186, 377, 72);
    CGRect lResetFrame = CGRectMake(368, 276, 148, 72);
    CGRect lResultAreaFrame = CGRectMake(5, 368, 630, 589);
    if ([DictUtil isIPad]) {
        lTitleFrame.size.width += 80;
        lSettingFrame.origin.x += 80;
        //lLblLengthFrame.origin.y += 4;
        lTxtLengthFrame.origin.x -= 10;
        lTxtLengthFrame.size.width += 90;
        lTxtLettersFrame.size.width += 80;
        lResetFrame.origin.x += 80 / 2;
        lResultAreaFrame.size.width += 80;
    }
    
    // resizing according to self.frame;
    CGRect lFrame = self.frame;
    float lSizeRatio = lFrame.size.height / lFrame.size.width;
    float lWidthRatio = 0;
    float lHeightRatio = lFrame.size.height / 960.0;
    if (fabsf(lSizeRatio - 960.0 / 640.0) < fabsf(lSizeRatio - 960.0 / 720.0)) {
        // ipod/iphone
        lWidthRatio = lFrame.size.width / 640.0;
    }
    else {
        // ipad
        lWidthRatio = lFrame.size.width / 720.0;
    }
    
    // resize frames.
    if (lWidthRatio != 1 || lHeightRatio != 1) {
        lChooseImageFrame = [DictUtil resizeFrame:lChooseImageFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lTitleFrame = [DictUtil resizeFrame:lTitleFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lSettingFrame = [DictUtil resizeFrame:lSettingFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lLblLengthFrame = [DictUtil resizeFrame:lLblLengthFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
        lTxtLengthFrame = [DictUtil resizeFrame:lTxtLengthFrame widthRatio:lWidthRatio heightRatio:lHeightRatio];
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
    [lpImgChooseImage release];
    [lpImgChooseImageHover release];
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
    [lpTitleImage release];
    [self addSubview:lpTitleView];
    [lpTitleView release];
    
    // create setting button
    mpBtnSetting = [[DropDownButton alloc] initWithFrame:lSettingFrame mainVC:mpMainVC popRect:lSettingFrame];
     UIImage* lpSettingImage = [ColorUtil newImage:@"settings.png"];
    [mpBtnSetting setImage:lpSettingImage forState:UIControlStateNormal];
    [lpSettingImage release];
    
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
    [mpBtnSetting release];
    
    // add labels of word length.
    [self addLabel:@"Word Length:" frame:lLblLengthFrame];    
    
    // input text field for length
    mpTxtLength = [self addTextField:lTxtLengthFrame];
    mpTxtLength.clearsOnBeginEditing = YES;
    //mpTxtLength.placeholder = @"5";
    mpTxtLength.keyboardType = UIKeyboardTypeNumberPad;
    
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
    [lpImgReset release];
    [lpImgResetHover release];    
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
    [mpTxtHint release];
    
    // text result area
    mpResultWordsView = [[ResultWordsView alloc] initWithFrame:lResultAreaFrame style:UITableViewStylePlain];
    mpResultWordsView.hidden = YES;
    mpResultWordsView.mDelegate = self;
    [self addSubview:mpResultWordsView];
    [mpResultWordsView release];
    
    // waiting indicator
//    mpActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    mpActivityIndicator.frame = CGRectMake(0, 0, 32, 32);
//    [mpActivityIndicator setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
//    [mpMainVC.view addSubview:mpActivityIndicator];
//    [mpActivityIndicator release];
}

- (void)initHintsText {
    NSMutableString* lpHintsText = [[NSMutableString alloc] initWithCapacity:0];
    if ([DictUtil isIPad]) {
        [lpHintsText appendString:@"Hints:\n\n"];
        [lpHintsText appendString:@"The app provides two input ways:\n"];
        [lpHintsText appendString:@"1. Import a screenshot from your \"Draw Something\" game. It will recognize the screenshot automatically and return candidate words in an instant.\n"];
        [lpHintsText appendString:@"2. Enter the word length and the candidate letters manually. It will search the words after every typing immediately.\n\n"];
        [lpHintsText appendString:@"The app provides two result views, that can be configured by the top-right \"Setting\" button:\n"];
        [lpHintsText appendString:@"1. Display the candidate words in detail, including the Chinese explanations. You can tap on the item to see the whole explanation in tooltip.\n"];
        [lpHintsText appendString:@"2. Display the candidate words in columns without Chinese explanations.\n\n"];
        [lpHintsText appendString:@"Please report issues to \"drawdict@gmail.com\", and rate for us if convenient.\n"];
        //[lpHintsText appendString:@"Good luck and have fun!\n"];
    }
    else {
        [lpHintsText appendString:@"Hints:\n"];
        [lpHintsText appendString:@"1. The app can automatically recognize the screenshot from your \"Draw Something\" game, and also the letters entered by you manually.\n"];
        [lpHintsText appendString:@"2. The app provides candidate words in an instant, with or without Chinese explanations configured by the top-right \"Setting\" button.\n\n"];
        [lpHintsText appendString:@"Please report issues to \"drawdict@gmail.com\", and rate for us if convenient.\n"];
        //[lpHintsText appendString:@"Good luck and have fun!\n"];
    }
    mpHintsText = lpHintsText;
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
    mpTxtHint.text = iHints;
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
    
    NSString* lpLengthText = mpTxtLength.text;
    // get super privilege.
    NSString* lpPrivilegeKey = [Global getPrivilegeKey];
    if (lpPrivilegeKey != nil) {
        if ([lpPrivilegeKey compare:lpLengthText] == NSOrderedSame) {
            [Global saveSuperPrivilege];
            [self resizeForAds:CGSizeZero showAd:NO animation:NO];
            [mpMainVC performSelector:@selector(unloadAdBannerView)];
        }
    }
    // or remove super privilege
    NSString* lpRemovePrivilegeKey = [Global getRemovePrivilegeKey];
    if (lpRemovePrivilegeKey != nil) {
        if ([lpRemovePrivilegeKey compare:lpLengthText] == NSOrderedSame) {
            [Global removeSuperPrivilege];
            [mpMainVC performSelector:@selector(reloadAdBannerView)];
        }
    }
    
    // do real reset work.
    mpTxtChars.text = @"";
    mpTxtLength.text = @"";
    [mpBtnChooseImage setImage:nil forState:UIControlStateNormal];
    [self displayHints:mpHintsText textColor:[Global getHintInfoColor]];
    mpTxtHint.hidden = NO;
    mpResultWordsView.hidden = YES;
}

- (void)searchWords {
    NSString* lpChars = mpTxtChars.text;
    if (!lpChars || lpChars.length == 0 || !mpTxtLength.text || mpTxtLength.text.length == 0) return;
    
    int lLen = [mpTxtLength.text intValue];
    if (lLen <= 0) {
        [self displayHints:LENGTH_ONLY_NUMBER_ALLOWED textColor:[Global getHintErrorColor]];
        return;
    }
    
    if (lLen > 8) {
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
                [lpItems release];
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
            [lpDividedWords release];
            
            [mpResultWordsView refreshData:lpItemMap dataKeys:lpItemKeys];
            [lpItemMap release];
            [lpItemKeys release];
            
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

- (void)dealloc {
    [mpDictCore release];
    [mpImageChooser release];
    [mpImageRecognizer release];
    [mpHintsText release];
    [super dealloc];
}

- (void)releaseFocusInTextFields {
    if ([mpTxtChars isFirstResponder]) {
        [mpTxtChars resignFirstResponder];
    }
    
    if ([mpTxtLength isFirstResponder]) {
        [mpTxtLength resignFirstResponder];
    }
}

- (void)removeTooltipView {
    if (mpTooltipView) {
        [mpTooltipView fadeOut];
        [mpTooltipView removeFromSuperview];
        mpTooltipView = nil;
    }
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self removeTooltipView];
//}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* lpTouchedView = [super hitTest:point withEvent:event];
    
    if (mpTooltipView) {
        [self removeTooltipView];
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
	if (lpView != mpTxtChars && lpView != mpTxtLength) {
        [self releaseFocusInTextFields];
	}
}

#pragma mark -
#pragma mark - ImageChooserDelegate methods
- (void)searchWordsWithImage:(UIImage*)ipImage {
    NSMutableString* lpChars = [[NSMutableString alloc] initWithCapacity:0];
    int lNGuessChars = [mpImageRecognizer recognizeImage:ipImage oCharts:lpChars];
    if (lNGuessChars > 0 && lNGuessChars <= 8 && lpChars.length > 1 && lpChars.length >= lNGuessChars) {
        mpTxtChars.text = [lpChars uppercaseString];
        mpTxtLength.text = [NSString stringWithFormat:@"%d", lNGuessChars];
        [self searchWords];
    }
    else {
        // not correct pic.
        mpTxtLength.text = @"";
        mpTxtChars.text = @"";
        [self displayHints:SCREENSHOT_CANNOT_RECOGNIZE textColor:[Global getHintErrorColor]];
    }
    [lpChars release];
    
    [Global hideWaitView];
}

- (void)handleChosenImage:(UIImage*)ipImage {
    if (!ipImage) return;
    
    [Global showWaitView:mpMainVC.view text:nil];

    [mpBtnChooseImage setImage:ipImage forState:UIControlStateNormal];
    
    //[self searchWordsWithRetainedImage:[ipImage retain]];
    [self performSelector:@selector(searchWordsWithImage:) withObject:ipImage afterDelay:0];
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL lAllowed = YES;
    @autoreleasepool {
        if (textField == mpTxtLength) {
            lAllowed = [DictUtil stringInCharSet:string charSet:[Global getNumbersCharSet]];
            if (!lAllowed) {
                if (!mpTxtHint.hidden) {
                    [self displayHints:LENGTH_ONLY_NUMBER_ALLOWED textColor:[Global getHintErrorColor]];
                }
            }
        }
        else if (textField == mpTxtChars) {
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

#pragma mark -
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
    [mpTooltipView release];
}

#pragma mark -
#pragma mark - DropDownButtonDelegate methods
- (void)didSelectItem:(NSString*)mpLanguage {
    [Global setLanguageSetting:mpLanguage];
    [mpResultWordsView reloadData];
}

@end
