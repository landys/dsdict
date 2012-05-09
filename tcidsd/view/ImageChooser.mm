//
//  ImageChooser.m
//  tcidsd
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageChooser.h"
#import "DictUtil.h"

@interface ImageChooser (Private)

- (void)dismissImagePickerWindow;

@end

@implementation ImageChooser

@synthesize mpDelegate;

- (id)initWithMainViewController:(UIViewController*)ipViewController popRect:(CGRect)iRect {
    self = [super init];
    if (self) {
        mpMainVC = ipViewController;
        mPopRect = iRect;
        
        mpImagePicker = [[UIImagePickerController alloc] init];
        mpImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
        mpImagePicker.delegate = self; 
        mpImagePicker.allowsEditing = NO;
        
        if ([DictUtil isIPad]) {
            mpPopover = [[UIPopoverController alloc] initWithContentViewController:mpImagePicker];
            mpPopover.delegate = self;
        }
    }
    return self;
}

- (void)displayImagePickerWindow {
    if ([DictUtil isIPad]) {
        [mpPopover presentPopoverFromRect:mPopRect inView:mpMainVC.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [mpMainVC presentModalViewController:mpImagePicker animated:YES]; 
    } 
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* lpImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (lpImage) {
        [mpDelegate handleChosenImage:lpImage];
    }

    [self dismissImagePickerWindow];
}

- (void)dismissImagePickerWindow {
    if ([DictUtil isIPad]) {
        if (mpPopover && mpPopover.isPopoverVisible) {
            [mpPopover dismissPopoverAnimated:YES];
        }
	}
    else {
        [mpMainVC dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [mpImagePicker release];
    [mpPopover release];
    [mpDelegate release];
    [super dealloc];
}

@end
