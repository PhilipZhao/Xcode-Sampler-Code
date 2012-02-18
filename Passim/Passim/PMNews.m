//
//  PMNews.m
//  Passim
//
//  Created by Philip Zhao on 1/27/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMNews.h"
#import "PMHerokCacheRequest.h"

@implementation PMNews
@synthesize newsData = _newsData;
@synthesize frontPhoto = _frontPhoto;
@synthesize newsComments = _newsComments;

+ (PMNews *) newsToObject:(NSDictionary *)newsData
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
  return [self.newsData objectForKey:PASSIM_NEWS_AUTHOR];
}

- (NSString *) newsDate
{
  return @"need to format the date";
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
  return self.frontPhoto;
}

- (void) getNewsFrontPhotoWithBlock:(void (^)(UIImage *))handler
{
  if (self.frontPhoto == nil) {
    // request through network
    [PMHerokCacheRequest fetchPhotoWithNewsId:[self newsId] 
                                       option:PMHerokPhotoFront 
                            withCompleteBlock:^(NSArray *photos) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if ([photos count] == 0) handler(nil);
        else {
          self.frontPhoto = [photos objectAtIndex:0];
          handler(self.frontPhoto);
        }
      });
    }];
  } else {
    handler(self.frontPhoto);
  }
}

- (void)getNewsComment:(void (^)(NSArray *))handler
{
  if (self.newsComments == nil) {
     [PMHerokCacheRequest fetchNewsCommentWithNewsId:[self newsId] 
                                   withCompleteBlock:^(NSArray *comments) {
     dispatch_async(dispatch_get_main_queue(), ^{
       if ([comments count] == 0) handler(nil);
       else {
         self.newsComments = comments;
         handler(self.newsComments);
       }
     });}];
  } else {
    handler(self.newsComments);
  }
}

@end
