//
//  PMNavigation.m
//  Passim
//
//  Created by Philip Zhao on 1/14/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMNavigation.h"
#import "PMAppDelegate.h"

#define TAB_SELECTED_INDEX @"tabSelectedIndex"
@interface PMNavigation()
@property (weak, nonatomic) id viewController;
@end

@implementation PMNavigation
@synthesize viewController = _viewController;

- (void) viewDidLoad
{
  [super viewDidLoad];
  NSLog(@"Navigation: viewDidLoad");
  UIViewController *vc;
  UIApplication *app = [UIApplication sharedApplication];
  id appDelegate = app.delegate;
  PMTweeterUtility *tweeterUtil = [appDelegate valueForKey:PMTWEETERUTILITY_KEY];
  if (![tweeterUtil canAccessTweeter]) {
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"fronPhotoShowController"];
  } else {
    [tweeterUtil requireAccessUserAccountWithCompleteHandler:^(BOOL granted){}];
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
  }
  [self presentViewController:vc animated:NO completion:^{
    if ([vc isKindOfClass:[UITabBarController class]]) {
      // retrieve user information
      UITabBarController *tabBarController = (UITabBarController *)vc;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSInteger value = [[defaults stringForKey:TAB_SELECTED_INDEX] integerValue];
      tabBarController.selectedIndex = value;
    }
    // init to set up delegate?
  }];

  self.viewController = vc;
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(saveCurrentStatus:) 
                                               name:UIApplicationDidEnterBackgroundNotification object:app];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  NSLog(@"Navigation: viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  NSLog(@"Naviagtion: viewWillDisappar");
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  NSLog(@"Navigation: viewDidUnload");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveCurrentStatus:(NSNotification *) notification
{
  NSLog(@"%@", NSStringFromSelector(_cmd));
  if ([self.viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController = (UITabBarController *)self.viewController;
    // write to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSString stringWithFormat:@"%d", tabController.selectedIndex] 
                forKey:TAB_SELECTED_INDEX];
    [defaults synchronize];
  }
}
@end
