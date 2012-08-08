//
//  AdManager.h
//  tcidsd
//
//  Created by Jinde Wang on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

@protocol AdManagerDelegate <NSObject>

@optional

- (void)adViewDidReceiveAd:(CGSize)iAdViewSize;

@end


@interface AdManager : NSObject<GADBannerViewDelegate> {
    GADBannerView* mpAdView;
    
    UIView* mpParentView;
    
    UIViewController* mpRootViewController;
    
    id<AdManagerDelegate> mpDelegate;
}

@property (nonatomic) id<AdManagerDelegate> mpDelegate;

- (id)initWithParentView:(UIView*)ipParentView rootViewController:(UIViewController*)ipRootViewController;

- (void)reloadAdBannerView;
- (void)unloadAdBannerView;
- (void)requestNewAd;

- (void)reInitAdBannerView;
- (GADRequest*)generateRequest;
- (GADAdSize)getAdBannerSize;

- (void)clearAdManager;

@end

