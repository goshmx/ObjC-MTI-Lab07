//
//  Mapa.h
//  tragomaps
//
//  Created by TRON on 18/02/15.
//  Copyright (c) 2015 TRON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <iAd/iAd.h>

@interface Mapa : UIViewController<CLLocationManagerDelegate, GMSMapViewDelegate>

@property (strong, nonatomic) CLLocationManager     *locationManager;
@property (strong, nonatomic) CLLocation            *location;
@property (strong, nonatomic) IBOutlet UIView *vistaMapa;

- (IBAction)accionListado:(id)sender;
@end
