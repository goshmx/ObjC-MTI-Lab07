//
//  ViewController.m
//  tragomaps
//
//  Created by TRON on 13/02/15.
//  Copyright (c) 2015 TRON. All rights reserved.
//

#import "Home.h"

@interface Home ()

@end

@implementation Home

- (void)viewDidLoad {
    [self cfgiAdBanner];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*********************************************************************************
 iAd Functions
 ***********************************************************************************/

- (void)cfgiAdBanner
{
    // Setup iAdView
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    
    CGRect adFrame = adView.frame;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    NSLog(@"screenSize.height: %f",screenSize.height);
    
    if (screenSize.height > 480.0f)
    {//Do iPhone 5 stuff here
        adFrame.origin.y = 518;
    }
    else
    {//Do iPhone 4 stuff here
        adFrame.origin.y = 430;
    }
    adView.frame = adFrame;
    
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [self.view addSubview:adView];
    adView.delegate = self;
    adView.hidden = YES;
    self->bannerIsVisible = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self->bannerIsVisible)
    {
        adView.hidden = NO;
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        [UIView commitAnimations];
        self->bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self->bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        [UIView commitAnimations];
        adView.hidden = YES;
        self->bannerIsVisible = NO;
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = YES;
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}

@end
