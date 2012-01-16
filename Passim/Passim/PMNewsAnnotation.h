//
//  PMNewsAnnotation.h
//  Passim
//
//  Created by Philip Zhao on 1/15/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PMNewsAnnotation : NSObject <MKAnnotation>

+ (PMNewsAnnotation *)annotationForNews:(NSDictionary *)news;  // passim news data input.

@property (nonatomic) NSInteger news_id;
@property (strong, nonatomic) NSDictionary *news;  // news store min amount news information
@end
