//
//  PMAppDelegate.h
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMLocationUtility.h"
#import "PMTweeterUtility.h"
#import "PMHerokCacheRequest.h"

#define PMTWEETERUTILITY_KEY @"sharedTweeterUtility"
#define PMUTILITY_KEY @"sharedUtility"
#define PMHEROKREQUEST_KEY @"sharedHerokRequest"

@interface PMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PMLocationUtility* sharedUtility; // a utitly object that shared across VC
@property (strong, nonatomic) PMTweeterUtility *sharedTweeterUtility;
@property (strong, nonatomic) PMHerokCacheRequest *sharedHerokRequest;
@end
