//
//  PMNotification.h
//  Passim
//
//  Created by Philip Zhao on 1/16/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PMNotificationNetwork <NSObject>

@end

#define PMNotificationLocationNewLocation @"PMNotificationLocationNewLocation"
#define PMInfoCLLocation @"PMInfoCLLocation"
@protocol PMNotificationLocation <NSObject>
@optional
- (void)notificationReceiveNewLocation:(NSNotification *)notification;

@end