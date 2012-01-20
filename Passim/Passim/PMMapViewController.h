//
//  PMMapViewController.h
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface PMMapViewController : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;  // map view on the screen
@property (strong, nonatomic) NSMutableDictionary *newsAnnotations;


@end
