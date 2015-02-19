//
//  Mapa.m
//  tragomaps
//
//  Created by TRON on 18/02/15.
//  Copyright (c) 2015 TRON. All rights reserved.
//

#import "Mapa.h"
#import "json/SBJson.h"

NSDictionary    *jsonResponse;

NSMutableArray *namePlace;
NSMutableArray *latPlace;
NSMutableArray *lngPlace;
NSMutableArray *urlPlace;

NSString    *strUserLocation;
float       mlatitude;
float       mlongitude;

GMSMapView *mapView;
GMSMarker *usuario;


@interface Mapa ()

@end

@implementation Mapa{
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager                    = [[CLLocationManager alloc] init];
    self.locationManager.delegate           = self;
    self.location                           = [[CLLocation alloc] init];
    self.locationManager.desiredAccuracy    = kCLLocationAccuracyKilometer;
    [self.locationManager  requestWhenInUseAuthorization];
    [self.locationManager  requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    [self mapsInit];
    [self postService];
    mapView.delegate = self;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) mapsInit{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mlatitude
                                                            longitude:mlongitude
                                                                 zoom:16];
    [self.vistaMapa layoutIfNeeded];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.frame = CGRectMake(0, 0, self.vistaMapa.frame.size.width, self.vistaMapa.frame.size.height);
    mapView.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    usuario = [[GMSMarker alloc] init];
    usuario.position = CLLocationCoordinate2DMake(mlatitude, mlongitude);
    usuario.title = @"Yo";
    usuario.snippet = @"Vamonos por las primeras!";
    usuario.icon = [UIImage imageNamed:@"usuario.png"];
    usuario.map = mapView;
    
    [self.vistaMapa addSubview:mapView];
    [self geolocaliza];
}

- (void) geolocaliza{
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         float mapLat = self.locationManager.location.coordinate.latitude;
         float mapLng = self.locationManager.location.coordinate.longitude;
         mapView.camera = [GMSCameraPosition cameraWithLatitude:mapLat longitude:mapLng zoom:16];
     }];

}


/**********************************************************************************************
 Localization
 **********************************************************************************************/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = locations.lastObject;
    NSLog( @"didUpdateLocation!");
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         for (CLPlacemark *placemark in placemarks)
         {
             NSString *addressName = [placemark name];
             NSString *city = [placemark locality];
             NSString *administrativeArea = [placemark administrativeArea];
             NSString *country  = [placemark country];
             NSString *countryCode = [placemark ISOcountryCode];
             //NSLog(@"name is %@ and locality is %@ and administrative area is %@ and country is %@ and country code %@", addressName, city, administrativeArea, country, countryCode);
             strUserLocation = [[administrativeArea stringByAppendingString:@","] stringByAppendingString:countryCode];
             //NSLog(@"gstrUserLocation = %@", strUserLocation);
         }
         mlatitude = self.locationManager.location.coordinate.latitude;
         //[mUserDefaults setObject: [[NSNumber numberWithFloat:mlatitude] stringValue] forKey: pmstrLatitude];
         mlongitude = self.locationManager.location.coordinate.longitude;
         //[mUserDefaults setObject: [[NSNumber numberWithFloat:mlatitude] stringValue] forKey: pmstrLatitude];
         //NSLog(@"mlatitude = %f", mlatitude);
         //NSLog(@"mlongitude = %f", mlongitude);
         usuario.position = CLLocationCoordinate2DMake(mlatitude, mlongitude);
     }];
}

-(BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    NSLog(@"%@", marker.description);
    [mapView setSelectedMarker:marker];
    return YES;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    NSLog(@"%@", marker.title);
    CLLocationCoordinate2D posicion =  marker.position;
    float markerLat = posicion.latitude;
    float markerLng = posicion.longitude;
    NSLog(@"%.8f",markerLat);
    NSString *direccion = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit", markerLat, markerLng,mlatitude,mlongitude];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:direccion]];
        } else {
            NSLog(@"Can't use comgooglemaps://");
        }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*******************************************************************************
 Web Service
 *******************************************************************************/
//-------------------------------------------------------------------------------
- (void) postService
{
    NSLog(@"postService");
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadService) object:nil];
    [queue addOperation:operation];
}
//-------------------------------------------------------------------------------
- (void) loadService
{
    @try
    {
        
        NSURL *url = [NSURL URLWithString:@"http://goshmx.com/apps/mobileserv/api/mti/lista/user/gosh"];
        NSLog(@"URL postService = %@", url);
        
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
        NSError *error;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        jsonResponse = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
        //-------------------------------------------------------------------------------
    }
    @catch (NSException * e)
    {
        NSLog(@"JSON Exception");
    }
    //-------------------------------------------------------------------------------
    NSLog(@"jsonResponse %@", jsonResponse);
    namePlace = [jsonResponse valueForKey:@"name"];
    latPlace = [jsonResponse valueForKey:@"lat"];
    lngPlace = [jsonResponse valueForKey:@"lng"];
    urlPlace = [jsonResponse valueForKey:@"url"];
    
    NSLog(@"nombres %@", namePlace);
    
    for (int a=0;a<[namePlace count];a++){
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([latPlace[a] floatValue], [lngPlace[a] floatValue]);
        marker.title = namePlace[a];
        marker.snippet = @"Click aqui para indicarte como llegar";
        marker.icon = [UIImage imageNamed:@"1423446952_beer.png"];
        marker.map = mapView;
    }
    
}

- (IBAction)accionListado:(id)sender {
    [self performSegueWithIdentifier:@"sagaMapaHome" sender:self];
}
@end
