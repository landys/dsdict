//
//  DropDownButton.h
//  tcidsd
//
//  Created by Jinde Wang on 14/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DropDownListViewController.h"

@protocol DropDownButtonDelegate

@optional
- (void)didSelectItem:(NSString*)mpLanguage;

@end

@interface DropDownButton : UIButton<UIActionSheetDelegate> {
    // for ipad
    //UIPopoverController* mpPopover;
  
    UIViewController* mpMainVC;
    CGRect mPopRect;
    
//    NSArray* mpData;
//    int mSelectedIndex;
    
    // 0 - none, 1 - cn.
    int mStatus;
    
    //DropDownListViewController* mpDropDownListViewController;
    
    id<DropDownButtonDelegate> mDelegate;
}

@property (nonatomic, assign) id<DropDownButtonDelegate> mDelegate;

- (id)initWithFrame:(CGRect)frame mainVC:(UIViewController*)ipViewController popRect:(CGRect)iRect;
//- (void)refleshData:(NSArray*)ipData selectIndex:(int)iSelectIndex; 
//- (void)setSelectedIndex:(int)iSelectedIndex;
- (void)refleshStatus:(int)iStatus;

@end
