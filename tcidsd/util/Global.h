//
//  Global.h
//  tcidsd
//
//  Created by Jinde Wang on 15/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingManager.h"

#if defined (FREE_VERSION)
#import "AdManager.h"
#endif

// This defined value should not be changed in the later app versions.
//#define LANGUAGE_ENGLISH @"en"
#define LANGUAGE_CHINESE @"cn"
#define LANGUAGE_NONE @"none"

@interface Global : NSObject

+ (void)initGlobalValues;
+ (void)releaseGlobalValues;

#if defined (FREE_VERSION)
+ (void)initAdManager:(UIView*)ipParentView rootViewController:(UIViewController*)ipRootViewController;
+ (AdManager*)getAdManager;
#endif

+ (NSArray*)getPriorityMap;
//+ (NSArray*)getLanguages;

//+ (SettingManager*)getGlobalSettingManager;
+ (NSString*)getLanguageSetting;
+ (void)setLanguageSetting:(NSString*)ipLangCode;
//+ (NSString*)parseLanguageCodeFromIndex:(int)iIndex;
//+ (int)parseIndexFromLanguageCode:(NSString*)ipLangCode;

+ (BOOL)isLanguageNone;

+ (BOOL)hasSuperPrivilege;
+ (void)saveSuperPrivilege;
+ (void)removeSuperPrivilege;
+ (NSString*)getPrivilegeKey;
+ (NSString*)getRemovePrivilegeKey;

+ (UIFont*)getCommonBoldFont:(int)iFontSize;
+ (UIFont*)getCommonFont:(int)iFontSize;
+ (UIFont*)getCommonLightFont:(int)iFontSize;

+ (UIColor*)getLightTextColor;
+ (UIColor*)getDarkTextColor;
+ (UIColor*)getTextBgColor;

+ (UIColor*)getHintInfoColor;
+ (UIColor*)getHintWarningColor;
+ (UIColor*)getHintErrorColor;

+ (NSCharacterSet*)getAlphaCharSet;
+ (NSCharacterSet*)getNumbersCharSet;

+ (NSString*)getRateUrl;
+ (NSString*)getUpgradeUrl;

//+ (UIActivityIndicatorView*)getIndicatorView;

+ (void)showWaitView:(UIView*)ipParentView text:(NSString*)ipText bgMask:(BOOL)iBgMask iconBgMask:(BOOL)iIconBgMask;
+ (void)hideWaitView;

@end
