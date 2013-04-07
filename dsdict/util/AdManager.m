//
//  AdManager.m
//  dsdict
//
//  Created by Jinde Wang on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdManager.h"
#import "DictUtil.h"

// Admob mediation id
#define ADMOB_PUBLISHER_ID @"a08dbfd0e8574025"
#define ADMOB_PUBLISHER_ID_IPAD @"6d1e113f8af14bbc"

// Admob id
//#define ADMOB_PUBLISHER_ID @"a14f8cf7c904423"
//#define ADMOB_PUBLISHER_ID_IPAD @"a14f8cf8b3c2a9c"

// Adwhirl id
//#define ADWHIRL_SDK_KEY @"cdd4cf099fdc437a84e636e4814e9392"
//#define ADWHIRL_SDK_KEY_IPAD @"d2710366ddf546898764d521ebd39267"

@interface AdManager (Private)

//- (void)reInitAdBannerView;
//- (GADRequest*)generateRequest;
//- (GADAdSize)getAdBannerSize;

@end

@implementation AdManager
@synthesize mpDelegate;

- (id)initWithParentView:(UIView*)ipParentView rootViewController:(UIViewController*)ipRootViewController {
    self = [super init];
    if (self) {
        mpParentView = ipParentView;
        mpRootViewController = ipRootViewController;
    }
    
    return self;
}

- (GADRequest *)generateRequest {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad.
    //request.testing = YES;
    
    return request;
}

- (GADAdSize)getAdBannerSize {
    return [DictUtil isIPad] ? kGADAdSizeLeaderboard : kGADAdSizeBanner;
}

//- (CGSize)getAdBannerSize {
//    return [DictUtil isIPad] ? kGADAdSizeLeaderboard.size : kGADAdSizeBanner.size;
//    //return [DictUtil isIPad] ? GAD_SIZE_728x90 : GAD_SIZE_320x50;
//    //return [DictUtil isIPad] ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
//}

- (void)reloadAdBannerView {
    [self reInitAdBannerView];
    [self requestNewAd];
}

- (void)reInitAdBannerView {
    if (mpAdView != nil) {
        [self unloadAdBannerView];
    }
    
    // Create a view of the standard size at the bottom but out of the screen.
    //    CGSize lBannerSize = [self getAdBannerSize];
    //    CGRect lBannerFrame = CGRectMake((int)((self.view.frame.size.width - lBannerSize.width) / 2), self.view.frame.size.height, lBannerSize.width, lBannerSize.height);
    GADAdSize lBannerSize = [self getAdBannerSize];
    CGPoint lBannerOrigin = CGPointMake((int)((mpParentView.frame.size.width - lBannerSize.size.width) / 2), mpParentView.frame.size.height);
    
    //    mpAdView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    //    mpAdView.frame = lBannerFrame;
    
    //    mpAdView = [[GADBannerView alloc] initWithFrame:lBannerFrame];
    mpAdView = [[GADBannerView alloc] initWithAdSize:lBannerSize origin:lBannerOrigin];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    mpAdView.adUnitID = [DictUtil isIPad] ? ADMOB_PUBLISHER_ID_IPAD : ADMOB_PUBLISHER_ID;
    mpAdView.delegate = self;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    mpAdView.rootViewController = mpRootViewController;
    [mpParentView addSubview:mpAdView];
}

- (void)unloadAdBannerView {
    mpAdView.delegate = nil;
    [mpAdView removeFromSuperview];
    //[mpAdView release];
    mpAdView = nil;
}

- (void)requestNewAd {
    // Initiate a generic request to load it with an ad.
    [mpAdView loadRequest:[self generateRequest]];
    //[mpAdView requestFreshAd];
}

- (void)clearAdManager {
    mpAdView.delegate = nil;
    //[mpAdView release];
    mpAdView = nil;
}


#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and add it to the view.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    // This code slides the banner up onto the screen with an animation.
    if (adView.frame.origin.y != mpParentView.frame.size.height - adView.frame.size.height) {
        [UIView animateWithDuration:1.0 animations:^ {
            adView.frame = CGRectMake(adView.frame.origin.x, mpParentView.frame.size.height - adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
        }];
        
        [mpDelegate adViewDidReceiveAd:[self getAdBannerSize].size];
        //[mpDictView resizeForAds:[self getAdBannerSize].size showAd:YES animation:YES];
    }
}

//- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
//    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
//}

@end
