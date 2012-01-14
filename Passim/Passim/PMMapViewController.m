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

#define METERS_PER_MILE 1609.344

@interface PMMapViewController () <PMUtilityDelegate>
@property (weak, nonatomic) PMLocationUtility *sharedUtilty;
@end

@implementation PMMapViewController
@synthesize mapView = _mapView;
@synthesize sharedUtilty = _sharedUtilty;

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

#pragma mark - PMUtility Delegate
- (void)utility:(PMLocationUtility *)sender getUserLocationUpdate:(CLLocation *)location 
{
  // move the map to this center
  [self displayMapWithLocation:location.coordinate];
}
@end
