//
//  ViewController.h
//  dsdict
//
//  Created by Jinde Wang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GADBannerView.h"
//#import "GADBannerViewDelegate.h"
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "DictView.h"

@interface ViewController : UIViewController<AdWhirlDelegate> {
    //GADBannerView *bannerView_;
    AdWhirlView* mpAdView;
    
    DictView* mpDictView;
}

- (void)reloadAdBannerView;
- (void)unloadAdBannerView;
- (void)requestNewAd;

@end
