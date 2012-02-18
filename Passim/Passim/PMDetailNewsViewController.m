//
//  PMDetailNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/20/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMDetailNewsViewController.h"
#define NEWS_VIEW @"cell for news"
#define COMMENT_VIEW @"cell for comment"

@interface PMDetailNewsViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goBackPreviousViewButton;

@end

@implementation PMDetailNewsViewController
@synthesize barItemTitle = _barItemTitle;
@synthesize goBackPreviousViewButton = _goBackPreviousViewButton;
@synthesize news_id = _news_id;

#pragma mark - setter/getter
- (void)setNews_id:(NSInteger)news_id
{
  if (_news_id != news_id) {
    _news_id = news_id;
    // reload from the network
  }
}

- (void) setBarItemTitle:(NSString *)barItemTitle 
{
  _barItemTitle = barItemTitle;
}
- (NSString *)barItemTitle {
  if (_barItemTitle == nil || [_barItemTitle length] <= 0)
    return @"Return";
  else
    return _barItemTitle;
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
  [self setGoBackPreviousViewButton:nil];
  [self setGoBackPreviousViewButton:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.goBackPreviousViewButton.title = self.barItemTitle;
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
