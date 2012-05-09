//
//  DictUtil.m
//  tcidsd
//
//  Created by Jinde Wang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictUtil.h"

@implementation DictUtil

+ (BOOL)isIPad {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isIOS5orLater {
    return ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending);
}

+ (NSString*)getPreferredLanguage {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
}

+ (BOOL)isChinesePreferred {
    NSString* lLanguage = [DictUtil getPreferredLanguage];
    return (lLanguage != nil && ([lLanguage compare:@"zh-Hans"] == NSOrderedSame || [lLanguage compare:@"zh-Hant"] == NSOrderedSame));
}

+ (BOOL)stringInCharSet:(NSString*)ipStr charSet:(NSCharacterSet*)ipCharSet {
    if (ipStr == nil) return YES;
    if (ipCharSet == nil) return NO;
    
    for (int i=0; i<ipStr.length; ++i) {
        if (![ipCharSet characterIsMember:[ipStr characterAtIndex:i]]) {
            return NO;
        }
    }
    
    return YES;
}

+ (CGRect)resizeFrame:(CGRect)iFrame widthRatio:(float)iWidthRatio heightRatio:(float)iHeightRatio {
    return CGRectMake(roundf(iFrame.origin.x * iWidthRatio), roundf(iFrame.origin.y * iHeightRatio), roundf(iFrame.size.width * iWidthRatio), roundf(iFrame.size.height * iHeightRatio));
}

+ (int)compCGFloat:(CGFloat)iLeft right:(CGFloat)iRight
{
	if (fabs(iLeft - iRight) < FLT_EPSILON)
	{
		return 0;
	}
	
	return iLeft > iRight ? 1 : -1;
}

+ (CGFloat)getTextSizeByUILabel:(NSString*)ipString withFontSize:(float)iFontSize withFontName:(NSString*)ipFontName{
	UILabel* lpLabelTemp = [[UILabel alloc] init];
	lpLabelTemp.text = ipString;
	lpLabelTemp.font= [UIFont fontWithName:ipFontName size:iFontSize];
	CGSize lCurSize = [lpLabelTemp sizeThatFits:CGSizeZero];
	[lpLabelTemp release];
	return lCurSize.width;
}

+ (CGSize)getTextWidthHeightByUILabel:(NSString*)ipString withFontSize:(float)iFontSize withFontName:(NSString*)ipFontName{
	UILabel* lpLabelTemp = [[UILabel alloc] init];
	lpLabelTemp.text = ipString;
	lpLabelTemp.font= [UIFont fontWithName:ipFontName size:iFontSize];
	CGSize lCurSize = [lpLabelTemp sizeThatFits:CGSizeZero];
	[lpLabelTemp release];
	return lCurSize;
}

@end
