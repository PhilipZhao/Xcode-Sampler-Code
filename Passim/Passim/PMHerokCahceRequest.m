//
//  PMHerokRequest.m
//  Passim
//
//  Created by Philip Zhao on 1/16/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMHerokCacheRequest.h"
#import "ASIHTTPRequest.h"


#define PASSIM_WEB @"http://passim1200.herokuapp.com/"
#define PASSIM_NEWS_FEED @""

@implementation PMHerokCacheRequest

@synthesize passimDB = _passimDB;
@synthesize lastLoadFromNetworkData = _lastLoadFromNetworkData;

#pragma mark - private function
- (void)useDocumentWithBlock:(void (^)()) handler
{
  if (![[NSFileManager defaultManager] fileExistsAtPath:[self.passimDB.fileURL path]]) {
    // does not exist on disk, so create it
    [self.passimDB saveToURL:self.passimDB.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
      handler();
    }];
  } else if (self.passimDB.documentState == UIDocumentStateClosed) {
    // exists on disk, but we need to open it
    [self.passimDB openWithCompletionHandler:^(BOOL success) {
      handler();
    }];
  } else if (self.passimDB.documentState == UIDocumentStateNormal) {
    // already open and ready to use
    handler();
  }
}


- (id)init 
{
  if (self = [super init]) {
    // create passimDB instance
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                         inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Passim Cache Database"];
    // url is now "<Documents Directory>/Passim Cache Databas"
    self.passimDB = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
  }
  return self;
}


#pragma mark - Setter/Getter
- (void)setPassimDB:(UIManagedDocument *)passimDB
{
  if (_passimDB != passimDB) {
    _passimDB = passimDB;
    [self useDocumentWithBlock:^{}];
  }
}

- (NSArray *)lastLoadFromNetworkData
{
  if (_lastLoadFromNetworkData == nil) 
    _lastLoadFromNetworkData = [[NSArray alloc] init];
  return _lastLoadFromNetworkData;
}

// implement the network request
#pragma mark - implement Network request
- (void)newsBoundedByOrigin:(CLLocationCoordinate2D) origin 
                   withSpan:(MKCoordinateSpan) span
                       from:(NSTimer *) pastTime
    withCacheCompletedBlock:(void (^)()) cacheHandler
         withCompletedBlock:(void (^)(NSArray *newsData)) networkCompletedHandler;
{
  // TODO: phil figure how to present these thing
  // db request to database.
  NSURL *url = [NSURL URLWithString:[PASSIM_WEB stringByAppendingFormat:@"news_around?origin_geo_lat=%f&origin_geo_long=%f&offset_geo_lat=%f&offset_geo_long=%f", origin.latitude, origin.longitude, span.latitudeDelta, span.longitudeDelta]];
  NSLog(@"%@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *newsResult = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      // parsing the data
      NSLog(@"%@", newsResult);
      NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[newsResult count]];
      if ([newsResult count] > 0) {
        for (NSDictionary *key in newsResult) [result addObject:key];
      }
      // use retrive the data into 
      networkCompletedHandler(result);
      // set out notification for whose observing
      NSDictionary *info = [NSDictionary alloc];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"Need to figure it out" object:self userInfo:nil];
      // cache them into the database
      // cache the data
      self.lastLoadFromNetworkData = result;
    }
  }];
  [request setFailedBlock:^{
    // Set out notification for failure
  }];
  [request startAsynchronous];
}

- (void)newsFeedForPeopleWhoseIFollowedWith:(NSString *) screen_name
                  withNetworkCompletedBlock:(void (^)()) networkhandler
{
  NSURL *url = [NSURL URLWithString:[PASSIM_NEWS_FEED stringByAppendingFormat:@"%@", screen_name]];
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
  
  }];
  [request setFailedBlock:^{
    // 
  }];
  [request startAsynchronous];
}
@end
