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

#define HEROK_NEWS_TITLE  @"news_title"
#define HEROK_NEWS_AUTHOR @"news_uploader_screen_name"
#define HEROK_NEWS_ID     @"id"
#define HEROK_LAT         @"news_geo_lat"
#define HEROK_LON         @"news_geo_long"

typedef enum {
  PMHerokCacheFromCache,         // get from current cache, if not, from network
  PMHerokCacheForceToReload,     // get from server, not to db
  PMHerokCacheForceToStoreToDB,  // get from server and to db
  PMHerokCacheFromNetworkButFailedFromDB // get from server and to db, but network failure will load from db.
} PMHerokCacheOption;

@interface PMHerokCacheRequest : NSObject <NSURLConnectionDelegate>
@property (strong, nonatomic) UIManagedDocument *passimDB;
@property (strong, nonatomic) NSArray *lastLoadFromNetworkData;

- (void)newsBoundedByOrigin:(CLLocationCoordinate2D) origin 
                   withSpan:(MKCoordinateSpan) span
                       from:(NSTimer *) pastTime
    withCacheCompletedBlock:(void (^)()) cacheHandler
         withCompletedBlock:(void (^)(NSArray *newsData)) networkCompleteHandler;
// Array of newsData with each one is Dictionary with key

/**
 * Load a news based on the current address. Option to help speed thing up
 * address: with key City, State, Country
 * option:  either load from current cache, db or network
 
 */
- (void)newsBasedOnRegion:(NSDictionary *)address
                   option:(PMHerokCacheOption) option
        withCompleteBlock:(void (^)(NSArray *newsData)) handler;
@end
