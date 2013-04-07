//
//  WaitView.h
//  dsdict
//
//  Created by Jinde Wang on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitView : UIView {
	UILabel* mpWaitLabel;
	UIActivityIndicatorView* mpWaitActivity;
    BOOL mBgMask;
    BOOL mIconBgMask;
}

@property (nonatomic, readonly) UILabel* mpWaitLabel;
@property (nonatomic) BOOL mBgMask;
@property (nonatomic) BOOL mIconBgMask;

- (void)startAnimating;
- (void)stopAnimating;
- (void)resetSubviewsFrames;

@end
