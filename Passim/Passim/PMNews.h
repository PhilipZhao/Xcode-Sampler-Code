//
//  PMNews.h
//  Passim
//
//  Created by Philip Zhao on 1/27/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PMStandKeyConstant.h"

@interface PMNews : NSObject
@property (strong, nonatomic) NSDictionary *newsData;
@property (strong, nonatomic) UIImage *frontPhoto;

+ (PMNews *) newsToObject: (NSDictionary *) newsData;

- (void) getNewsFrontPhotoWithBlock:(void (^)(UIImage *)) handler;
- (void) getNewsAllPhotoWithBlock:(void (^)(NSArray *)) handler;

- (NSString *) newsTitle;
- (NSString *) newsSummary;
- (NSString *) newsAuthor;
- (NSString *) newsDate;
- (NSInteger)  newsId;
- (CLLocationCoordinate2D) newsCoordinate;
- (UIImage *) newsFrontPhoto;
@end
