//
//  PMUtlity.h
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class  PMUtility;
@protocol PMUtilityDelegate <NSObject>
- (void)utility:(PMUtility *) sender getUserLocationUpdate:(CLLocation *) location;
@end


@interface PMUtility : NSObject
@property (nonatomic) BOOL turnOnLocationUpdate;  // turn on/off location update
/**
 *  get the cache Location.
 *  @return nil if cache data is not ready. You should become the delegate or 
 *  request again when it avaialble 
 */
- (CLLocation *)getUserCurrentLocationWithSender:(id) sender;
@end
