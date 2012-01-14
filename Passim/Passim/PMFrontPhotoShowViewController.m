//
//  PMFrontPhotoShowViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMFrontPhotoShowViewController.h"

#define SLIDE_SHOW_DURIATION 1
#define ANIMATION_DURIATION 0.5
#define MAX_NUM_OF_IMAGE 4
@interface PMFrontPhotoShowViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) NSTimer *animationTimer;
@property (strong, nonatomic) NSArray *imageArray;
@property (nonatomic) int imgIndex;
@end

@implementation PMFrontPhotoShowViewController
@synthesize imageView = _imageView;
@synthesize animationTimer = _animationTimer;
@synthesize imageArray = _imageArray;
@synthesize imgIndex = _imgIndex;

#pragma mark - Setter/Getter
- (NSArray *)imageArray
{
  if (_imageArray == nil) {
    NSMutableArray *imgArray = [[NSMutableArray alloc] initWithCapacity:MAX_NUM_OF_IMAGE];
    for (int i = 0; i < [imgArray count]; i++) {
      UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"frontPhotoShow%d.png", i]];
      [imgArray addObject:image];
    }
    _imageArray = [NSArray arrayWithArray:imgArray];
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
  // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.view.backgroundColor = [UIColor blackColor];
  self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:SLIDE_SHOW_DURIATION 
                                                       target:self 
                                                     selector:@selector(fadingOut:) 
                                                     userInfo:nil 
                                                      repeats:NO];
  self.imageView.image = [self.imageArray objectAtIndex:self.imgIndex];
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
  
}

@end
