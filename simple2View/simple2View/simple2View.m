//
//  simple2View.m
//  simple2View
//
//  Created by Philip Zhao on 12/31/11.
//  Copyright (c) 2011 University of Wisconsin-Madison. All rights reserved.
//

#import "simple2View.h"
#define degree2Raidus(x) (M_PI*(x)/180.0)
@implementation simple2View
@synthesize protrait;
@synthesize landscape;
@synthesize foo = _foo;
@synthesize bar = _bar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
  [self setProtrait:nil];
  [self setLandscape:nil];
  [self setFoo:nil];
  [self setBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
  if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
    self.view = self.protrait;
    self.view.transform = CGAffineTransformIdentity;
    self.view.transform = CGAffineTransformMakeRotation(degree2Raidus(0));
    self.view.bounds = CGRectMake(0.0, 0.0, 320.0, 460.0);
  } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
    self.view = self.protrait;
    self.view.transform = CGAffineTransformIdentity;
    self.view.transform = CGAffineTransformMakeRotation(degree2Raidus(90));
    self.view.bounds = CGRectMake(0.0, 0.0, 320.0, 460.0);
  } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
    self.view = self.landscape;
    self.view.transform = CGAffineTransformIdentity;
    self.view.transform = CGAffineTransformMakeRotation(degree2Raidus(-90));
    self.view.bounds = CGRectMake(0.0, 0.0, 460.0, 320.0);
  } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
    self.view = self.landscape;
    self.view.transform = CGAffineTransformIdentity;
    self.view.transform = CGAffineTransformMakeRotation(degree2Raidus(90));
    self.view.bounds = CGRectMake(0.0, 0.0, 460.0, 320.0);
  }
}

- (IBAction)fooTap:(id)sender 
{
  if ([self.foo containsObject:sender]) {
    NSLog(@"fooTap with Item %d", [self.foo count]);
    for (UIButton * foo in self.foo) {
      foo.hidden = YES;
    }
  }
}

- (IBAction)barTap:(id)sender 
{
  if ([self.bar containsObject:sender]) {
    NSLog(@"barTap with Items %d", [self.bar count]);
    for (UIButton * bar in self.bar) {
      bar.hidden = YES;
    }
  }
}
@end
