//
//  ColorUtil.h
//  tcidsd
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class Pixel {
public:
    Byte r;
    Byte g;
    Byte b;
    Byte a;
public:
    Pixel(Byte ir, Byte ig, Byte ib, Byte ia) : r(ir), g(ig), b(ib), a(ia) {}
    Pixel() : r(0), g(0), b(0), a(0) {}
};

@interface ColorUtil : NSObject

// it should be invoked before is* methods.
+ (void)initStdColors;

+ (BOOL)isBgGray:(const Pixel&)iPixel;
+ (BOOL)isBgBlueGreenRed:(const Pixel&)iPixel;
+ (BOOL)isCharWhite:(const Pixel&)iPixel;

+ (Pixel)makePixelWithRGBA:(Byte)r g:(Byte)g b:(Byte)b a:(Byte)a;
+ (Pixel)makePixelWithInt:(int)iColor;

+ (float)inchesToPixles:(float)iInches;
+ (float)pixelsToInches:(float)iPixels;
+ (float)pointsToPixles:(float)iPoints;
+ (bool)stringToRGB:(NSString*)ipString withRed:(float*)opRed andGreen:(float*)opGreen andBlue:(float*)opBlue;
+ (int)hexStringToInt:(NSString*)ipString;

+ (int)intFromBGRToRGB: (int)iValue;
//+ (void)intToRGB: (int)iValue withRed:(float*)opRed andGreen:(float*)opGreen andBlue:(float*)opBlue;
+ (UIColor*)colorFromInteger:(NSInteger)iValue;
// please be noted the color info is saved as BGR instead of RGB in the grid and CE
+ (UIColor*)colorFromInteger:(NSInteger)iValue rgbReversed:(BOOL)iIsRGBReversed;

// iR, iG, iB, *opH, *opS, *opV are all in [0, 1].
+ (void)rgbToHsv:(float)iR withG:(float)iG andB:(float)iB andH:(float*)opH andS:(float*)opS andV:(float*)opV;
// iH, iS, iV, *opR, *opG, *opB are all in [0, 1].
+ (void)hsvToRgb:(float)iH withS:(float)iS andV:(float)iV andR:(float*)opR andG:(float*)opG andB:(float*)opB;
+ (BOOL)colorIsBright:(int)redComp withGreen:(int)greenComp withBlue:(int)blueComp;
+ (int)colorAdjust:(int)oriColor withDarker:(BOOL) isDarker; 
+ (int)getCalculatedGradient:(int)oriColor;
+ (void)intToRGB2:(int)iValue withRed:(float*)opRed andGreen:(float*)opGreen andBlue:(float*)opBlue;
+ (void)colorToRgb:(UIColor*)ipColor withR:(float*)opR andG:(float*)opG andB:(float*)opB;
+ (NSInteger)getContrastColor:(NSInteger)iGivenColor;
+ (NSInteger)darkerHex:(NSInteger)hex percentage:(CGFloat)prc;
+ (NSInteger)getColorInGradientRange:(float)index startColor:(NSInteger)iStartColor endColor:(NSInteger)iEndColor;
+ (int)colorAdjust:(int)oriColor withVFactor:(float)vFactor;

+ (UIImage*)newImage:(NSString*)ipImgFileName;

@end
