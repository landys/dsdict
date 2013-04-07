//
//  ViewController.m
//  dsdict
//
//  Created by Jinde Wang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "DictView.h"
#import "ColorUtil.h"
#import "DictUtil.h"
#import "Global.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
    
#if defined (FREE_VERSION)    
    [Global initAdManager:self.view rootViewController:self];
    AdManager* lpAdManager = [Global getAdManager];
    lpAdManager.mpDelegate = mpDictView;
    
    // move the request ad to AppDelegate#applicationDidBecomeActive.
    if (![Global hasSuperPrivilege]) {
        [lpAdManager reInitAdBannerView];
    }
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
#if defined (FREE_VERSION) 
    AdManager* lpAdManager = [Global getAdManager];
    [lpAdManager clearAdManager];
#endif    
    
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


@end
