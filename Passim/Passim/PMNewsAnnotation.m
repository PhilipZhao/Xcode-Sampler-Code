//
//  PMNewsAnnotation.m
//  Passim
//
//  Created by Philip Zhao on 1/15/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMNewsAnnotation.h"
#import "PMStandKeyConstant.h"

@implementation PMNewsAnnotation
@synthesize news = _news;
@synthesize news_id = _news_id;

+ (PMNewsAnnotation *)annotationForNews:(NSDictionary *)news
{
  PMNewsAnnotation *annotation = [[PMNewsAnnotation alloc] init];
  annotation.news = news;
  return annotation;
}

- (NSString *)title
{
  return [self.news objectForKey:PASSIM_NEWS_TITLE];
}

- (NSString *)subtitle
{
  return [self.news objectForKey:PASSIM_NEWS_AUTHOR];
}

- (CLLocationCoordinate2D)coordinate
{
  CLLocationCoordinate2D coordinate;
  coordinate.latitude = [[self.news objectForKey:PASSIM_LATITIUDE] doubleValue];
  coordinate.longitude = [[self.news objectForKey:PASSIM_LONGTITUDE] doubleValue];
  return coordinate;
}

- (NSInteger)news_id
{
  NSInteger news_id = [[self.news objectForKey:PASSIM_NEWS_ID] intValue];
  return news_id;
}

@end
