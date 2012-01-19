//
//  PMHerokRequest.m
//  Passim
//
//  Created by Philip Zhao on 1/16/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMHerokCacheRequest.h"
#import "ASIHTTPRequest.h"


#define PASSIM_NEWS_AROUND @"http://passim1200.herokuapp.com/news_range?"
#define PASSIM_NEWS_FEED @""

@implementation PMHerokCacheRequest

@synthesize passimDB = _passimDB;

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


// implement the network request
#pragma mark - implement Network request
- (void)newsBoundedByUpperLocation:(CLLocationCoordinate2D) upper 
                     lowerLocation:(CLLocationCoordinate2D) lower 
                              from:(NSTimer *) pastTime
           withCacheCompletedBlock:(void (^)()) cacheHandler
                withCompletedBlock:(void (^)()) networkhandler
{
  // TODO: phil figure how to present these thing
  // db request to database.
  NSURL *url = [NSURL URLWithString:[PASSIM_NEWS_AROUND stringByAppendingFormat:@"range_geo_lat_lower=%f&range_geo_long_lower=%f&range_geo_lat_higher=%f&range_geo_long_higher=%f", lower.latitude, lower.longitude, upper.latitude, upper.longitude]];
  NSLog(@"%@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *newsResult = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonParsingError];
      // parsing the data
      NSLog(@"news result: %@", newsResult);
      // use retrive the data into 
      networkhandler();
      // set out notification for whose observing
      // cache them into the database
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
