//
//  ImageCore.h
//  dsdict
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorUtil.h"

@interface ImageCore : NSObject {
    CGSize mImgSize;
    Byte* mpPixels;
}

@property (nonatomic, readonly) Byte* mpPixels;
@property (nonatomic, readonly) CGSize mImgSize;

- (id)initWithUIImage:(UIImage*)ipImage;
- (Pixel)getPixelColor:(int)x y:(int)y;

+ (UIImage*)resizeImage:(UIImage*)iImage newRect:(CGRect)iNewRect;
+ (UIImage*)createGrayScaleImageFromImage:(UIImage*)image;

@end
