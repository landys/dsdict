//
//  WaitView.m
//  dsdict
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

@synthesize mpWaitLabel, mBgMask, mIconBgMask;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];    
	if (self) {
        mBgMask = YES;
        mIconBgMask = NO;
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
}

- (void)addWaitActivity {
	mpWaitActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//mpWaitActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:mpWaitActivity];
}

- (void)resetSubviewsFrames {
    CGSize lParentSize = self.frame.size;
	CGSize lWaitLabelSize = mpWaitLabel.text.length > 0 ? [mpWaitLabel sizeThatFits:CGSizeZero] : CGSizeZero;
	CGSize lWaitActivitySize = mpWaitActivity.frame.size;
    
    CGFloat lWaitHeight = lWaitLabelSize.height + lWaitActivitySize.height;
    mpWaitActivity.frame = CGRectMake((lParentSize.width - lWaitActivitySize.width) / 2, (lParentSize.height - lWaitHeight) / 2, lWaitActivitySize.width, lWaitActivitySize.height);
    mpWaitLabel.frame = CGRectMake((lParentSize.width - lWaitLabelSize.width) / 2, mpWaitActivity.frame.origin.y + lWaitActivitySize.height, lWaitLabelSize.width, lWaitLabelSize.height);
}

- (void)setMBgMask:(BOOL)iBgMask {
    if (mBgMask != iBgMask) {
        mBgMask = iBgMask;
        if (mBgMask) {
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        }
        else {
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (mIconBgMask) {
        CGRect lActivityFrame = mpWaitActivity.frame;
        CGRect lIconBgRect = lActivityFrame;
        if (mpWaitLabel.text != nil && mpWaitLabel.text.length > 0) {
            CGRect lLabelRect = mpWaitLabel.frame;
            lIconBgRect.origin.x = MIN(lActivityFrame.origin.x, lLabelRect.origin.x);
            lIconBgRect.origin.y = MIN(lActivityFrame.origin.y, lLabelRect.origin.y);
            lIconBgRect.size.width = MAX(lActivityFrame.origin.x + lActivityFrame.size.width, lLabelRect.origin.x + lLabelRect.size.width) - lIconBgRect.origin.x;
            lIconBgRect.size.height = MAX(lActivityFrame.origin.y + lActivityFrame.size.height, lLabelRect.origin.y + lLabelRect.size.height) - lIconBgRect.origin.y;
        }
        lIconBgRect.origin.x -= 10;
        lIconBgRect.origin.y -= 10;
        lIconBgRect.size.width += 20;
        lIconBgRect.size.height += 20;
        
        CGFloat lX = lIconBgRect.origin.x;
        CGFloat lY = lIconBgRect.origin.y;
        CGFloat lWidth = lIconBgRect.size.width;
        CGFloat lHeight = lIconBgRect.size.height;
        
        CGFloat lRadius = (lWidth + lHeight) * 0.05;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextMoveToPoint(context, lX + lRadius, lY);
        
        CGContextAddLineToPoint(context, lX + lWidth - lRadius, lY);
        CGContextAddArc(context, lX + lWidth - lRadius, lY + lRadius, lRadius, -0.5 * M_PI, 0.0, 0);
        
        CGContextAddLineToPoint(context, lX + lWidth, lY + lHeight - lRadius);
        CGContextAddArc(context, lX + lWidth - lRadius, lY + lHeight - lRadius, lRadius, 0.0, 0.5 * M_PI, 0);
        
        CGContextAddLineToPoint(context, lX + lRadius, lY + lHeight);
        CGContextAddArc(context, lX + lRadius, lY + lHeight - lRadius, lRadius, 0.5 * M_PI, M_PI, 0);
        
        CGContextAddLineToPoint(context, lX, lY + lRadius);
        CGContextAddArc(context, lX + lRadius, lY + lRadius, lRadius, M_PI, 1.5 * M_PI, 0);
        
        CGContextClosePath(context);
        
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
        CGContextDrawPath(context, kCGPathFill);
    }
}

@end
