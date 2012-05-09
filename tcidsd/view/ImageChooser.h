//
//  ImageChooser.h
//  tcidsd
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageChooserDelegate <NSObject>

- (void)handleChosenImage:(UIImage*)ipImage;

@end

@interface ImageChooser : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    UIImagePickerController* mpImagePicker;
    // for ipad
    UIPopoverController* mpPopover;

    UIViewController* mpMainVC;
    CGRect mPopRect;
    
    id<ImageChooserDelegate> mpDelegate;
}

@property (nonatomic, retain) id<ImageChooserDelegate> mpDelegate;

- (id)initWithMainViewController:(UIViewController*)ipViewController popRect:(CGRect)iRect;
- (void)displayImagePickerWindow;

@end
