//
//  PMMapViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMMapViewController.h"
#import "PMLocationUtility.h"
#import "PMAppDelegate.h"
#import "PMNewsAnnotation.h"

#define METERS_PER_MILE 1609.344
#define MKANNOATIONVIEW_ID @"MapAnnoationView_reuseID"
#define SEGUE_SHOW_NEWS @"showNewsDetail"

@interface PMMapViewController () <PMUtilityDelegate>
@property (weak, nonatomic) PMLocationUtility *sharedUtilty;
@end

@implementation PMMapViewController

#pragma mark - 
@synthesize mapView = _mapView;
@synthesize newsAnnotation = _newsAnnotation;
@synthesize sharedUtilty = _sharedUtilty;

#pragma mark - Setter/Getter
- (void)setNewsAnnotation:(NSDictionary *)newsAnnotation
{
  _newsAnnotation = newsAnnotation;
  [self updateNewsMap];
}

- (void)setMapView:(MKMapView *)mapView
{
  _mapView = mapView;
  [self updateNewsMap];
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
  [super viewDidLoad];
  id delegate = [[UIApplication sharedApplication] delegate];
  self.sharedUtilty = [delegate valueForKey:PMUTILITY_KEY];
  [self.sharedUtilty setValue:self forKey:@"delegate"];
  self.sharedUtilty.turnOnLocationUpdate = YES;
  CLLocation *userLocation = [self.sharedUtilty getUserCurrentLocationWithSender:self];
  if (userLocation != nil) {
    [self displayMapWithLocation:userLocation.coordinate];
  }
}

- (void)viewDidUnload
{
  [self setMapView:nil];
  [super viewDidUnload];
  self.sharedUtilty = nil;
  
    // Release any retained subviews of the main view.
}


#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - private function
- (void)displayMapWithLocation:(CLLocationCoordinate2D) zoomLocation
{
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
  MKCoordinateRegion adjustRegion = [self.mapView regionThatFits:viewRegion];
  [self.mapView setRegion:adjustRegion animated:YES];
}

// Add news pin into map
- (void)updateNewsMap
{
  if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
  if (self.newsAnnotation) [self.mapView addAnnotations: [self.newsAnnotation allValues]];
}

// Add one news pin to map
- (void)addToNewsMapWithAnnotation:(id<MKAnnotation>) annotation
{
  if ([annotation isKindOfClass:[PMNewsAnnotation class]]) {
    NSInteger news_id = [(PMNewsAnnotation *)annotation news_id];
    id value = [self.newsAnnotation objectForKey:[NSNumber numberWithInt:news_id]];
    // check whehter it exist in the map
    if (!value) {
      [self.newsAnnotation setObject:annotation forKey:[NSNumber numberWithInt:news_id]];
      // TODO: Pin drop animation. need more research on this.
      [self.mapView addAnnotation:annotation];
    }
  }
  
}

// Remove one news pin from Map
- (void)removeFromNewsMapWithAnnotation:(id<MKAnnotation>) annotation
{
  [self.mapView removeAnnotation:annotation];
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
    }
  } else {
    NSLog(@"Cann't perform segue with Segue ID : %@ in PMMapViewController", segue.identifier);
  }
}


#pragma mark - PMUtility Delegate
- (void)utility:(PMLocationUtility *)sender getUserLocationUpdate:(CLLocation *)location 
{
  // move the map to this center
  [self displayMapWithLocation:location.coordinate];
}


#pragma mark - MKMapViewController Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
  MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:MKANNOATIONVIEW_ID];
  if (!aView) {
    // TODO: maybe need to write a subclass or experience the image property in MKAnnoationView
    // to custome the point on map
    aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MKANNOATIONVIEW_ID];
    aView.canShowCallout = YES;
    aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
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

#pragma mark - Network 

@end
