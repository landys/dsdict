//
//  DictUtil.h
//  tcidsd
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DictUtil : NSObject

+ (BOOL)isIPad;
+ (BOOL)isIOS5orLater;
// en: english, zh-Hans: simplified chinese, zh-Hant: tranditional chinese, ja: japanese...
+ (NSString*)getPreferredLanguage;
+ (BOOL)isChinesePreferred;

+ (BOOL)stringInCharSet:(NSString*)ipStr charSet:(NSCharacterSet*)ipCharSet;

+ (CGRect)resizeFrame:(CGRect)iFrame widthRatio:(float)iWidthRatio heightRatio:(float)iHeightRatio;

+ (int)compCGFloat:(CGFloat)iLeft right:(CGFloat)iRight;
+ (CGFloat)getTextSizeByUILabel:(NSString*)ipString withFontSize:(float)iFontSize withFontName:(NSString*)ipFontName;
+ (CGSize)getTextWidthHeightByUILabel:(NSString*)ipString withFontSize:(float)iFontSize withFontName:(NSString*)ipFontName;
@end
