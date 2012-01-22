//
//  PMUtlity.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMLocationUtility.h"
#import "PMNotification.h"

@interface PMLocationUtility() <CLLocationManagerDelegate>
@property (weak, nonatomic) id<PMUtilityDelegate> delegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *currentAddress;
@end

@implementation PMLocationUtility
@synthesize turnOnLocationUpdate = _turnOnLocationUpdate;
@synthesize delegate = _delegate;
@synthesize locationManager = _locationManager;
@synthesize geocoder = _geocoder;
@synthesize currentAddress = _currentAddress;

- (id)init {
  if (self = [super init]) {
    // set self userLocation to no
  }
  return self;
}

#pragma mark - Setter/Getter
- (void)setDelegate:(id<PMUtilityDelegate>) delegate 
{
  if (delegate == nil) {
    // turn off GPS or other service?
  }
  _delegate = delegate;
}

- (void)setTurnOnLocationUpdate:(BOOL)turnOnLocationUpdate {
  if (turnOnLocationUpdate) {
    [self.locationManager startUpdatingLocation];
  } else {
    [self.locationManager stopUpdatingLocation];
  }
  _turnOnLocationUpdate = turnOnLocationUpdate;
}

- (CLLocationManager *)locationManager
{
  if (_locationManager == nil) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100;
  }
  return _locationManager;
}

- (CLGeocoder *)geocoder
{
  if (_geocoder == nil) {
    _geocoder = [[CLGeocoder alloc] init];
  }
  return _geocoder;
}

- (CLLocation *)getUserCurrentLocationWithSender:(id) sender
{
  if (self.locationManager.location == nil) {
    // start the Location Manager service
    self.turnOnLocationUpdate = YES;
  }
  NSLog(@"current user location <%f, %f>", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
  return self.locationManager.location;
}

#pragma mark - Location delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"locationManager failed with error");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  //set up the userLocation right
  NSDate *eventDate = newLocation.timestamp;
  NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
  if (abs(howRecent) < 15) {
    // stop the geolocation service
    //self.turnOnLocationUpdate = NO;
    self.currentAddress = nil; // invalid current address
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placeMarkers, NSError *error) {
      if (error == nil)
        self.currentAddress = [placeMarkers objectAtIndex:0];
    }];
    NSDictionary *postInfo = [NSDictionary dictionaryWithObject:self.locationManager.location 
                                                         forKey:PMInfoCLLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:PMNotificationLocationNewLocation 
                                                        object:self 
                                                      userInfo:postInfo];
  }
}
@end
