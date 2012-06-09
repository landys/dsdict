//
//  ViewController.m
//  tcidsd
//
//  Created by Jinde Wang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "DictView.h"
#import "ColorUtil.h"
#import "DictUtil.h"
#import "Global.h"

#define ADMOB_PUBLISHER_ID @"a14f8cf7c904423"
#define ADMOB_PUBLISHER_ID_IPAD @"a14f8cf8b3c2a9c"

@interface ViewController (Private)

- (void)reInitAdBannerView;
- (GADRequest*)generateRequest;
- (CGSize)getAdBannerSize;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (GADRequest *)generateRequest {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad.
    //request.testing = YES;
    
    return request;
}

- (CGSize)getAdBannerSize {
    return [DictUtil isIPad] ? GAD_SIZE_728x90 : GAD_SIZE_320x50;
}

- (void)reloadAdBannerView {
    [self reInitAdBannerView];
    [self requestNewAd];
}

- (void)reInitAdBannerView {
    if (bannerView_ != nil) {
        [self unloadAdBannerView];
    }
    
    // Create a view of the standard size at the bottom but out of the screen.
    CGSize lBannerSize = [self getAdBannerSize];
    CGRect lBannerFrame = CGRectMake((int)((self.view.frame.size.width - lBannerSize.width) / 2), self.view.frame.size.height, lBannerSize.width, lBannerSize.height);
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:lBannerFrame];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = [DictUtil isIPad] ? ADMOB_PUBLISHER_ID_IPAD : ADMOB_PUBLISHER_ID;
    bannerView_.delegate = self;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
}

- (void)unloadAdBannerView {
    bannerView_.delegate = nil;
    [bannerView_ removeFromSuperview];
    [bannerView_ release];
    bannerView_ = nil;
}

- (void)requestNewAd {
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[self generateRequest]];
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [super viewDidLoad];
    
    [ColorUtil initStdColors];
    
    // global settings
    [Global initGlobalValues];
	
    mpDictView = [[DictView alloc] initWithFrame:self.view.frame viewController:self];
    [self.view addSubview:mpDictView];
    
    [mpDictView initForSearch];
    
    // move the request ad to AppDelegate#applicationDidBecomeActive.
    if (![Global hasSuperPrivilege]) {
        //[self reloadAdBannerView];
        [self reInitAdBannerView];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    bannerView_.delegate = nil;
    [bannerView_ release];
    bannerView_ = nil;
    
    [mpDictView release];
    mpDictView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    // Now only support portrait mode.
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        } else {
            return YES;
        }
    }
    return NO;
}

#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and add it to the view.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    // This code slides the banner up onto the screen with an animation.
    if (adView.frame.origin.y != self.view.frame.size.height - adView.frame.size.height) {
        [UIView animateWithDuration:1.0 animations:^ {
            adView.frame = CGRectMake(adView.frame.origin.x, self.view.frame.size.height - adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
        }];
        
        [mpDictView resizeForAds:[self getAdBannerSize] showAd:YES animation:YES];
    }
}

//- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
//    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
//}

@end
