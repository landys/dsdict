//
//  DropDownButton.m
//  tcidsd
//
//  Created by Jinde Wang on 14/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DropDownButton.h"
#import "DictUtil.h"
#import "Global.h"

@interface DropDownButton (Private)

- (void)onButtonClicked;
- (void)displayDropDownList;
//- (void)dismissDropDownList;

@end

@implementation DropDownButton
@synthesize mDelegate;

- (id)initWithFrame:(CGRect)frame mainVC:(UIViewController*)ipViewController popRect:(CGRect)iRect {
    self = [super initWithFrame:frame];
    if (self) {
        mpMainVC = ipViewController;
        mPopRect = iRect;
        
        // default is cn.
        mStatus = 1;
        
        //mpData = [[Global getLanguages] retain];
        //mSelectedIndex = 0;
        
//        mpDropDownListViewController = [[DropDownListViewController alloc] initWithStyle:UITableViewStylePlain];
//        mpDropDownListViewController.mDelegate = self;
//        
//        if ([DictUtil isIPad]) {
//            mpPopover = [[UIPopoverController alloc] initWithContentViewController:mpDropDownListViewController];
//        }
        
        [self addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)displayDropDownList {
//    if ([DictUtil isIPad]) {
//        [mpPopover presentPopoverFromRect:mPopRect inView:mpMainVC.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    }
//    else {
//        [mpMainVC presentModalViewController:mpDropDownListViewController animated:YES]; 
//    } 
//    NSArray* lpLanguages = mpData;
    UIActionSheet* lpDropDownList = [[UIActionSheet alloc] initWithTitle:@"Settings" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (mStatus == 0) {
        [lpDropDownList addButtonWithTitle:@"Show Chinese Explanations"];
    }
    else {
        [lpDropDownList addButtonWithTitle:@"Hide Chinese Explanations"];
    }
    
    [lpDropDownList addButtonWithTitle:@"Rate me"];
    NSString* lpUpgradeUrl = [Global getUpgradeUrl];
    if (lpUpgradeUrl != nil && lpUpgradeUrl.length > 0) {
        [lpDropDownList addButtonWithTitle:@"Upgrade to Ad Free Version"];
    }
    
//    for (int i=0; i<lpLanguages.count; ++i) {
//        //if (mSelectedIndex != i) {
//        [lpDropDownList addButtonWithTitle:[lpLanguages objectAtIndex:i]];
//        //}
//    }
    [lpDropDownList addButtonWithTitle:@"Cancel"];
    lpDropDownList.cancelButtonIndex = lpDropDownList.numberOfButtons - 1;
    
    if ([DictUtil isIPad]) {
        [lpDropDownList showFromRect:mPopRect inView:mpMainVC.view animated:YES];
    } else {
        [lpDropDownList showInView:mpMainVC.view];
    }
}

//- (void)dismissDropDownList {
//    if ([DictUtil isIPad]) {
//        if (mpPopover && mpPopover.isPopoverVisible) {
//            [mpPopover dismissPopoverAnimated:YES];
//        }
//	}
//    else {
//        [mpMainVC dismissModalViewControllerAnimated:YES];
//    }
//}

- (void)onButtonClicked {
    [self displayDropDownList];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 0) {
        if (mStatus == 0) {
            mStatus = 1;
            [mDelegate didSelectItem:LANGUAGE_CHINESE];
        }
        else {
            mStatus = 0;
            [mDelegate didSelectItem:LANGUAGE_NONE];
        }
    }
    else if (buttonIndex == 1) {
        // redirect to rate page.
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Global getRateUrl]]];
    }
    else if (buttonIndex == 2) {
        // only in free version, upgrade
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Global getUpgradeUrl]]];        
    }
}

- (void)refleshStatus:(int)iStatus {
    mStatus = iStatus;
}

//- (void)setSelectedIndex:(int)iSelectedIndex {
//    int lIndex = iSelectedIndex;// >= mpData.count ? 0 : iSelectedIndex;
//    [self setTitle:[mpData objectAtIndex:lIndex] forState:UIControlStateNormal];
//    
//    mSelectedIndex = lIndex;
//}

//- (void)refleshData:(NSArray*)ipData selectIndex:(int)iSelectIndex {
//    if (ipData == nil || ipData.count <= iSelectIndex) return;
//    
//    [self setTitle:[ipData objectAtIndex:iSelectIndex] forState:UIControlStateNormal];
//    [mpDropDownListViewController refleshData:ipData selectIndex:iSelectIndex];
//}

//- (void)didSelectItem:(int)mpIndex text:(NSString*)mpText {
//    [self setTitle:mpText forState:UIControlStateNormal];
//    
//    [self dismissDropDownList];
//    
//    [mDelegate didSelectItem:mpIndex];
//}

//- (void)dealloc {
//    //[mpDropDownListViewController release];
//    //[mpPopover release];
//    [mpData release];
//    [super dealloc];
//}

@end
