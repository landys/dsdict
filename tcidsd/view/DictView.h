//
//  DictView.h
//  tcidsd
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictCore.h"
#import "ImageChooser.h"
#import "ImageRecognizer.h"
#import "ResultWordsView.h"
#import "TooltipView.h"
#import "DropDownButton.h"
#import "SettingManager.h"

@interface DictView : UIView <ImageChooserDelegate, UITextFieldDelegate, ResultWordsViewDelegate, DropDownButtonDelegate> {
    DictCore* mpDictCore;
    
    // subviews
    UIButton* mpBtnChooseImage;
    DropDownButton* mpBtnSetting;
    UITextField* mpTxtChars;
    UITextField* mpTxtLength;
    UIButton* mpBtnReset;
    
    UITextView* mpTxtHint;
    
    ResultWordsView* mpResultWordsView;
    
    UIViewController* mpMainVC;
    
    ImageChooser* mpImageChooser;
    
    ImageRecognizer* mpImageRecognizer;
    
    //UIActivityIndicatorView* mpActivityIndicator;
    
    TooltipView* mpTooltipView;
    
    NSString* mpHintsText;
    
    CGRect mResultAreaFrameNoAd;
}

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)ipVC;
// iAdSize is only needed when iShowAd is YES.
- (void)resizeForAds:(CGSize)iAdSize showAd:(BOOL)iShowAd animation:(BOOL)doAnimation;

@end
