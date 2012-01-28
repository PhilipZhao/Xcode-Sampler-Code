//
//  PMMapViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMMapViewController.h"
#import "PMAppDelegate.h"
#import "PMNewsAnnotation.h"
#import "PMNotification.h"
#import "PMComposeNewsViewController.h"

#define METERS_PER_MILE 1609.344
#define MKANNOATIONVIEW_ID @"MapAnnoationView_reuseID"
#define SEGUE_SHOW_NEWS @"showNewsDetail"


@interface PMMapViewController () <PMUtilityDelegate, PMNotificationLocation>
@property (weak, nonatomic) PMLocationUtility *sharedUtilty;
@property (weak, nonatomic) PMHerokCacheRequest *sharedHerokRequest;
@end

@implementation PMMapViewController

#pragma mark - 
@synthesize mapView = _mapView;
@synthesize newsAnnotations = _newsAnnotations;
@synthesize sharedUtilty = _sharedUtilty;
@synthesize sharedHerokRequest = _sharedHerokRequest;

#pragma mark - private function
- (void)displayMapWithLocation:(CLLocationCoordinate2D) zoomLocation
{
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 
                                                                     0.5 * METERS_PER_MILE, 
                                                                     0.5 * METERS_PER_MILE);
  MKCoordinateRegion adjustRegion = [self.mapView regionThatFits:viewRegion];
  [self.mapView setRegion:adjustRegion animated:YES];
}

// Add news pin into map
- (void)updateNewsMap
{
  if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
  if (self.newsAnnotations) [self.mapView addAnnotations: [self.newsAnnotations allValues]];
}

// Add one news pin to map
- (void)addToNewsMapWithAnnotation:(id<MKAnnotation>) annotation
{
  if ([annotation isKindOfClass:[PMNewsAnnotation class]]) {
    NSInteger news_id = [(PMNewsAnnotation *)annotation news_id];
    id value = [self.newsAnnotations objectForKey:[NSNumber numberWithInt:news_id]];
    // check whehter it exist in the map
    [self.newsAnnotations setObject:annotation forKey:[NSNumber numberWithInt:news_id]];
    if (!value) {
      // TODO: Pin drop animation. need more research on this.
      [self.mapView addAnnotation:annotation];
    }
  }
}

- (void)addToNewsMapWithAnnotations:(NSArray *) annotations
{
  NSMutableArray *listToAdd = [[NSMutableArray alloc] init];
  for (PMNewsAnnotation *annotation in annotations) {
    NSInteger news_id = [(PMNewsAnnotation *)annotation news_id];
    id value = [self.newsAnnotations objectForKey:[NSNumber numberWithInt:news_id]];
    [self.newsAnnotations setObject:annotation forKey:[NSNumber numberWithInt:news_id]];
    if (!value)
      [listToAdd addObject:annotation];
  }
  if ([listToAdd count] > 0) [self.mapView addAnnotations:listToAdd];
  else NSLog(@"it is empty arrary");
}

// Remove one news pin from Map
- (void)removeFromNewsMapWithAnnotation:(id<MKAnnotation>) annotation
{
  if ([annotation isKindOfClass:[PMNewsAnnotation class]]) {
    NSInteger news_id = [(PMNewsAnnotation *)annotation news_id];
    [self.newsAnnotations removeObjectForKey:[NSNumber numberWithInt:news_id]];
  }
  [self.mapView removeAnnotation:annotation];
}

// depreicate for this version
- (void)updateNewsWithCurrentRegion:(MKCoordinateRegion) region
{
  NSLog(@"this method is not recommended to use, see updateNewsWithCurrentAddress: method");
  CLLocationCoordinate2D origin;
  origin.latitude = region.center.latitude - region.span.latitudeDelta/2;
  origin.longitude = region.center.longitude - region.span.longitudeDelta/2;
  [self.sharedHerokRequest newsBoundedByOrigin: origin 
                                      withSpan:region.span
                                          from:nil
                       withCacheCompletedBlock:^{}
                            withCompletedBlock:^(NSArray *newsData){
    NSLog(@"Retrieve news completed");
    // need to show up the pin in the map
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[newsData count]];
    for (NSDictionary *singleNews in newsData) {
      PMNewsAnnotation *annotation = [PMNewsAnnotation annotationForNews:singleNews];
      [annotations addObject:annotation];
    }                          
    // put data into it
    [self addToNewsMapWithAnnotations:annotations];
  }];
}

- (void)updateNewsWithCurrentAddress:(NSDictionary *)newAddress
{
  void (^completeBlock)(NSArray *) = ^(NSArray *newsData) {
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[newsData count]];
    for (NSDictionary *singleNews in newsData) {
      PMNewsAnnotation *annotation = [PMNewsAnnotation annotationForNews:singleNews];
      [annotations addObject:annotation];
    }
    [self addToNewsMapWithAnnotations:annotations];
  };
  [self.sharedHerokRequest newsBasedOnRegion: newAddress
                                      option:PMHerokCacheFromCache 
                           withCompleteBlock:completeBlock];
}

#pragma mark - Setter/Getter
- (void)setNewsAnnotations:(NSDictionary *)newsAnnotation
{
  _newsAnnotations = [newsAnnotation mutableCopy];
  [self updateNewsMap];
}

- (void)setMapView:(MKMapView *)mapView
{
  _mapView = mapView;
  _mapView.delegate = self;
  [self updateNewsMap];
}

- (NSMutableDictionary *)newsAnnotations
{
  if (_newsAnnotations == nil) {
    _newsAnnotations = [[NSMutableDictionary alloc] init];
  }
  return _newsAnnotations;
}


#pragma mark - View Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"MapView viewDidLoad");
  [super viewDidLoad];
  id delegate = [[UIApplication sharedApplication] delegate];
  self.sharedUtilty = [delegate valueForKey:PMUTILITY_KEY];
  self.sharedUtilty.turnOnLocationUpdate = YES;
  CLLocation *userLocation = [self.sharedUtilty getUserCurrentLocationWithSender:self];
  if (userLocation != nil) {
    [self displayMapWithLocation:userLocation.coordinate];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    [self.sharedUtilty addressInformationBaseOnLocation:location sender:self completedBlock:^(NSDictionary *address) {
      [self updateNewsWithCurrentAddress:address];
    }];
  }

  // set up Notification
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceiveNewLocation:) name:PMNotificationLocationNewLocation object:self.sharedUtilty];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceiveNewAddress:) name:PMNotificationLocationNewAddress object:self.sharedUtilty];
}

- (void)viewDidUnload
{
  [self setMapView:nil];
  [super viewDidUnload];
  self.sharedUtilty = nil;
  [[NSNotificationCenter defaultCenter] removeObject:self];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  //[self updateNewsMap];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [self.mapView addAnnotations: [self.newsAnnotations allValues]];
}


#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:SEGUE_SHOW_NEWS]) {
    // init the detail news controller about which news need fetch
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
      PMNewsAnnotation *annotation = (PMNewsAnnotation *)[(MKAnnotationView *)sender annotation];
      if ([segue.destinationViewController respondsToSelector:@selector(setNews_id:)])
        [segue.destinationViewController setNews_id:annotation.news_id];
      // set up delegate
      
    }
  } else if ([segue.identifier isEqualToString:SEGUE_COMPOSITE_NEWS]) {
    if ([segue.destinationViewController isKindOfClass:[PMComposeNewsViewController class]]) {
      NSLog(@"segueway correct");
      PMComposeNewsViewController *vc = (PMComposeNewsViewController *)segue.destinationViewController;
      [vc setCompletionHandler:^(PMComposeViewControllerResult result) {
        if (result == PMComposeViewControllerResultDone) NSLog(@"Done");
        else NSLog(@"Cancel");
        dispatch_async(dispatch_get_main_queue(), ^{
          [segue.destinationViewController dismissModalViewControllerAnimated:YES];
        });
      }];
      // set the completeHandler
    }
  } else {
    NSLog(@"Cann't perform segue with Segue ID : %@ in PMMapViewController", segue.identifier);
  }
}


#pragma mark - PMUtility Delegate, Notification
- (void)utility:(PMLocationUtility *)sender getUserLocationUpdate:(CLLocation *)location 
{
  // move the map to this center
  [self displayMapWithLocation:location.coordinate];
}

- (void)notificationReceiveNewLocation:(NSNotification *)notification
{
  NSLog(@"Notificiation For new location");
  CLLocation *location = [notification.userInfo valueForKey:PMInfoCLLocation];
  [self displayMapWithLocation:location.coordinate];
  // need to wait for the address to come in
}

- (void)notificationReceiveNewAddress:(NSNotification *)notification
{
  NSLog(@"receive new location");
  NSDictionary *location = [notification.userInfo valueForKey:PMInfoAddress];
  [self updateNewsWithCurrentAddress: location];
}

#pragma mark - MKMapViewController Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
  NSLog(@"mapViewForAnnotation");
  MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:MKANNOATIONVIEW_ID];
  if (!aView) {
    // TODO: maybe need to write a subclass or experience the image property in MKAnnoationView
    // to custome the point on map
    aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MKANNOATIONVIEW_ID];
    aView.canShowCallout = YES;
    [(MKPinAnnotationView *)aView setPinColor:MKPinAnnotationColorPurple];
    // add leftCalloutAccessoryView
    aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    // add rightCalloutAccessorView
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    aView.rightCalloutAccessoryView = rightButton;
  }
  aView.annotation = annotation;
  [(UIImageView *)aView.leftCalloutAccessoryView setImage: nil];
  return aView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
  // prepare for segue-way
  [self performSegueWithIdentifier:SEGUE_SHOW_NEWS sender:view];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
  // get news image and display it
  NSLog(@"news_id: %d", [(PMNewsAnnotation *)view.annotation news_id]);
  // TODO: need to get news image
#warning Need to get news images
  UIImage *news_img;
  [(UIImageView *)view.leftCalloutAccessoryView setImage:news_img];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
  // send network request to new location
  NSLog(@"regionDidChangedAnimated and need to implement");
  CLLocation *location = [[CLLocation alloc] initWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
  [self.sharedUtilty addressInformationBaseOnLocation:location sender:self completedBlock:^(NSDictionary *address){
    [self updateNewsWithCurrentAddress:address];
  }];
  //[self updateNewsWithCurrentRegion:mapView.region];
}
@end
