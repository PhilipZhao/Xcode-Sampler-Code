//
//  PMDetailNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/20/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMDetailNewsViewController.h"

@interface PMDetailNewsViewController ()

@end

@implementation PMDetailNewsViewController
@synthesize news_id = _news_id;

#pragma mark - setter/getter
- (void)setNews_id:(NSInteger)news_id
{
  if (_news_id != news_id) {
    _news_id = news_id;
    // reload from the network
  }
}

#pragma mark - Life cycle
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
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (IBAction)goBackPreviousView:(id)sender {
  //self.modalPresentationStyle = UIModalTransitionStyleFlipHorizontal;
  [self dismissModalViewControllerAnimated:YES];
}
@end
