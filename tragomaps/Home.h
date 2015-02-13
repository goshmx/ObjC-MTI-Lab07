//
//  ViewController.h
//  tragomaps
//
//  Created by TRON on 13/02/15.
//  Copyright (c) 2015 TRON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GAITrackedViewController.h"

@interface Home : GAITrackedViewController<UIApplicationDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
}
@end

