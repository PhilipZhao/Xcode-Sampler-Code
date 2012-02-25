//
//  PMHerokRequest.m
//  Passim
//
//  Created by Philip Zhao on 1/16/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMHerokCacheRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "PMNotification.h"
#import "PMStandKeyConstant.h"
#import "PMNews.h"


#define PASSIM_WEB @"http://passim1201.herokuapp.com/"
#define PASSIM_NEWS_FEED @""

typedef void (^newsHandler)(NSArray *newsData);
@interface PMHerokCacheRequest()
@property (strong, nonatomic) NSDictionary *addressBook;
@property (copy, nonatomic) newsHandler newsInRegionHandler;
@end

@implementation PMHerokCacheRequest
@synthesize passimDB = _passimDB;
@synthesize lastLoadFromNetworkData = _lastLoadFromNetworkData;
@synthesize addressBook = _addressBook;
@synthesize newsInRegionHandler = _newsInRegionHandler;

#pragma mark - class method
+ (void) fetchPhotoWithNewsId:(NSInteger)news_id option:(PMHerokPhotoOption)option withCompleteBlock:(void (^)(NSArray *))arrayOfImageHandler
{
  dispatch_queue_t imageDownloadQ = dispatch_queue_create("Server image downloader", NULL);
  dispatch_async(imageDownloadQ, ^{
    [NSThread sleepForTimeInterval:10];
    UIImage *image = [UIImage imageNamed:@"picons46.png"];
    NSArray *imageArray = [NSArray arrayWithObject:image];
    arrayOfImageHandler(imageArray);
  });
  dispatch_release(imageDownloadQ);
  /*
  NSURL *url = [NSURL URLWithString:[PASSIM_WEB stringByAppendingFormat:@"","" ]];
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *newsResult = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonParsingError];
      
    }
  }];
  [request setFailedBlock:^{}];
  [request startAsynchronous]; */
}

+ (void) fetchNewsCommentWithNewsId:(NSInteger)new_id withCompleteBlock:(void (^)(NSArray *))handler
{
  NSURL *url =[NSURL URLWithString:[PASSIM_WEB stringByAppendingFormat:@"news/%d/comments", new_id]];
  NSLog(@"comment url: %@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *commentResult = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonParsingError];
      NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[commentResult count]];
      if ([commentResult count] > 0) {
        for (NSDictionary *key in commentResult) {
          [result addObject:key];
          NSLog(@"Comment: %@", key);
        }
      }
      handler(result);
    }
  }];
  [request setFailedBlock:^{}];
  [request startAsynchronous];
}

#pragma mark - private function
- (BOOL) comparedAddress:(NSDictionary *) newAddr
{
  if ([self.addressBook count] == 0 || [newAddr count] == 0) 
    return NO;
  if ([(NSString *)[self.addressBook objectForKey:@"City"] isEqualToString:(NSString *)[newAddr objectForKey:@"City"]]
      && [(NSString *)[self.addressBook objectForKey:@"State"] isEqualToString:(NSString *)[newAddr objectForKey:@"State"]]
      && [(NSString *)[self.addressBook objectForKey:@"Country"] isEqualToString:(NSString *)[newAddr objectForKey:@"Country"]]
      )
    return YES;
  if ([(NSString *)[self.addressBook objectForKey:@"City"] isEqualToString:(NSString *)[newAddr objectForKey:PASSIM_CITY]]
      && [(NSString *)[self.addressBook objectForKey:@"State"] isEqualToString:(NSString *)[newAddr objectForKey:PASSIM_STATE]]
      && [(NSString *)[self.addressBook objectForKey:@"Country"] isEqualToString:(NSString *)[newAddr objectForKey:PASSIM_COUNTRY]])
    return YES;
  return NO;
}

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

- (NSDictionary *) handleJsonReturnData:(ASIHTTPRequest *) request {
  if (request == nil) return nil;
  NSData *data = [request responseData];
  if (data == nil) return nil;
  NSError *jsonParsingError;
  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
  if ([result count] > 0 && [result objectForKey:@"error"] == nil) return result;
  return nil;
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
  return _lastLoadFromNetworkData;
}

- (NSDictionary *)addressBook
{
  if (_addressBook == nil) 
    _addressBook = [[NSDictionary alloc] init];
  return _addressBook;
}

- (newsHandler)newsInRegionHandler
{
  if (_newsInRegionHandler == nil)
    _newsInRegionHandler = ^(NSArray *data) {};
  return _newsInRegionHandler;
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
  NSURL *url = [NSURL URLWithString:[PASSIM_WEB stringByAppendingFormat:@"news_around_basic?origin_geo_lat=%f&origin_geo_long=%f&offset_geo_lat=%f&offset_geo_long=%f", origin.latitude, origin.longitude, span.latitudeDelta, span.longitudeDelta]];
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
      self.lastLoadFromNetworkData = result;
    }
  }];
  [request setFailedBlock:^{
    // Set out notification for failure
  }];
  [request startAsynchronous];
}

- (void)newsBasedOnRegion:(NSDictionary *)address 
                   option:(PMHerokCacheOption)option
        withCompleteBlock:(void (^)(NSArray *))handler
{
  if ([(NSString *)[address objectForKey:@"City"] isEqualToString:@"McFarland"]) {
    [address setValue:@"Madison" forKey:@"City"];  // fix the bug by CoreData
  }
  self.newsInRegionHandler = handler;  // update to latest handler
  if ([self comparedAddress:address] && option == PMHerokCacheFromCache) {
    self.newsInRegionHandler(self.lastLoadFromNetworkData);
    return;
  } 

  self.addressBook = address;
  self.lastLoadFromNetworkData = nil;
  NSString *urlString = [PASSIM_WEB stringByAppendingFormat:@"news_match_full?news_city=%@&&news_state=%@&&news_country=%@",
                        [address objectForKey:@"City"], [address objectForKey:@"State"], [address objectForKey:@"Country"]];
  
  NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
  NSLog(@"url %@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *newsResult = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      // parsing the data
      NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[newsResult count]];
      if ([newsResult count] > 0) {
        for (NSDictionary *key in newsResult) {
          [result addObject: [PMNews newsFromObject:key]];
          NSLog(@"%@", key);
        }
      }
      NSLog(@"finished Parse the return data %@", result);
      self.lastLoadFromNetworkData = result;
      self.newsInRegionHandler(self.lastLoadFromNetworkData);

      if (option == PMHerokCacheForceToStoreToDB || option == PMHerokCacheFailedFromNetworkNowFromDB) {
#warning store to db        
      }
    }
  }];

  [request setFailedBlock:^{
    if (option == PMHerokCacheFailedFromNetworkNowFromDB) {
#warning load from DB
    }
  }];

  [request startAsynchronous];  
}

- (void) postNews:(NSDictionary *)news withCompleteBlock:(void (^)(BOOL))handler
{
  if ([news objectForKey:PASSIM_NEWS_PHOTO_UI] == nil) {
    [self postNewsOnHerok:news flag:PMNetworkFlagAsync withCompleteBlock:handler];
  } else {
    dispatch_queue_t concur = dispatch_queue_create("submit news request concurrent", DISPATCH_QUEUE_CONCURRENT);
    __block BOOL herokCompleted = NO, passimCompleted = NO;
    dispatch_sync(concur, ^{
      [self postNewsOnHerok:news flag:PMNetworkFlagSync
          withCompleteBlock:^(BOOL finished){
        herokCompleted = finished;
      }];
    });
    dispatch_sync(concur, ^{
      [self postNews:news withImage:[news objectForKey:PASSIM_NEWS_PHOTO_UI] flag:PMNetworkFlagSync 
   withCompleteBlock:^(BOOL finished){
        passimCompleted = finished;
      }];
    });
    dispatch_sync(concur, ^{
      NSLog(@"Update news: %@", news);
      if (herokCompleted && passimCompleted) {
        [self postNewsImage:news flag:PMNetworkFlagSync withCompleteBlock:handler];
      } else {
        handler(NO);
      }
    });
    dispatch_release(concur);
  }
}

- (void) postNewsOnHerok:(NSDictionary *)news flag:(PMNetworkFlag)flag withCompleteBlock:(void (^)(BOOL))handler {
  NSString *urlString = [PASSIM_WEB stringByAppendingFormat:@"news/do?screen_name=%@&&news_title=%@&&news_geo_lat=%f&&news_geo_long=%f&&news_date_time=%@&&news_city=%@&&news_country=%@&&news_state=%@&&news_summary=%@&&news_short_address=%@", (NSString *) [news objectForKey:PASSIM_SCREEN_NAME], (NSString *)[news objectForKey:PASSIM_NEWS_TITLE], [[news objectForKey:PASSIM_LATITIUDE] doubleValue], [[news objectForKey:PASSIM_LONGTITUDE] doubleValue], (NSString *)[news objectForKey:PASSIM_DATE_TIME], (NSString *)[news objectForKey:PASSIM_CITY], (NSString *)[news objectForKey:PASSIM_COUNTRY], (NSString *)[news objectForKey:PASSIM_STATE], (NSString *)[news objectForKey:PASSIM_NEWS_SUMMARY], (NSString *)[news objectForKey:PASSIM_NEWS_ADDRESS]];
  NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
  NSLog(@"postNewsOnHerok: %@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];  
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *newsResult = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      NSLog(@"%@", newsResult);
      if ([newsResult count] > 0 && [newsResult objectForKey:@"error"] == nil) {
        if ([self comparedAddress:newsResult]) {
          [self.lastLoadFromNetworkData insertObject:[PMNews newsFromObject: newsResult] atIndex:0];
          [news setValue:[newsResult objectForKey:PASSIM_NEWS_ID] forKey:PASSIM_NEWS_ID];
        }
        handler(YES);
#warning need to notification the update version
        [[NSNotificationCenter defaultCenter] postNotificationName:PMNotificationHerokCacheRequestNewData 
                                                            object:self 
                                                          userInfo:nil];
        return;
      }
    }
    handler(NO);
  }];
  [request setFailedBlock:^{
    handler(NO);
  }];
  if (flag == PMNetworkFlagSync)
    [request startSynchronous];
  else
    [request startAsynchronous];
}

- (void) postNews:(NSDictionary *)news withImage:(UIImage *)image flag:(PMNetworkFlag)flag withCompleteBlock:(void (^)(BOOL))handler
{
  NSString *urlString = @"http://ipassim.com/www/barrio_pic/imageUpload.php";
  NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSLog(@"postNewsImage %@", url);
  ASIFormDataRequest *_request = [ASIFormDataRequest requestWithURL:url];
  __weak ASIFormDataRequest *request = _request;
  [request setPostValue:[news objectForKey:PASSIM_NEWS_AUTHOR] forKey:@"screen_name"];
  [request setCompletionBlock:^() {
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *passimServerResult = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      NSLog(@"Passim Return %@", passimServerResult);
      if ([passimServerResult count] > 0 && [passimServerResult objectForKey:@"error"] == nil) {
        [news setValue:[passimServerResult objectForKey:POST_PASSIM_PHOTO] forKey:PASSIM_NEWS_PHOTO_URL];
        handler(YES);
      } else {
        handler(NO);
      }
    }
  }];
  [request setFailedBlock:^(){ handler(NO);}];
  if (flag == PMNetworkFlagSync)
    [request startSynchronous];
  else 
    [request startAsynchronous];
}

- (void) postNewsImage:(NSDictionary *)news flag:(PMNetworkFlag)flag withCompleteBlock:(void (^)(BOOL))handler
{
  NSString *urlString = [PASSIM_WEB stringByAppendingFormat:@"photo/do?news_id=%d&&photo_url=%@&&screen_name=%@", [news objectForKey:PASSIM_NEWS_ID], [news objectForKey:PASSIM_NEWS_PHOTO_URL], [news objectForKey:PASSIM_NEWS_AUTHOR]];
  NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSLog(@"%@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^(){
    NSData *returnData = [request responseData];
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *photoCreate = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      NSLog(@"%@", photoCreate);
      if ([photoCreate count] > 0 && [photoCreate objectForKey:@"error"] == nil) {
        handler(YES);
        return;
      }
    }
    handler(NO);
  }];
  [request setFailedBlock:^{
    handler(NO);
  }];
  if (flag == PMNetworkFlagSync)
    [request startSynchronous];
  else 
    [request startAsynchronous];
}

- (void)postComment:(NSDictionary *)comment flag:(PMNetworkFlag)flag withCompleteBlock:(void (^)(BOOL))handler 
{
  NSString *urlString = [PASSIM_WEB stringByAppendingFormat:@"comment/do?screen_name=%@&&news_id=%d&&comment_content=%@&&commenter_screen_name=%@", [comment objectForKey:PASSIM_SCREEN_NAME], [[comment objectForKey:PASSIM_NEWS_ID] integerValue], [comment objectForKey:PASSIM_COMMENT], [comment objectForKey:PASSIM_SCREEN_NAME]];
  NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
  NSLog(@"%@", url);
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = [request responseData];  
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *commentResult = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      NSLog(@"%@", commentResult);
      if ([commentResult count] > 0 && [commentResult objectForKey:@"error"] == nil) {
        handler(YES);
        return;
      }
    }
    handler(NO);
  }];
  [request setFailedBlock:^{
    handler(NO);
  }];
  if (flag == PMNetworkFlagSync)
    [request startSynchronous];
  else 
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

- (void) registerAnUser:(NSDictionary *) userInfo 
      withCompleteBlock:(void (^)(BOOL))handler
{
  NSString *urlString = [PASSIM_WEB stringByAppendingFormat:@"user/do?screen_name=%@&&user_name=%@", [userInfo objectForKey:PASSIM_SCREEN_NAME], [userInfo objectForKey:PASSIM_USERNAME]];
  NSURL *url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
  __weak ASIHTTPRequest *request = _request;
  [request setCompletionBlock:^{
    NSData *returnData = request.responseData;
    if (returnData != nil) {
      NSError *jsonParsingError;
      NSDictionary *create_user = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&jsonParsingError];
      if ([create_user objectForKey:@"error"] == nil) {
        handler(YES);
        NSLog(@"create a user");
      } else {
        handler(NO);
        NSLog(@"faile to user");
      }
    }
  }];
  [request setFailedBlock:^{handler(NO);}];
  [request startAsynchronous];
}
@end
