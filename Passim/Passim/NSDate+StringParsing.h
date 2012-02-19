//
//  NSDate+StringParsing.h
//  Passim
//
//  Created by Philip Zhao on 2/19/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (StringParsing)
+ (NSDate *)dateWithISO8601String:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString 
                withFormat:(NSString *)dateFormat;
@end
