//
//  TooltipView.h
//  tcidsd
//
//  Created by Jinde Wang on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
#import <vector>


@interface TooltipView : UIView {
	Word* mpWord;
    // array of values of Y-axis to draw the line
	std::vector<float> mSepLines;
	float mSepLineLen;
	float mSepLineX;
}

//note avialFrame and dataElementFrame are frame  with this view's super view coordinate  
- (id)initWithAvailFrameInContainer:(CGRect)availFrame withDataElementFrame:(CGRect)dataElementFrame data:(Word*)ipWord;

- (void)fadeOut;

// adjust tooltip position
// those frame are in tooltip viewer's super view/container's coordinate system
// this method should be may to a  class and allow user to customize the paddint information for general usage
+ (CGRect)adjustedTooltipFrameWithTooltipSize:(CGSize)tooltipSize availFrameInContainer:(CGRect)availFrame withDataElementFrame:(CGRect)dataElementFrame;
@end
