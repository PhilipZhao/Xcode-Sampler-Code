//
//  PMComposeNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/18/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMComposeNewsViewController.h"

@implementation PMComposeNewsViewController
@synthesize completionHandler = _completionHandler;

#pragma mark - Setter/Getter
- (PMComposeViewControllerCompletionHandler) completionHandler
{
  if (_completionHandler == nil) {
    _completionHandler = ^(PMComposeViewControllerResult rs){};
  }
  return _completionHandler;
}
#pragma mark - Life cycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  NSLog(@"Composite News View Load");
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
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

- (IBAction)submitNews:(id)sender {
  // error checking and make sure it is OK.
  self.completionHandler(PMComposeViewControllerResultDone);
}

- (IBAction)cancelSumbit:(id)sender {
  self.completionHandler(PMComposeViewControllerResultCancelled);
}
@end
