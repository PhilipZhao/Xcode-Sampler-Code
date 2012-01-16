//
//  PMTestViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/14/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMTestViewController.h"
#import "PMAppDelegate.h"

@interface PMTestViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PMTestViewController
@synthesize imageView = _imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    // Implement loadView to create a view hierarchy programmatically, without using a nib.
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
  //self.view.backgroundColor = [UIColor whiteColor];
  UIApplication *app = [UIApplication sharedApplication];
  id delegate = app.delegate;
  PMTweeterUtility *tweeterUtil = [delegate valueForKey:PMTWEETERUTILITY_KEY];
  self.imageView.image = [tweeterUtil getCurrentUserProfile];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
