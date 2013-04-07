//
//  SectionHeaderViewer.mm
//  dsdict
//
//  Created by Jinde Wang on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionHeaderViewer.h"
#import "ColorUtil.h"
#import "Global.h"

#define SECTION_TITLE_FOND_SIZE 16

@implementation SectionHeaderViewer

- (id)initWithFrame:(CGRect)frame wordsTitle:(NSString*)ipWordsTitle wordsCount:(int)iWordsCount {
    self = [super initWithFrame:frame];
	if (self) {
        @autoreleasepool {
            NSString* lpTitle = [[NSString alloc] initWithFormat:@"%d %@", iWordsCount, ipWordsTitle];
            UILabel* lpLblWordsTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 6)];
            lpLblWordsTitle.text = lpTitle;
            lpLblWordsTitle.textAlignment = UITextAlignmentCenter;
            lpLblWordsTitle.backgroundColor = [UIColor clearColor];
            lpLblWordsTitle.font = [Global getCommonBoldFont:SECTION_TITLE_FOND_SIZE];//lpLblWordsTitle.font.pointSize];	
            lpLblWordsTitle.shadowOffset=CGSizeMake(0, 1);
            lpLblWordsTitle.textColor = [UIColor whiteColor];
            lpLblWordsTitle.shadowColor=[UIColor colorWithRed:0xb1/0xff green:0xb1/0xff blue:0xb1/0xff alpha:0.5];
            [self addSubview:lpLblWordsTitle];
        }
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
	int firstColor = 0xc25075;
	int secondColor = 0xbe325f;
	// draw gradient
	float redLight, greenLight, blueLight;
	[ColorUtil intToRGB2: firstColor withRed:&redLight andGreen:&greenLight andBlue:&blueLight];
	
	float redDark, greenDark, blueDark;
	[ColorUtil intToRGB2: secondColor withRed:&redDark andGreen:&greenDark andBlue:&blueDark];
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGColorSpaceRef gradientColorSpace=CGColorSpaceCreateDeviceRGB();
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = {redLight, greenLight, blueLight, 1.0, redDark, greenDark, blueDark,1.0};
	CGGradientRef myGradient = CGGradientCreateWithColorComponents(gradientColorSpace, components, locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint=CGPointMake(0, 0);
	myEndPoint.x = 0;
	myEndPoint.y = rect.size.height;
	CGContextDrawLinearGradient (ctx, myGradient, myStartPoint, myEndPoint, 0);	
	CGColorSpaceRelease(gradientColorSpace);
	CGGradientRelease(myGradient);
	// draw border
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, 0, rect.size.height);
	CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
	CGContextSetRGBStrokeColor(ctx, 0x98/255.f, 0x9e/255.f, 0xa4/255.f, 1.f);
	CGContextStrokePath(ctx);
	
	CGContextMoveToPoint(ctx, 0, 0);
	CGContextAddLineToPoint(ctx, rect.size.width, 0);
	CGContextSetRGBStrokeColor(ctx, 0xa5/255.f, 0xb1/255.f, 0xba/255.f, 1.f);
	CGContextStrokePath(ctx);
}

//- (void)dealloc {
//	[mpWeekday release];
//	[mpDate release];
//	
//	[super dealloc];
//}

@end
