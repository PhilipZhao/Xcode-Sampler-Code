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
#define TAB_BAR_HEIGHT 49
#define TAB_BAR_WIDE 320
#define TAB_ITEM_COUNT 4
@interface PMNavigation()
@property (weak, nonatomic) id viewController;
@property (strong, nonatomic) UIImageView *tabBarArrow;
@property (strong, nonatomic) NSMutableDictionary *glowNotificationArray;

@end

@implementation PMNavigation
@synthesize viewController = _viewController;
@synthesize tabBarArrow = _tabBarArrow;
@synthesize glowNotificationArray = _glowNotificationArray;

#pragma mark - private function
- (NSInteger) tagForTabBarWithIndex:(NSUInteger) tabIndex
{
  NSInteger tagValue = tabIndex + 100;
  return tagValue;
}

- (CGFloat)tabBar:(UITabBarController *)tabBarController horizontalLocationFor:(NSUInteger)tabIndex
{
  // A single tab item's width is the entire width of the tab bar divided by number of items
  CGFloat tabItemWidth = tabBarController.tabBar.frame.size.width / TAB_ITEM_COUNT;
  // A half width is tabItemWidth divided by 2 minus half the width of the arrow
  CGFloat halfTabItemWidth = (tabItemWidth / 2.0) - (self.tabBarArrow.frame.size.width / 2.0);
  
  // The horizontal location is the index times the width plus a half width
  return (tabIndex * tabItemWidth) + halfTabItemWidth;
}

- (void)tabBar:(UITabBarController *) tabBar addTabBarArrowFor:(NSUInteger) tabIndex;
{
  UIImage* tabBarArrowImage = [UIImage imageNamed:@"TabBarNipple.png"];
  self.tabBarArrow = [[UIImageView alloc] initWithImage:tabBarArrowImage];
  // To get the vertical location we start at the bottom of the window, 
  // go up by height of the tab bar, go up again by the height of arrow and then
  // come back down 2 pixels so the arrow is slightly on top of the tab bar.
  CGFloat verticalLocation = tabBar.view.frame.size.height - 
                             tabBar.tabBar.frame.size.height - 
                             tabBarArrowImage.size.height + 2;
  self.tabBarArrow.frame = CGRectMake([self tabBar:tabBar horizontalLocationFor:tabIndex], 
                                      verticalLocation, 
                                      tabBarArrowImage.size.width, 
                                      tabBarArrowImage.size.height);
  
  [tabBar.view addSubview:self.tabBarArrow];
}

- (void)tabBar:(UITabBarController *)tabBar addGlowingNotification:(NSUInteger)tabIndex
{
  if ([tabBar.view viewWithTag:[self tagForTabBarWithIndex:tabIndex]] == nil) {
    UIImage *glowingImage = [UIImage imageNamed:@"TabBarGlow.png"];
    UIImageView *glowingView = [[UIImageView alloc] initWithImage:glowingImage];
    CGFloat verticalLocation = tabBar.view.frame.size.height - glowingImage.size.height;
    glowingView.frame = CGRectMake([self tabBar:tabBar horizontalLocationFor:tabIndex], verticalLocation, glowingImage.size.width, glowingImage.size.height);
    //[self.glowNotificationArray setObject:glowingView forKey:[NSNumber numberWithInt:tabIndex]];
    glowingView.tag = [self tagForTabBarWithIndex:tabIndex];
    [tabBar.view addSubview:glowingView];
  }
}

#pragma mark - Life cycle
- (void) viewDidLoad
{
  [super viewDidLoad];
  UIViewController *vc;
  UIApplication *app = [UIApplication sharedApplication];
  id appDelegate = app.delegate;
  PMTweeterUtility *tweeterUtil = [appDelegate valueForKey:PMTWEETERUTILITY_KEY];
  if (![tweeterUtil canAccessTweeter]) {
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"fronPhotoShowController"];
    [vc setValue:self forKey:@"PMNaviController"];
  } else {
    [tweeterUtil requireAccessUserAccountWithCompleteHandler:^(BOOL granted, BOOL hasAccountInSystem){}];
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    if ([vc isKindOfClass:[UITabBarController class]]) {
      [vc setValue:self forKey:@"delegate"];  // set up tab bar delegatation
      // retrieve user information
      UITabBarController *tabBarController = (UITabBarController *)vc;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSInteger value = [[defaults stringForKey:TAB_SELECTED_INDEX] integerValue];
      tabBarController.selectedIndex = value;
      [self tabBar:tabBarController addTabBarArrowFor:value];
    }
  }
  [self presentViewController:vc animated:NO completion:^{}];

  self.viewController = vc;
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(saveCurrentStatus:) 
                                               name:UIApplicationDidEnterBackgroundNotification object:app];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification implementation
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

- (void)notificationForTabBar:(NSNotification *) notification
{
  
}

#pragma mark - TabBar Delegatation implementation
- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
  // remove the glowing if it exist
  if ([theTabBarController.view viewWithTag:[self tagForTabBarWithIndex:theTabBarController.selectedIndex]] != nil) {
    [[theTabBarController.view viewWithTag:[self tagForTabBarWithIndex:theTabBarController.selectedIndex]] removeFromSuperview];
  }
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2];
  CGRect frame = self.tabBarArrow.frame;
  frame.origin.x = [self tabBar:theTabBarController horizontalLocationFor:theTabBarController.selectedIndex];
  self.tabBarArrow.frame = frame;
  [UIView commitAnimations];  
}

@end
