//
//  PMFrontPhotoShowViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMFrontPhotoShowViewController.h"
#import "PMAppDelegate.h"
#import "PMNavigation.h"

#define SLIDE_SHOW_DURIATION 4
#define ANIMATION_DURIATION 0.8
#define MAX_NUM_OF_IMAGE 4
@interface PMFrontPhotoShowViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) NSTimer *animationTimer;
@property (strong, nonatomic) NSArray *imageArray;
@property (nonatomic) int imgIndex;
@end

@implementation PMFrontPhotoShowViewController
@synthesize PMNaviController = _PMNaviController;
@synthesize imageView = _imageView;
@synthesize animationTimer = _animationTimer;
@synthesize imageArray = _imageArray;
@synthesize imgIndex = _imgIndex;

#pragma mark - Setter/Getter
- (NSArray *)imageArray
{
  if (_imageArray == nil) {
    NSMutableArray *imgArray = [[NSMutableArray alloc] initWithCapacity:MAX_NUM_OF_IMAGE];
    for (int i = 0; i < MAX_NUM_OF_IMAGE; i++) {
      UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"TestPhotos%d.jpg", i]];
      //NSLog(@"%@", [NSString stringWithFormat:@"TestPhotos%d.png",i]);
      if (image) [imgArray addObject:image];
    }
    _imageArray = [[NSArray alloc] initWithArray:imgArray];
    _imgIndex = 0; // start from the very beginning
  }
  return _imageArray;
}

#pragma mark - Life Cycle for View Controller
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
  [self setImageView:nil];
  [super viewDidUnload];
  NSLog(@"view did unload");
  // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.view.backgroundColor = [UIColor blackColor];
  if ([self.imageArray count] != 0 ) {
    // start animation if we have images
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:SLIDE_SHOW_DURIATION 
                                                       target:self 
                                                     selector:@selector(fadingOut:) 
                                                     userInfo:nil 
                                                      repeats:NO];
    self.imageView.image = [self.imageArray objectAtIndex:self.imgIndex];
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
  // release any memory holding
  self.imageView.image = nil;
  self.imageArray = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - private function
- (void)fadingIn:(NSTimer *)timer
{
  void(^animationBlock)(void) = ^{
    self.imageView.alpha = 1.0;
  };
  void(^completeBlock)(BOOL) = ^(BOOL finished) {
    if (finished) {
      self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:SLIDE_SHOW_DURIATION 
                                                             target:self 
                                                           selector:@selector(fadingOut:) 
                                                           userInfo:nil 
                                                            repeats:NO];
    }
  };
  [UIView animateWithDuration:ANIMATION_DURIATION 
                        delay:0 
                      options:UIViewAnimationOptionBeginFromCurrentState 
                   animations:animationBlock 
                   completion:completeBlock];
}

- (void)fadingOut:(NSTimer *)timer
{
  void(^animationBlock)(void) = ^{
    self.imageView.alpha = 0.0;
  };
  void(^completedBlock)(BOOL) = ^(BOOL finished) {
    if (finished) {
      self.imgIndex = (++self.imgIndex) % MAX_NUM_OF_IMAGE;
      self.imageView.image = [self.imageArray objectAtIndex:self.imgIndex];
      [self fadingIn:self.animationTimer];
    }
  };
  [UIView animateWithDuration:ANIMATION_DURIATION 
                        delay:0 
                      options:UIViewAnimationOptionBeginFromCurrentState 
                   animations:animationBlock 
                   completion:completedBlock];
}

#pragma mark - Target Action
- (IBAction)twitterSignIn:(UIButton *)sender {
  // send requires to tweeter and decide which way to go on based there
  id delegate =[UIApplication sharedApplication].delegate;
  PMTweeterUtility *tweeter = [delegate valueForKey: PMTWEETERUTILITY_KEY];
  PMHerokCacheRequest *herokRequest = [delegate valueForKey:PMHEROKREQUEST_KEY];
  [tweeter requireAccessUserAccountWithCompleteHandler:^(BOOL granted, BOOL hasAccountInSystem){
    if (granted && hasAccountInSystem) {
      dispatch_queue_t registerUser = dispatch_queue_create("register twitter user", nil);
      dispatch_async(registerUser, ^{
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        [userInfo setValue:[tweeter getDefaultsScreenName] forKey: PASSIM_SCREEN_NAME];
        [tweeter getDefaultsUserInfoWithCompleteHandler:^(NSDictionary* tweeterUserInfo) {
          [userInfo setValue: [tweeterUserInfo objectForKey:@"name"] forKey: PASSIM_USERNAME];
          [herokRequest registerAnUser:userInfo flag: PMNetworkFlagAsync withCompleteBlock:^(BOOL completed) {}];
        }];
      });
      dispatch_release(registerUser);
      [self performSegueWithIdentifier:@"fromPhotoSlideToTabBar" sender:self];
    } else if (granted && !hasAccountInSystem) {
      // I did not know what to do here!!!
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Account Set up" 
                                                      message:@"Need to set up twitter account in Setting App before continue" 
                                                     delegate:self 
                                            cancelButtonTitle:@"OK" 
                                            otherButtonTitles:@"Open Settings", nil];
      [alert show];
      // TODO: show open up Setting App
    } else {
      // not granted
    }
  }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    // open Settings App
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
  }
}

#pragma mark - Segue way preparation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"fromPhotoSlideToTabBar"]) {
    if ([segue.destinationViewController isKindOfClass:[UITabBarController class]] 
        && (self.PMNaviController != nil) 
        && [self.PMNaviController isKindOfClass:[PMNavigation class]] ) {
      // set up delegate, and link between Navi and TabBar controller
      [segue.destinationViewController setValue:self.PMNaviController forKey:@"delegate"];
      [self.PMNaviController setValue:segue.destinationViewController forKey:@"viewController"];
      [self.PMNaviController tabBar:segue.destinationViewController addTabBarArrowFor:0]; 
    }
  } else {
    // Something wrong with it.
    NSLog(@"We need to crash here!");
  }
}

@end
