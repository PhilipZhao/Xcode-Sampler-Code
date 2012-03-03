//
//  PMNews.m
//  Passim
//
//  Created by Philip Zhao on 1/27/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMNews.h"
#import "PMStandKeyConstant.h"
#import "PMHerokCacheRequest.h"
#import "NSDate+StringParsing.h"

@implementation PMNews
@synthesize newsData = _newsData;
@synthesize frontPhoto = _frontPhoto;
@synthesize newsComments = _newsComments;

+ (PMNews *) newsFromObject:(NSDictionary *)newsData
{
  PMNews *news = [[PMNews alloc] init];
  news.newsData = newsData;
  return news;
}

#pragma mark - implement all the public function
- (NSString *) newsTitle 
{
  return [self.newsData objectForKey:PASSIM_NEWS_TITLE];
}

- (NSString *) newsSummary
{
  return [self.newsData objectForKey:PASSIM_NEWS_SUMMARY];
}

- (NSString *) newsAuthor
{
  return [self.newsData objectForKey:PASSIM_USERNAME];
}

- (NSString *) newsScreenName
{
  return [self.newsData objectForKey:PASSIM_NEWS_AUTHOR];
}

- (NSDate *) newsDate
{
  NSString* date_time = [self.newsData objectForKey:PASSIM_DATE_TIME];
  NSDate* newsDateTime = [NSDate dateWithISO8601String:date_time];
  return newsDateTime;
}

- (PMNewsDateTime) newsDateTimeByAgo
{
  NSString* date_time = [self.newsData objectForKey:PASSIM_DATE_TIME];
  NSDate* newsDateTime = [NSDate dateWithISO8601String:date_time];
  NSTimeInterval interval = abs([newsDateTime timeIntervalSinceNow]);
  PMNewsDateTime dateTime;
  if (interval < 60) {
    dateTime.timeSinceNow = (NSInteger) abs(interval);
    dateTime.ago = PMSecondAgo;
  } else if (interval < 60*60) {
    dateTime.timeSinceNow = (NSInteger) (abs(interval)/(60));
    dateTime.ago = PMMinuteAgo;
  } else if (interval < 60*60*24) {
    dateTime.timeSinceNow = (NSInteger) (abs(interval)/(60*60));
    dateTime.ago = PMHourAgo;
  } else {
    dateTime.timeSinceNow = (NSInteger) (abs(interval)/(60*60*24));
    dateTime.ago = PMDayAgo;
  }
  return dateTime;
}

- (NSString *) newsAddress
{
  if ([[self.newsData objectForKey:PASSIM_NEWS_ADDRESS] length] == 0) return nil;
  return [self.newsData objectForKey:PASSIM_NEWS_ADDRESS];
}

- (NSInteger) newsId
{
  return [[self.newsData objectForKey:PASSIM_NEWS_ID] intValue];
}

- (CLLocationCoordinate2D)newsCoordinate
{
  CLLocationCoordinate2D coordinate;
  coordinate.latitude = [[self.newsData objectForKey:PASSIM_LATITIUDE] doubleValue];
  coordinate.longitude = [[self.newsData objectForKey:PASSIM_LONGTITUDE] doubleValue];
  return coordinate;
}

- (UIImage *) newsFrontPhoto
{
  NSLog(@"%@", self.frontPhoto);
  return self.frontPhoto;
}

- (NSURL *) newsFrontPhotoURL
{
  NSString *url = [self.newsData objectForKey:PASSIM_NEWS_FRONT_PHOTO_URL];
  if (url != [NSNull null])  // protection bar here. Need to remove in the future
    return [NSURL URLWithString:
            [(NSString *)[self.newsData objectForKey:PASSIM_NEWS_FRONT_PHOTO_URL] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
  else 
    return nil;
}

- (void) getNewsFrontPhotoWithBlock:(void (^)(UIImage *))handler
{
  if (self.frontPhoto == nil) {
    // request through network
    [PMHerokCacheRequest fetchPhotoWithURL:[self newsFrontPhotoURL] 
                                       option:PMHerokPhotoFront 
                                         flag:PMNetworkFlagAsync
                            withCompleteBlock:^(NSArray *photos) {
      if ([photos count] != 0) self.frontPhoto =[photos objectAtIndex:0]; 
      dispatch_async(dispatch_get_main_queue(), ^{
        handler(self.frontPhoto);
      });
    }];
  } else {
    handler(self.frontPhoto);
  }
}

- (void)getNewsAllPhotoWithBlock:(void (^)(NSArray *))handler
{
  
}

- (void)getNewsCommentWithHandler:(void (^)(NSArray *))handler
{
  if (self.newsComments == nil) {
     [PMHerokCacheRequest fetchNewsCommentWithNewsId:[self newsId] 
                                   withCompleteBlock:^(NSArray *comments) {
     self.newsComments = comments;
     dispatch_async(dispatch_get_main_queue(), ^{
       if ([comments count] == 0) handler(nil);
       else
         handler(self.newsComments);
     });}];
  } else 
    handler(self.newsComments);
}

@end
