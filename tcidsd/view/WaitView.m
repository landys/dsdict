//
//  WaitView.m
//  tcidsd
//
//  Created by Jinde Wang on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WaitView.h"
//#import "Global.h"

@interface WaitView (Private)

- (void)addWaitLabel;
- (void)addWaitActivity;

@end

@implementation WaitView

@synthesize mpWaitLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];    
	if (self) {
		[self addWaitLabel];
		[self addWaitActivity];
    }
    return self;
}

- (void) startAnimating {
    self.hidden = NO;
	[mpWaitActivity startAnimating];
}

- (void) stopAnimating {
	[mpWaitActivity stopAnimating];
    self.hidden = YES;
}

- (void)addWaitLabel {
	mpWaitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	mpWaitLabel.backgroundColor = [UIColor clearColor];
	mpWaitLabel.opaque = NO;
	mpWaitLabel.text = @"Loading...";
	mpWaitLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:18];//[Global getCommonBoldFont:18];
	mpWaitLabel.textColor = [UIColor whiteColor];
	//mpWaitLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:mpWaitLabel];
    [mpWaitLabel release];
}

- (void)addWaitActivity {
	mpWaitActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//mpWaitActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:mpWaitActivity];
    [mpWaitActivity release];
}

- (void)resetSubviewsFrames {
    CGSize lParentSize = self.frame.size;
	CGSize lWaitLabelSize = mpWaitLabel.text.length > 0 ? [mpWaitLabel sizeThatFits:CGSizeZero] : CGSizeZero;
	CGSize lWaitActivitySize = mpWaitActivity.frame.size;
    
    CGFloat lWaitHeight = lWaitLabelSize.height + lWaitActivitySize.height;
    mpWaitActivity.frame = CGRectMake((lParentSize.width - lWaitActivitySize.width) / 2, (lParentSize.height - lWaitHeight) / 2, lWaitActivitySize.width, lWaitActivitySize.height);
    mpWaitLabel.frame = CGRectMake((lParentSize.width - lWaitLabelSize.width) / 2, mpWaitActivity.frame.origin.y + lWaitActivitySize.height, lWaitLabelSize.width, lWaitLabelSize.height);
}

@end
