//
//  PMNewsAnnotation.h
//  Passim
//
//  Created by Philip Zhao on 1/15/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PMNews.h"
@interface PMNewsAnnotation : NSObject <MKAnnotation>

+ (PMNewsAnnotation *)annotationForNewsObject:(PMNews *)news;

@property (strong, nonatomic) PMNews *news;

- (NSInteger) news_id;
@end
