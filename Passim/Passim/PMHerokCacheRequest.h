//
//  PMHerokRequest.h
//  URL Loading System
//  Passim
//
//  Created by Philip Zhao on 1/16/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PMHerokCacheRequest : NSObject <NSURLConnectionDelegate>
@property (strong, nonatomic) UIManagedDocument *passimDB;

- (void)newsBoundedByUpperLocation:(CLLocationCoordinate2D) upper 
                     lowerLocation:(CLLocationCoordinate2D) lower 
                              from:(NSTimer *) pastTime
           withCacheCompletedBlock:(void (^)()) cacheHandler
                withCompletedBlock:(void (^)()) networkhandler;

@end
