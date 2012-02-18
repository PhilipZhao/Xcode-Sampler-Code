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
//@synthesize news_id = _news_id;

/*
+ (PMNewsAnnotation *)annotationForNews:(NSDictionary *)news
{
  PMNewsAnnotation *annotation = [[PMNewsAnnotation alloc] init];
  //annotation.news = news;
  return annotation;
}*/

+ (PMNewsAnnotation *)annotationForNewsObject:(PMNews *)news
{
  PMNewsAnnotation *annotation = [[PMNewsAnnotation alloc] init];
  annotation.news = news;
  return annotation;
}
- (NSString *)title
{
  //return [self.news objectForKey:PASSIM_NEWS_TITLE];
  return [self.news newsTitle];
}

- (NSString *)subtitle
{
  //return [self.news objectForKey:PASSIM_NEWS_AUTHOR];
  return [self.news newsAuthor];
}

- (CLLocationCoordinate2D)coordinate
{
  return [self.news newsCoordinate];
}

- (NSInteger)news_id
{
  //NSInteger news_id = [[self.news objectForKey:PASSIM_NEWS_ID] intValue];
  //return news_id;
  return [self.news newsId];
}

@end
