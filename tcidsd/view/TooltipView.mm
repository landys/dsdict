//
//  TooltipView.mm
//  tcidsd
//
//  Created by Jinde Wang on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TooltipView.h"
#import <string>
#import "ColorUtil.h"
#import "Global.h"

#define OUT_CIRCLE_STROKE 2.0f

@interface TooltipView (Private)
- (void)createToolTip;
- (void)drawBackGroundWithContext:(CGRect)rect context:(CGContextRef)ctx;
- (CGMutablePathRef)createBorderPathFromRect:(CGRect)rect;
@end

@implementation TooltipView

const int TooltipFontSize = 16;
const float MaxLabelWidth = 160;
const float LabelGap = 8;
const float LeftPadding = 5;
const float RightPadding = 5;
const float TopPadding = 5;
const float BottomPadding = 5;
const float SeparatorLineGap = 6;
const float SepLineTopPadding = 2;
const float CornerRadius = 5;
const float OuterBorderWidth = 1;
const float InnerBorderWidth = 1;
const int LabelColor = 0x303030;//0xf0f0f0;
const int DataColor = 0x303030;//0xffffff;
const int GradientTopColor = 0xebfbff;//0x4270d8;//0xfacc88;
const int GradientBottomColor = 0xe5f6fe;//0x0546da; //0xfa8416;
const int SepLineColor = 0xa29595;//0xd5a512;
const int ShadowColor = 0;
const int BorderColor = 0x827575;
const float ShadowAlpha = 0.45;
const float ShadowWidth = 2;
const float ShadowHeight = 4;
const float ShadowSpread = 3;

- (id)initWithAvailFrameInContainer:(CGRect)availFrame withDataElementFrame:(CGRect)dataElementFrame data:(Word*)ipWord {
    self = [super initWithFrame:CGRectZero];
	if (self) {
        // Initialization code
		self.userInteractionEnabled = false;
		self.backgroundColor = [UIColor clearColor];	
		self.clipsToBounds = NO;
		
		mpWord = [ipWord retain];
		
		[self createToolTip];
		CGSize tooltipSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
		self.frame = [TooltipView adjustedTooltipFrameWithTooltipSize:tooltipSize availFrameInContainer:availFrame withDataElementFrame:dataElementFrame];
	}	
	return self;			
}
/*!
 adjust tooltip position
 those frame are in tooltip viewer's super view's coordinate system
*/
+ (CGRect)adjustedTooltipFrameWithTooltipSize:(CGSize)tooltipSize availFrameInContainer:(CGRect)availFrame withDataElementFrame:(CGRect)dataElementFrame
{
	CGRect lFrame = CGRectMake(0, 0, tooltipSize.width, tooltipSize.height);
	//
	const int kMinPadding = 20; // padding between tooltip and the data element
	const int kBorderPadding = 3; // padding between the tooltip and the container's border
	/*
	*/
	CGRect elementFrameInAvailFrame = CGRectIntersection(availFrame, dataElementFrame);
	elementFrameInAvailFrame.origin.x -= availFrame.origin.x;
	elementFrameInAvailFrame.origin.y -= availFrame.origin.y;
    
	if (elementFrameInAvailFrame.origin.x < 0 || elementFrameInAvailFrame.origin.y < 0) {
		return CGRectZero;
	}
	//priority: top >right > left > bottom
	//
	int lTopY = elementFrameInAvailFrame.origin.y-kMinPadding-lFrame.size.height;
	int lTopSpace = lTopY;
	//
	int lRightPosX = elementFrameInAvailFrame.origin.x+elementFrameInAvailFrame.size.width+kMinPadding;
	int lRightSpace = availFrame.size.width - lRightPosX -lFrame.size.width;
	int lLeftPosX = elementFrameInAvailFrame.origin.x-kMinPadding-lFrame.size.width;
	int lLeftSpace = lLeftPosX;
	
	int lBottomY = elementFrameInAvailFrame.origin.y+elementFrameInAvailFrame.size.height+kMinPadding;
	int lBottomSpace = availFrame.size.height-lBottomY-lFrame.size.height;
	
	if (lTopSpace > 0) {
		lFrame.origin.y = lTopY;
		//
		//note since in vertical direction we have enough padding
		//we don't consider padding here
		
		//PM want us to show the tooltip at the center of the element
		int rightPosX = elementFrameInAvailFrame.origin.x + elementFrameInAvailFrame.size.width/2;
		int rightSpace = availFrame.size.width-(rightPosX+lFrame.size.width);
		if (rightSpace > 0) {
			lFrame.origin.x = rightPosX;
		}
		else{
			//move it to the left a bit
			rightPosX += rightSpace;
			lFrame.origin.x = rightPosX;

		}
	}
	else if((lRightSpace > 0) || (lLeftSpace > 0)) {
		
		if(lRightSpace > 0){
		   lFrame.origin.x = lRightPosX;
		}
		else{
		   lFrame.origin.x = lLeftPosX;	
		}
		//
		//note:
		//a. here we don't consider the min padding
		//b. put the tooltip as higher as we I can -- PM: George
		
		//since when we reach here, there are not enough space in top direction
		//I think below code is safe
		lFrame.origin.y = kBorderPadding;
	
	}
	else if(lBottomSpace > 0){
		
		lFrame.origin.y = lBottomY;
		//TODO: duplicate code with top case
		//
		//note since in vertical direction we have enough padding
		//we don't consider padding here
		
		int lTempRightSpace = availFrame.size.width-(elementFrameInAvailFrame.origin.x+lFrame.size.width);
		if (lTempRightSpace > 0) {
			lFrame.origin.x = elementFrameInAvailFrame.origin.x;
		}
		else{
			int lTempX = elementFrameInAvailFrame.origin.x+lTempRightSpace;
			lFrame.origin.x = lTempX;
		}		
	}
	else{//no where to place
		
		if (lRightSpace > lLeftSpace) {//
			lFrame.origin.x = availFrame.size.width-lFrame.size.width-kBorderPadding;
		}
		else{//
			
			lFrame.origin.x = kBorderPadding;
		}
		if (lTopSpace > lBottomSpace) {
			lFrame.origin.y = kBorderPadding;
		}
		else{
			lFrame.origin.y = availFrame.size.height-lFrame.size.height-kBorderPadding;
		}					
	}
	//
	lFrame.origin.x += availFrame.origin.x;
	lFrame.origin.y += availFrame.origin.y;
	//
    if (lFrame.origin.x < 0) {
		lFrame.origin.x = kBorderPadding;
	}
	if (lFrame.origin.y < 0) {
		lFrame.origin.y = kBorderPadding;
	}
	//
	return lFrame;	
}

- (void)createToolTip {
	if (!mpWord) {
		return;
	}
	
    NSMutableArray* lpDataProvider = [[NSMutableArray alloc] initWithCapacity:0];
    [lpDataProvider addObject:mpWord.mpWord];
    [lpDataProvider addObject:@""];
    @autoreleasepool {
        NSArray* lpWordChs = [mpWord.mpCn componentsSeparatedByString:@"#"];
        for (NSString* lpWordCh in lpWordChs) {
            if (lpWordCh.length > 0) {
                [lpDataProvider addObject:lpWordCh];
            }
        }
    }
	
	NSMutableArray* lpArrTitles = [[NSMutableArray alloc] initWithCapacity:lpDataProvider.count];
	//NSMutableArray* lpArrDatas = [[NSMutableArray alloc] initWithCapacity:lpDataProvider.count];
	
	CGFloat lTitleMaxWidth = 0;
	CGFloat lDataMaxWidth = 0;
	CGFloat lCurY = TopPadding;
	CGFloat lX = LeftPadding;
	
	mSepLineX = lX;
	mSepLines.clear();
	
	for (int i=0; i<lpDataProvider.count; ++i) {
        NSString* lpContent = (NSString*)[lpDataProvider objectAtIndex:i];
		if (lpContent.length == 0) {
			// separate line
			mSepLines.push_back(lCurY + SepLineTopPadding);
			
			// update lCurHeight;
			lCurY += SeparatorLineGap;
		}
		else {
		    /*
			 first round deal with the title labels, e.g. "Profit"
			 second round deal with the data labes, e.g. "$10.13"
			 */
			
			int maxHeightOfTitleAndData = -1;
			
		    //for (int j = 0; j < 2; j++) {
				
            //bool isTitle = (j == 0)?true:false;
            //
//            std::string content;
//            if(isTitle){
//                content = mDataProvider.at(i).first + ":";
//            }
//            else{
//                content = mDataProvider.at(i).second;
//                
//            }
            UILabel* label = [[UILabel alloc] init];
//            if (isTitle) {
            [lpArrTitles addObject:label];
//            }
//            else{
//                [lpArrDatas addObject:label];
//            }
            [self addSubview:label];
            [label release];
            //
            //NSString* labelStr = [NSString stringWithUTF8String:content.c_str()];
            UIFont* labelFont = [Global getCommonLightFont:TooltipFontSize];
            label.text = lpContent;
            label.font = labelFont;
            //if (isTitle) {
//            label.textColor = [ColorUtil colorFromInteger:LabelColor];
//            label.textAlignment = UITextAlignmentRight;
//            }
//            else{
            label.textColor = [ColorUtil colorFromInteger:DataColor];
            label.textAlignment = UITextAlignmentLeft;
//            }
            label.backgroundColor = [UIColor clearColor];
            //TQMS 497598: handle very long text  
            label.numberOfLines = 0;//means no limit
            label.lineBreakMode = UILineBreakModeWordWrap;
            CGSize labelOneLineSize = [lpContent sizeWithFont:labelFont];
            int fitHeight = labelOneLineSize.height;
            int fitWidth =  labelOneLineSize.width;
            //
            int frameHeight = -1;
            int frameWidth = -1;
            //
            if (fitWidth < MaxLabelWidth) {
                
                frameHeight = fitHeight;
                frameWidth = fitWidth;
            }
            else{
                
                frameWidth = MaxLabelWidth;
                
                //as PM's requirement,at most two lines
                const int kMaxNumberOfLine = 2;
                //there are no prove this value is optimal. it's a bit big 
                //however accoring to Apple's document,I think it's safe.
                const int kPaddingBetweenLine = 10;
                int heightLimit = kMaxNumberOfLine * fitHeight + (kMaxNumberOfLine - 1) * kPaddingBetweenLine;

                CGSize constrainedSize = CGSizeMake(frameWidth, heightLimit);
                
                CGSize labelWrapSize = [lpContent sizeWithFont:labelFont constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];

                int wrappedHeight = labelWrapSize.height;
                /*
                 */
                if (wrappedHeight > heightLimit) {
                    frameHeight = heightLimit;
                }
                else{
                    frameHeight = wrappedHeight;
                }
            }
            if (maxHeightOfTitleAndData < frameHeight) {
                maxHeightOfTitleAndData = frameHeight;
            }
            //if (isTitle) {
            if (lTitleMaxWidth < frameWidth) {
                lTitleMaxWidth = frameWidth;
            }
            //}
            //else{
            //    if (lDataMaxWidth < frameWidth) {
            //        lDataMaxWidth = frameWidth;
            //    }
           // }
            /*
             for title width will be reset later
             for data x and width will be reset later.
             */
            label.frame = CGRectMake(lX, lCurY, frameWidth, frameHeight);	
			//}
			lCurY += maxHeightOfTitleAndData;
		}
	}
    
    [lpDataProvider release];
	
	if (lTitleMaxWidth > MaxLabelWidth) {
		lTitleMaxWidth = MaxLabelWidth;
	}
    // reset width
	for (int i = 0; i < [lpArrTitles count]; ++i) {
	   
		UILabel* lpLblTitle = [lpArrTitles objectAtIndex:i];
		lpLblTitle.frame = CGRectMake(lpLblTitle.frame.origin.x, lpLblTitle.frame.origin.y, lTitleMaxWidth, lpLblTitle.frame.size.height);
	}
	
	if (lDataMaxWidth > MaxLabelWidth) {
		lDataMaxWidth = MaxLabelWidth;
	}
	// reset x and width
	lX += lTitleMaxWidth + LabelGap;
//	for (int i = 0; i < [lpArrDatas count]; ++i) {
//		UILabel* lpLblData = [lpArrDatas objectAtIndex:i];
//		lpLblData.frame = CGRectMake(lX, lpLblData.frame.origin.y, lDataMaxWidth, lpLblData.frame.size.height);
//	}
	
	// lenth of separate lines.
	mSepLineLen = lTitleMaxWidth + lDataMaxWidth + LabelGap;
	
	float lBorderWith = OuterBorderWidth + InnerBorderWidth + ShadowWidth + ShadowSpread;
	float lBorderHeight = OuterBorderWidth + InnerBorderWidth + ShadowHeight + ShadowSpread;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, LeftPadding + mSepLineLen + RightPadding + lBorderWith, lCurY + BottomPadding + lBorderHeight);
	
	[lpArrTitles release];
	//[lpArrDatas release];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// draw gradient background with border
	[self drawBackGroundWithContext:rect context:ctx];
	
	// draw separate lines
	CGContextSetLineWidth(ctx, 1);
	CGContextSetStrokeColorWithColor(ctx, [[ColorUtil colorFromInteger:SepLineColor] CGColor]);
	CGContextBeginPath(ctx);
	for (int i=0; i<mSepLines.size(); ++i) {
		CGContextMoveToPoint(ctx, mSepLineX, int(mSepLines.at(i)) + 0.5);
		CGContextAddLineToPoint(ctx, mSepLineX + mSepLineLen, int(mSepLines.at(i)) + 0.5);
	}
	CGContextStrokePath(ctx);
}

- (void)drawBackGroundWithContext:(CGRect)rect context:(CGContextRef)ctx {
	CGContextSaveGState(ctx);
	//outer border: round corner and drop shadow
	// inner border is drawn when filling the rect with white color.
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextSetLineWidth(ctx, OuterBorderWidth);
	float r, g, b;
	[ColorUtil intToRGB2:BorderColor withRed:&r andGreen:&g andBlue:&b];
	CGContextSetRGBStrokeColor(ctx, r, g, b, 1.0);
	// drop shadow
	CGContextSetShadowWithColor(ctx, CGSizeMake(ShadowWidth, ShadowHeight), ShadowSpread, [[[ColorUtil colorFromInteger:ShadowColor] colorWithAlphaComponent:ShadowAlpha] CGColor]);
	// draw outer border with shadow
	CGRect lOuterBorderRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - ShadowWidth - ShadowSpread, rect.size.height - ShadowHeight - ShadowSpread);
	CGMutablePathRef lOuterBorderPath = [self createBorderPathFromRect:lOuterBorderRect];
	CGContextBeginPath(ctx);
	CGContextAddPath(ctx, lOuterBorderPath);
	// in flex ive gm, no need to draw the outer border stroke, keep the same in ipad
	CGContextDrawPath(ctx, kCGPathFill);
	//CGContextDrawPath(ctx, kCGPathFillStroke);
	CGPathRelease(lOuterBorderPath);
	
	//end drop shadow
	CGContextSetShadowWithColor(ctx,CGSizeZero,1.0,NULL);
	
	// clip inner border
	float lBorderWidth = InnerBorderWidth;//OuterBorderWidth + InnerBorderWidth; // no outer border now
	CGRect lInnerBorderRect = CGRectMake(lOuterBorderRect.origin.x + lBorderWidth, lOuterBorderRect.origin.y + lBorderWidth, 
										 lOuterBorderRect.size.width - lBorderWidth * 2, lOuterBorderRect.size.height - lBorderWidth * 2);
	CGMutablePathRef lInnerBorderPath = [self createBorderPathFromRect:lInnerBorderRect];
	CGContextBeginPath(ctx);
	CGContextAddPath(ctx, lInnerBorderPath);
	CGContextClip(ctx);
	CGPathRelease(lInnerBorderPath);
	
	// draw background gradient colors.
	float redLight, greenLight, blueLight;
	[ColorUtil intToRGB2:GradientTopColor withRed:&redLight andGreen:&greenLight andBlue:&blueLight];
	
	float redDark, greenDark, blueDark;
	[ColorUtil intToRGB2:GradientBottomColor withRed:&redDark andGreen:&greenDark andBlue:&blueDark];
	
	CGColorSpaceRef gradientColorSpace=CGColorSpaceCreateDeviceRGB();
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = {redLight, greenLight, blueLight, 1.0, redDark, greenDark, blueDark,1.0};
	CGGradientRef myGradient = CGGradientCreateWithColorComponents(gradientColorSpace, components, locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint = CGPointMake(lInnerBorderRect.origin.x, lInnerBorderRect.origin.y);
	myEndPoint.x = myStartPoint.x;
	myEndPoint.y = lInnerBorderRect.origin.y + lInnerBorderRect.size.height;
	CGContextDrawLinearGradient(ctx, myGradient, myStartPoint, myEndPoint, 0);	
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(gradientColorSpace);
	
	CGContextRestoreGState(ctx);
}

- (CGMutablePathRef)createBorderPathFromRect:(CGRect)rect {
	CGPoint leftTop = rect.origin;
	CGPoint rightTop = CGPointMake(CGRectGetMaxX(rect), leftTop.y);
	CGPoint leftBottom = CGPointMake(leftTop.x, CGRectGetMaxY(rect));
	CGPoint rightBottom = CGPointMake(rightTop.x, leftBottom.y);
	
	CGMutablePathRef lPath = CGPathCreateMutable();
	CGPathMoveToPoint(lPath, NULL, leftTop.x,leftTop.y+CornerRadius);
	
	CGPathAddArc(lPath, NULL, leftTop.x+CornerRadius,leftTop.y+CornerRadius, CornerRadius,M_PI,1.5*M_PI,0);
	CGPathAddLineToPoint(lPath, NULL, rightTop.x-CornerRadius, rightTop.y);
	
	CGPathAddArc(lPath, NULL, rightTop.x-CornerRadius,rightTop.y+CornerRadius, CornerRadius,1.5*M_PI,0, 0);
	
	CGPathAddLineToPoint(lPath, NULL, rightBottom.x, rightBottom.y-CornerRadius);
	CGPathAddArc(lPath, NULL, rightBottom.x-CornerRadius,rightBottom.y-CornerRadius, CornerRadius,0,M_PI_2, 0);
	
	CGPathAddLineToPoint(lPath, NULL, leftBottom.x+CornerRadius, leftBottom.y);
	CGPathAddArc(lPath, NULL, leftBottom.x+CornerRadius,leftBottom.y-CornerRadius,CornerRadius,M_PI_2,M_PI, 0);
	
	CGPathCloseSubpath(lPath);

	return lPath;
}

- (void)fadeOut {
	UIView* lpImageView = [self.subviews objectAtIndex:0];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[lpImageView setAlpha:0];
	[self setAlpha:0];
	[UIView commitAnimations];
}

- (void)dealloc {
    [mpWord release];
    [super dealloc];
}

@end
