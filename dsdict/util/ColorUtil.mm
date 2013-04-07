//
//  ColorUtil.m
//  dsdict
//
//  Created by Jinde Wang on 31/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorUtil.h"
#import <math.h>

#define CHAR_WHITE 0xffffff
#define BG_GRAY 0xf5f5f5
#define BG_GREEN 0x50cb50
#define BG_RED 0xd45b5e
#define BG_BLUE 0x50cef8

#define COLOR_TH 30
#define WHITE_COLOR_TH 10

static float sRatio = 1.0;

static Pixel StdCharWhite;
static Pixel StdBgGray;
static Pixel StdBgGreen;
static Pixel StdBgRed;
static Pixel StdBgBlue;

@interface ColorUtil (Private)

+ (BOOL)isColor:(const Pixel&)iPixel color:(const Pixel&)iStdPixel;
+ (BOOL)isColor:(const Pixel&)iPixel color:(const Pixel&)iStdPixel threshold:(float)iThreshold;

@end

@implementation ColorUtil

+ (void)initStdColors {
    StdCharWhite = [ColorUtil makePixelWithInt:CHAR_WHITE];
    StdBgGray = [ColorUtil makePixelWithInt:BG_GRAY];
    StdBgGreen = [ColorUtil makePixelWithInt:BG_GREEN];
    StdBgBlue = [ColorUtil makePixelWithInt:BG_RED];
    StdBgRed = [ColorUtil makePixelWithInt:BG_BLUE];
}

+ (BOOL)isColor:(const Pixel&)iPixel color:(const Pixel&)iStdPixel {
    return (abs(iPixel.r - iStdPixel.r) + abs(iPixel.g - iStdPixel.g) + abs(iPixel.b - iStdPixel.b) <= COLOR_TH);
}

+ (BOOL)isColor:(const Pixel&)iPixel color:(const Pixel&)iStdPixel threshold:(float)iThreshold {
    return (abs(iPixel.r - iStdPixel.r) + abs(iPixel.g - iStdPixel.g) + abs(iPixel.b - iStdPixel.b) <= iThreshold);
}

+ (BOOL)isBgGray:(const Pixel&)iPixel {
    return [ColorUtil isColor:iPixel color:StdBgGray];
}

+ (BOOL)isBgBlueGreenRed:(const Pixel&)iPixel {
    return ([ColorUtil isColor:iPixel color:StdBgBlue] || [ColorUtil isColor:iPixel color:StdBgGreen] || [ColorUtil isColor:iPixel color:StdBgRed]);
}

+ (BOOL)isCharWhite:(const Pixel&)iPixel {
    return [ColorUtil isColor:iPixel color:StdCharWhite threshold:WHITE_COLOR_TH];
}

+ (Pixel)makePixelWithRGBA:(Byte)r g:(Byte)g b:(Byte)b a:(Byte)a {
    return Pixel(r, g, b, a);
}

// i.e. 0xabcdef
+ (Pixel)makePixelWithInt:(int)iColor {
    return Pixel(((iColor >> 16) & 0xff), ((iColor >> 8) & 0xff), (iColor & 0xff), 1);
}

+ (float)inchesToPixles:(float)iInches {
	// from apple document, 1024-by-768-pixel resolution at 132 pixels per inch (ppi)
	// But in order to make the pixel alignment consistent with flex document, use 96 here.
	//return floor(iInches * 96.0f + 0.5);
	return floor(iInches * 96.0f * sRatio + 0.5);
	//return floor(iInches * 132.0f + 0.5);
}

+ (float)pixelsToInches:(float)iPixels {
	// from apple document, 1024-by-768-pixel resolution at 132 pixels per inch (ppi)
	// But in order to make the pixel alignment consistent with flex document, use 96 here.
	return iPixels/96.0f;
}

+ (float)pointsToPixles:(float)iPoints {
	// Use flex logic to convert point to pixel
	//return floor(iPoints * 96.0f / 72.0f + 0.5);
	return floor(iPoints * 132.0f / 96.0f * sRatio + 0.5);
}

+ (bool)stringToRGB:(NSString*)ipString withRed:(float*)opRed andGreen:(float*)opGreen andBlue:(float*)opBlue {
	//the pattern is like "FFFFFF"
	//int lLength = ipString->length();
	
	int lValue = [ipString intValue];
    
	*opRed = (lValue & 0x000000FF) / 255.0f;
	*opGreen = ((lValue & 0x0000FF00) >> 8) / 255.0f;
	*opBlue = ((lValue & 0x00FF0000) >> 16) / 255.0f;
	
	return true;
}

+ (int)hexStringToInt:(NSString*)ipString {
    
	//the pattern is like "0xFFFFFF"
	//ignore the first two chars
	int lLength = [ipString length];
	if (lLength < 2) {
		if (lLength == 1) {
			if (([ipString characterAtIndex:0] >= '0') && ([ipString characterAtIndex:0] <= '9')) {
				return [ipString intValue];
			}
		}
		assert(false);
	}
	//also support the transformation of decimal, since in some cases, we can not distinguish which type the string is of.
	if (([ipString characterAtIndex:1] != 'x') && ([ipString characterAtIndex:1] != 'X')) {
		return [ipString intValue];
	}
	int lValue = 0;
	for (int i = lLength - 1, j = 1; i > 1; --i, j *= 16) {
		if (([ipString characterAtIndex:i] >= '0') && ([ipString characterAtIndex:i] <= '9')) {
			lValue += j * ([ipString characterAtIndex:i] - '0');
		}
		else if (([ipString characterAtIndex:i] >= 'A') && ([ipString characterAtIndex:i] <= 'F')) {
			lValue += j * ([ipString characterAtIndex:i] - 'A' + 10);
		}
		else if (([ipString characterAtIndex:i] >= 'a') && ([ipString characterAtIndex:i] <= 'f')) {
			lValue += j * ([ipString characterAtIndex:i] - 'a' + 10);
		}
		else {   
			return -1;
		}		
	}
	return lValue;
}

+ (int)intFromBGRToRGB:(int)iValue {
	//the color inherited from web is gbr form, so need to transfrom it to rgb form
	int bValue = iValue & 0x0000FF;
	int gValue = (iValue & 0x00FF00) >> 8;
	int rValue = (iValue & 0xFF0000) >> 16;
	return rValue + gValue*0x100 + bValue*0x10000;
	
}

//+ (void)intToRGB:(int)iValue withRed:(float*)opRed andGreen:(float*)opGreen andBlue:(float*)opBlue
//{
//	
//	*opRed = (iValue & 0x000000FF) / 255.0f;
//	*opGreen = ((iValue & 0x0000FF00) >> 8) / 255.0f;
//	*opBlue = ((iValue & 0x00FF0000) >> 16) / 255.0f;
//}

+ (UIColor*)colorFromInteger:(NSInteger)iValue {
    CGFloat lBScale = (iValue & 0xff) / 255.0f;
    iValue >>= 8;
	
    CGFloat lGScale = (iValue & 0xff) / 255.0f;
    iValue >>= 8;
	
    CGFloat lRScale = (iValue & 0xff) / 255.0f;
    iValue >>= 8;
	
    return [UIColor colorWithRed:lRScale green:lGScale blue:lBScale alpha:1.0f];
}

+ (UIColor*)colorFromInteger:(NSInteger)iValue rgbReversed:(BOOL)iIsRGBReversed {
    CGFloat lRScale = (iValue & 0xff) / 255.0f;
    iValue >>= 8;
	
    CGFloat lGScale = (iValue & 0xff) / 255.0f;
    iValue >>= 8;
	
    CGFloat lBScale = (iValue & 0xff) / 255.0f;
    iValue >>= 8;
	
    return [UIColor colorWithRed:lRScale green:lGScale blue:lBScale alpha:1.0f];
}

+ (void)rgbToHsv:(float)iR withG:(float)iG andB:(float)iB andH:(float*)opH andS:(float*)opS andV:(float*)opV;
{
	float lR = iR * 255.f;
	float lG = iG * 255.f;
	float lB = iB * 255.f;
	float lMax = MAX(lR, MAX(lG, lB));
	float lMin = MIN(lR, MIN(lG, lB));
	float lDelta = lMax - lMin;
	float lH = 0.f;
	float lS = 0.f;
	float lV = lMax;
	
	if (lMax != 0) {
		lS = 255.f * lDelta / lMax;
	}
	else {		
		lS = 0.f;
	}
	
	if (lS == 0.f) {
		lH = -1.f;
		
	} 
	else {
		if (lR == lMax) {
			lH =  (lG - lB) / lDelta;
		}
		else if (lG == lMax) {
			lH = 2.f + (lB - lR) / lDelta;
		} 
		else {
			lH = 4.f + (lR - lG) / lDelta;
		}
	}
	
	lH = lH * 60.f;
	
	if (lH < 0.f) {
		lH = lH + 360.f;
	}
	
	lH = (((int)lH) % 360) / 360.f;
	lS = lS / 255.f;
	lV = lV / 255.f;
	
	*opH = lH;
	*opS = (lS > 1.f) ? 1.f : lS;
	*opV = (lV > 1.f) ? 1.f : lV;
}

+ (void)hsvToRgb:(float)iH withS:(float)iS andV:(float)iV andR:(float*)opR andG:(float*)opG andB:(float*)opB {
	float lR = 0.f;
	float lG = 0.f;
	float lB = 0.f;
	
	float lH = iH;
	float lS = iS;
	float lV = (int)(iV * 255.f);
	if (iS == 0.f) {
		lR = lG = lB = lV;
	}
	else {
		lH *= 6.f;
		int lI = (int)lH;
		float lF = lH - lI;
		int lP = (int)(lV * (1.f - lS));
		int lQ = (int)(lV * (1.f - (lS * lF)));
		int lT = (int)(lV * (1.f - (lS * (1.f - lF))));
		
		switch (lI) {
			case 0:
				lR = lV;
				lG = lT;
				lB = lP;
				break;
			case 1:
				lR = lQ;
				lG = lV;
				lB = lP;
				break;
			case 2:
				lR = lP;
				lG = lV;
				lB = lT;
				break;
			case 3:
				lR = lP;
				lG = lQ;
				lB = lV;
				break;
			case 4:
				lR = lT;
				lG = lP;
				lB = lV;
				break;
			case 5:
				lR = lV;
				lG = lP;
				lB = lQ;
				break;
		}
	}
	
	*opR = lR / 255.f;
	*opG = lG / 255.f;
	*opB = lB / 255.f;
}



+ (BOOL)colorIsBright:(int)redComp withGreen:(int)greenComp withBlue:(int)blueComp {
	int brightness = (redComp * 299 + greenComp * 587 + blueComp * 114) / 1000;
	if (brightness > 150) {
		return YES;
	}
	else {
		return NO;
	}
}

+ (int)colorAdjust:(int)oriColor withDarker:(BOOL)isDarker {
	float red, green, blue, destRed,destGreen,destBlue;
	float opH, opS, opV;
	[ColorUtil intToRGB2: oriColor withRed:&red andGreen:&green andBlue:&blue];
	[ColorUtil rgbToHsv:red withG:green andB:blue andH:&opH andS:&opS andV:&opV];
	if (isDarker) {
		opV*=0.9;
	}
	else {
		opV*=1.1;
		if (opV>1) {
			opV=1;
		}
	}
	
	[self hsvToRgb:opH withS:opS andV:opV andR:&destRed andG:&destGreen andB:&destBlue];
	int destColor=0;
	destColor+=((int)(destRed*255))<<16;
	destColor+=((int)(destGreen*255))<<8;
	destColor+=(int)(destBlue*255);
	return destColor;
    
}

+ (int)getCalculatedGradient:(int)oriColor {
	float red, green, blue, destRed,destGreen,destBlue;
	float opH, opS, opV;
	[ColorUtil intToRGB2: oriColor withRed:&red andGreen:&green andBlue:&blue];
	[ColorUtil rgbToHsv:red withG:green andB:blue andH:&opH andS:&opS andV:&opV];
	opV*=0.7;
	[self hsvToRgb:opH withS:opS andV:opV andR:&destRed andG:&destGreen andB:&destBlue];
	int destColor=0;
	destColor+=((int)(destRed*255))<<16;
	destColor+=((int)(destGreen*255))<<8;
	destColor+=(int)(destBlue*255);
	return destColor;	
}

+ (void)intToRGB2:(int)iValue withRed:(float*)opRed andGreen:(float*)opGreen andBlue:(float*)opBlue {
	* opBlue= (iValue & 0x000000FF) / 255.0f;
	*opGreen = ((iValue & 0x0000FF00) >> 8) / 255.0f;
	* opRed= ((iValue & 0x00FF0000) >> 16) / 255.0f;
}

+ (void)colorToRgb:(UIColor*)ipColor withR:(float*)opR andG:(float*)opG andB:(float*)opB {
	float lR = 0.f;
	float lG = 0.f;
	float lB = 0.f;
	if (ipColor && CGColorGetNumberOfComponents(ipColor.CGColor) >= 3) {
		const CGFloat* lColorComps = CGColorGetComponents(ipColor.CGColor);
		lR = lColorComps[0];
		lG = lColorComps[1];
		lB = lColorComps[2];
	}
	
	*opR = lR;
	*opG = lG;
	*opB = lB;
}

+ (NSInteger)getColorInGradientRange:(float)index startColor:(NSInteger)iStartColor endColor:(NSInteger)iEndColor {
	int i;
	if (index < 0 || index > 1){   //index out of range
	    return 0x000000;   //pass black color indicating failure
	}
	
	int range = 256;
	i = index * range;  //convert the percent index into a value between 0 to 255 
	
	int r, g, b;
	int sR = iStartColor>>16;
	int eR = iEndColor>>16;
	int sG = (iStartColor & 0x00FF00) >> 8;
	int eG = (iEndColor & 0x00FF00) >>8;
	int sB = (iStartColor & 0x0000FF);
	int eB = (iEndColor & 0x0000FF);
	//now compute the color value using our formula
	r = sR + ( i * ( eR - sR ) / range );
	g = sG + ( i * ( eG - sG ) / range );
	b = sB + ( i * ( eB - sB ) / range );
	
	return b + g*0x100 + r*0x10000;	
}


+ (NSInteger)getContrastColor:(NSInteger)iGivenColor {
	int r = iGivenColor>>16;
	int g = (iGivenColor & 0x00FF00) >> 8;
	int b = (iGivenColor & 0x0000FF);
	
	if([ColorUtil colorIsBright:r withGreen:g withBlue:b]) {
		return 0x000000; //use black
	}
	else {
		
		return 0xffffff;  //use white
	}
}

+ (NSInteger)darkerHex:(NSInteger)hex percentage:(CGFloat)prc {
	int r = hex>>16;
	int g = (hex & 0x00FF00) >> 8;
	int b = (hex & 0x0000FF);
	
	r = floor((1-prc) * r);	
	g = floor((1-prc) * g);
	b = floor((1-prc) * b);
	
	return b + g*0x100 + r*0x10000;		
}

+ (int)colorAdjust:(int)oriColor withVFactor:(float)vFactor {
	float red, green, blue, destRed,destGreen,destBlue;
	float opH, opS, opV;
	[ColorUtil intToRGB2: oriColor withRed:&red andGreen:&green andBlue:&blue];
	[ColorUtil rgbToHsv:red withG:green andB:blue andH:&opH andS:&opS andV:&opV];
	
	opV *= vFactor;
	
	if (opV > 1) {
		opV = 1;
	}
	else if (opV < 0) {
		opV = 0;
	}
	
	[self hsvToRgb:opH withS:opS andV:opV andR:&destRed andG:&destGreen andB:&destBlue];
	int destColor = 0;
	destColor += ((int)(destRed*255)) << 16;
	destColor += ((int)(destGreen*255)) << 8;
	destColor += (int)(destBlue*255);
    
	return destColor;
}

+ (UIImage*)newImage:(NSString*)ipImgFileName {
    return [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ipImgFileName ofType:@""]];
}

@end
