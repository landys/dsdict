//
//  ViewController.h
//  tcidsd
//
//  Created by Jinde Wang on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "DictView.h"

@interface ViewController : UIViewController<GADBannerViewDelegate> {
    GADBannerView *bannerView_;
    
    DictView* mpDictView;
}

- (void)reloadAdBannerView;
- (void)unloadAdBannerView;
- (void)requestNewAd;

@end
