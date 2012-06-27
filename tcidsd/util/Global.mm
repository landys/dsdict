//
//  Global.m
//  tcidsd
//
//  Created by Jinde Wang on 15/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "ColorUtil.h"
#import "DictUtil.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"
#import "WaitView.h"

#define LANGUAGE_KEY @"language"
#define PRIVILEGE_IDENTIFY @"identify"
#define PRIVILEGE_KEY @"WHOISJUNE"
#define REMOVE_PRIVILEGE_KEY @"WHOAREYOU"
//#define PRIVILEGE_KEY @"19880723"
//#define REMOVE_PRIVILEGE_KEY @"19850212"

#define GLOBAL_SETTING_PLIST @"settings.plist"

#define COMMON_FONT_NAME_LIGHT @"ChalkboardSE-Light"
#define COMMON_FONT_NAME_BOLD @"ChalkboardSE-Bold"
#define COMMON_FONT_NAME @"ChalkboardSE-Regular"

#define HINT_INFO_COLOR 0x101010
#define HINT_WARNING_COLOR 0xf8861c
#define HINT_ERROR_COLOR 0xff0000

#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define NUMBERS @"0123456789"
//#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
//#define NUMBERSPERIOD @"0123456789."
#if defined (FREE_VERSION)
// free version
//#define RATE_URL @"itms-apps://itunes.apple.com/us/app/domainsicle-domain-name-search/id521185012?ls=1&mt=8"
#define RATE_URL @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=521185012"
#define UPGRADE_URL @"http://itunes.apple.com/app/id530189788"
//#define RATE_URL_EN @"http://itunes.apple.com/app/id521185012"
//#define RATE_URL_CN @"http://itunes.apple.com/cn/app/id521185012"
//#define UPGRADE_URL_EN @"http://itunes.apple.com/app/id530189788"
//#define UPGRADE_URL_CN @"http://itunes.apple.com/cn/app/id530189788"
#define IS_SUPER NO
#else
// adless version
//#define RATE_URL @"itms-apps://itunes.apple.com/us/app/domainsicle-domain-name-search/id530189788?ls=1&mt=8"
#define RATE_URL @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=530189788"
#define UPGRADE_URL @""
//#define RATE_URL_EN @"http://itunes.apple.com/app/id530189788"
//#define RATE_URL_CN @"http://itunes.apple.com/cn/app/id530189788"
//#define UPGRADE_URL_EN @""
//#define UPGRADE_URL_CN @""
#define IS_SUPER YES
#endif

static SettingManager* gpSettingManager;
static NSArray* gpPriorityMap;
//static NSArray* gpLanguages;
static UIColor* gpLightTextColor;
static UIColor* gpDarkTextColor;
static UIColor* gpTextBgColor;

static UIColor* gpHintInfoColor;
static UIColor* gpHintWarningColor;
static UIColor* gpHintErrorColor;

static NSCharacterSet* gpAlphaSet;
static NSCharacterSet* gpNumbersSet;

//static UIActivityIndicatorView* gpIndicatorView;
static WaitView* gpWaitView;

@interface Global (Private)

+ (NSString*)generatePrivilegeIdentify;

@end

@implementation Global

+ (void)initGlobalValues {
    gpSettingManager = [[SettingManager alloc] initWithPListFile:GLOBAL_SETTING_PLIST];
    //gpLanguages = [[NSArray alloc] initWithObjects:@"Chinese Dict", @"English Dict", nil];
    
//    int lLangStatus = 0;
//    NSString* lpLanguageCode = [Global getLanguageSetting];
//    if (lpLanguageCode == nil) {
//        // the default language is read from the device reference.
//        if ([DictUtil isChinesePreferred]) {
//            [Global setLanguageSetting:LANGUAGE_CHINESE];
//            lLangStatus = 1;
//        }
//        else {
//            [Global setLanguageSetting:LANGUAGE_NONE];
//            lLangStatus = 0;
//        }
//    }
//    else {
//        lLangStatus = ([lpLanguageCode compare:LANGUAGE_NONE] == NSOrderedSame ? 0 : 1);
//    }
//    
//    if (lLangStatus == 1) {
//        gpPriorityMap = [[NSArray alloc] initWithObjects:@"罕见词", @"一般词", @"常用词", nil];
//    }
//    else {
    gpPriorityMap = [[NSArray alloc] initWithObjects:@"Rare Words", @"Normal Words", @"Common Words", @"Most Likely Words", nil];
//    }
    
    gpLightTextColor = [[UIColor whiteColor] retain];
    gpDarkTextColor = [[ColorUtil colorFromInteger:0x101010] retain];
    gpTextBgColor = [[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.9] retain];
    
    gpHintInfoColor = [[ColorUtil colorFromInteger:HINT_INFO_COLOR] retain];
    gpHintWarningColor = [[ColorUtil colorFromInteger:HINT_WARNING_COLOR] retain];
    gpHintErrorColor = [[ColorUtil colorFromInteger:HINT_ERROR_COLOR] retain];
    
    gpAlphaSet = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] retain];
    gpNumbersSet = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] retain];
    
    //gpIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    gpWaitView = [[WaitView alloc] initWithFrame:CGRectZero];
}

+ (void)releaseGlobalValues {
    [gpPriorityMap release];
    [gpSettingManager release];
    //[gpLanguages release];
    [gpLightTextColor release];
    [gpDarkTextColor release];
    [gpTextBgColor release];
    [gpHintInfoColor release];
    [gpHintWarningColor release];
    [gpHintErrorColor release];
    
    [gpAlphaSet release];
    [gpNumbersSet release];
    
    //[gpIndicatorView release];
    [gpWaitView release];
}

+ (NSArray*)getPriorityMap {
    return gpPriorityMap;
}

//+ (NSArray*)getLanguages {
//    return gpLanguages;
//}

//+ (SettingManager*)getGlobalSettingManager {
//    return gpSettingManager;
//}

+ (NSString*)getLanguageSetting {
    return [gpSettingManager getSetting:LANGUAGE_KEY];
}

+ (void)setLanguageSetting:(NSString*)ipLangCode {
    if (ipLangCode != nil) {
        [gpSettingManager setSetting:ipLangCode forKey:LANGUAGE_KEY];
    }
}

// according to gpLanguages.
//+ (NSString*)parseLanguageCodeFromIndex:(int)iIndex {
//    if (iIndex == 0) {
//        return LANGUAGE_CHINESE;
//    }
//    else if (iIndex == 1) {
//        return LANGUAGE_ENGLISH;
//    }
//    
//    return nil;
//}
//
//+ (int)parseIndexFromLanguageCode:(NSString*)ipLangCode {
//    if (ipLangCode == nil) return -1;
//    if ([ipLangCode compare:LANGUAGE_CHINESE] == NSOrderedSame) {
//        return 0;
//    }
//    else if ([ipLangCode compare:LANGUAGE_ENGLISH] == NSOrderedSame) {
//        return 1;
//    }
//    return -1;
//}

+ (BOOL)isLanguageNone {
    NSString* lpLanguageCode = [Global getLanguageSetting];
    return (lpLanguageCode != nil && [lpLanguageCode compare:LANGUAGE_NONE] == NSOrderedSame);
}

+ (NSString*)generatePrivilegeIdentify {
    NSString* lpDeviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (lpDeviceId != nil) {
        NSMutableString* lpRefineId = [NSMutableString stringWithString:PRIVILEGE_KEY];
        [lpRefineId insertString:lpDeviceId atIndex:lpRefineId.length / 2];
        return [lpRefineId stringFromMD5];
    }
    
    return nil;
}

+ (BOOL)isBornSuper {
    return IS_SUPER;
}

+ (BOOL)hasSuperPrivilege {
    if (IS_SUPER) return YES;
    
    BOOL isSuper = NO;
    @autoreleasepool {
        NSString* lpPrivilegeId = [Global generatePrivilegeIdentify];
        NSString* lpSavedPrivilegeId = [gpSettingManager getSetting:PRIVILEGE_IDENTIFY];
        isSuper = (lpPrivilegeId != nil && lpSavedPrivilegeId != nil && [lpPrivilegeId compare:lpSavedPrivilegeId] == NSOrderedSame);
    }
    
    return isSuper;
}

+ (void)saveSuperPrivilege {
    if (IS_SUPER) return;
    
    @autoreleasepool {
        NSString* lpPrivilegeId = [Global generatePrivilegeIdentify];
        if (lpPrivilegeId != nil) {
            [gpSettingManager setSetting:lpPrivilegeId forKey:PRIVILEGE_IDENTIFY];
        }
    }
}

+ (void)removeSuperPrivilege {
    if (IS_SUPER) return;
    
    if ([Global hasSuperPrivilege]) {
        [gpSettingManager setSetting:@"Thanks Guy~" forKey:PRIVILEGE_IDENTIFY];
    }
}

+ (NSString*)getRateUrl {
    return RATE_URL;
    //return ([DictUtil isChinesePreferred] ? RATE_URL_CN : RATE_URL_EN);
}

+ (NSString*)getUpgradeUrl {
    return UPGRADE_URL;
    //return ([DictUtil isChinesePreferred] ? UPGRADE_URL_CN : UPGRADE_URL_EN);
}

+ (NSString*)getPrivilegeKey {
    return PRIVILEGE_KEY;
}

+ (NSString*)getRemovePrivilegeKey {
    return REMOVE_PRIVILEGE_KEY;
}

+ (UIFont*)getCommonFont:(int)iFontSize {
    return [UIFont fontWithName:COMMON_FONT_NAME size:iFontSize];
}

+ (UIFont*)getCommonBoldFont:(int)iFontSize {
    return [UIFont fontWithName:COMMON_FONT_NAME_BOLD size:iFontSize];
}

+ (UIFont*)getCommonLightFont:(int)iFontSize {
    return [UIFont fontWithName:COMMON_FONT_NAME_LIGHT size:iFontSize];
}

+ (UIColor*)getLightTextColor {
    return gpLightTextColor;
}

+ (UIColor*)getDarkTextColor {
    return gpDarkTextColor;
}

+ (UIColor*)getTextBgColor {
    return gpTextBgColor;
}

+ (UIColor*)getHintInfoColor {
    return gpHintInfoColor;
}

+ (UIColor*)getHintWarningColor {
    return gpHintWarningColor;
}

+ (UIColor*)getHintErrorColor {
    return gpHintErrorColor;
}

+ (NSCharacterSet*)getAlphaCharSet {
    return gpAlphaSet;
}

+ (NSCharacterSet*)getNumbersCharSet {
    return gpNumbersSet;
}

//+ (UIActivityIndicatorView*)getIndicatorView {
//    return gpIndicatorView;
//}

+ (void)showWaitView:(UIView*)ipParentView text:(NSString *)ipText bgMask:(BOOL)iBgMask iconBgMask:(BOOL)iIconBgMask {
    [ipParentView addSubview:gpWaitView];
    gpWaitView.mBgMask = iBgMask;
    gpWaitView.mIconBgMask = iIconBgMask;
    gpWaitView.frame = CGRectMake(0, 0, ipParentView.frame.size.width, ipParentView.frame.size.height);
    gpWaitView.mpWaitLabel.text = ipText;
    
    [gpWaitView resetSubviewsFrames];
    
    [gpWaitView startAnimating];
}

+ (void)hideWaitView {
    [gpWaitView stopAnimating];
    [gpWaitView removeFromSuperview];
}

@end
