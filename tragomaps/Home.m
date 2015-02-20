//
//  ViewController.m
//  tragomaps
//
//  Created by TRON on 13/02/15.
//  Copyright (c) 2015 TRON. All rights reserved.
//

#import "Home.h"
#import "cellPlaces.h"
#import "json/SBJson.h"

NSDictionary    *jsonResponse;

NSMutableArray *namePlace;
NSMutableArray *latPlace;
NSMutableArray *lngPlace;
NSMutableArray *urlPlace;
NSMutableArray *descripcionPlace;

@interface Home ()

@end

@implementation Home

- (void)viewDidLoad {
    [self cfgiAdBanner];
    [self screenName];
    [super viewDidLoad];
    
    [self postService];
    [self.tablePlaces reloadInputViews];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Tabla TragoMaps - Home";
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

/**********************************************************************************************
 Table Functions
 **********************************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//-------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return namePlace.count;
}
//-------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
//-------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellPlaces");
    static NSString *CellIdentifier = @"cellPlaces";
    
    cellPlaces *cell = (cellPlaces *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[cellPlaces alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.nombreLugar.text = namePlace[indexPath.row];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPlace[indexPath.row]]];    
    cell.foto.image = [UIImage imageWithData:imageData];
    cell.foto.contentMode  = UIViewContentModeScaleAspectFit;
    cell.descLugar.text = descripcionPlace[indexPath.row];
    
    

    
    
    return cell;
}

//-------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *latitud = [latPlace objectAtIndex:indexPath.row];
    NSString *longitud = [lngPlace objectAtIndex:indexPath.row];
    NSString *nombre = [namePlace objectAtIndex:indexPath.row];
    
     NSString *direccion = [NSString stringWithFormat:@"comgooglemaps://?&daddr=%@,%@&zoom=14&directionsmode=driving", latitud, longitud];
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:direccion]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }    
    
}


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
    descripcionPlace = [jsonResponse valueForKey:@"descripcion"];

    
    
    NSLog(@"nombres %@", namePlace);
    [self.tablePlaces reloadData];
    [self.tablePlaces performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    
    
}



- (IBAction)accionMapa:(id)sender {
    [self performSegueWithIdentifier:@"sagaHomeMapa" sender:self];
}
- (IBAction)actualizar:(id)sender {
    [self postService];
    [self.tablePlaces reloadInputViews];
}
@end
