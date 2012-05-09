//
//  Global.h
//  tcidsd
//
//  Created by Jinde Wang on 15/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingManager.h"

// This defined value should not be changed in the later app versions.
//#define LANGUAGE_ENGLISH @"en"
#define LANGUAGE_CHINESE @"cn"
#define LANGUAGE_NONE @"none"

@interface Global : NSObject

+ (void)initGlobalValues;
+ (void)releaseGlobalValues;

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

//+ (UIActivityIndicatorView*)getIndicatorView;

+ (void)showWaitView:(UIView*)ipParentView text:(NSString*)ipText;
+ (void)hideWaitView;

@end
