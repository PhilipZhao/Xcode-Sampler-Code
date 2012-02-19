//
//  NSDate+StringParsing.m
//  Passim
//
//  Created by Philip Zhao on 2/19/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "NSDate+StringParsing.h"

@implementation NSDate (StringParsing)
+ (NSDate *)dateWithISO8601String:(NSString *)dateString
{
  if (!dateString) return nil;
  if ([dateString hasSuffix:@"Z"]) {
    dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"-0000"];
  }
  return [self dateFromString:dateString
                   withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDate *)dateFromString:(NSString *)dateString 
                withFormat:(NSString *)dateFormat 
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:dateFormat];
  
  NSLocale *locale = [[NSLocale alloc] 
                      initWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:locale];
  
  NSDate *date = [dateFormatter dateFromString:dateString];
  return date;
}
@end
