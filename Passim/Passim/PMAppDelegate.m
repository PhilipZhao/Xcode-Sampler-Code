//
//  PMAppDelegate.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMAppDelegate.h"


@interface PMAppDelegate()

@end
@implementation PMAppDelegate

@synthesize window = _window;
@synthesize sharedUtility = _sharedUtility;
@synthesize sharedTweeterUtility = _sharedTweeterUtility;
@synthesize sharedHerokRequest = _sharedHerokRequest;

#pragma mark - Setter/Getter
- (PMLocationUtility *)sharedUtility
{
  if (_sharedUtility == nil) {
    _sharedUtility = [[PMLocationUtility alloc] init];
  }
  return _sharedUtility;
}

- (PMTweeterUtility *)sharedTweeterUtility 
{
  if (_sharedTweeterUtility == nil) {
    _sharedTweeterUtility = [[PMTweeterUtility alloc] init];
  }
  return _sharedTweeterUtility;
}

- (PMHerokCacheRequest *)sharedHerokRequest
{
  if (_sharedHerokRequest == nil) {
    _sharedHerokRequest = [[PMHerokCacheRequest alloc] init];
  }
  return _sharedHerokRequest;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
   [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault ];
  NSLog(@"%@", NSStringFromSelector(_cmd));
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
