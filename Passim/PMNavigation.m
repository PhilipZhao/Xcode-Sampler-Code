//
//  PMNavigation.m
//  Passim
//
//  Created by Philip Zhao on 1/14/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMNavigation.h"

#define TAB_SELECTED_INDEX @"tabSelectedIndex"
@interface PMNavigation()
@property (strong, nonatomic) id viewController;
@end

@implementation PMNavigation
@synthesize viewController = _viewController;

- (void) viewDidLoad
{
  [super viewDidLoad];
  NSLog(@"Navigation: viewDidLoad");
  static NSInteger value = 0;
  UIViewController *vc;
  
  if (value == 1) {
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"fronPhotoShowController"];
  } else {
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
  }
  [self presentViewController:vc animated:NO completion:^{
    NSLog(@"complete presentViewController");
    if ([vc isKindOfClass:[UITabBarController class]]) {
      // retrieve user information
      NSLog(@"I am Tab Bar Controller");
      UITabBarController *tabBarController = (UITabBarController *)vc;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSInteger value = [[defaults stringForKey:TAB_SELECTED_INDEX] integerValue];
      tabBarController.selectedIndex = value;
    }
  }];
  self.viewController = vc;
  UIApplication *app = [UIApplication sharedApplication];
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
  if (self.viewController == nil) {
    NSLog(@"too sad");
  }
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
    NSLog(@"I am Tab Bar Controller and I ready to syn with user default");
    UITabBarController *tabController = (UITabBarController *)self.viewController;
    // write to file
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSString stringWithFormat:@"%d", tabController.selectedIndex] forKey:TAB_SELECTED_INDEX];
    [defaults synchronize];
  }
}
@end
