//
//  PMDetailNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/20/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMDetailNewsViewController.h"
#import "PMAppDelegate.h"

#define TAG_PROFILE 4
#define TAG_AUTHOR 1
#define TAG_SCREEN_NAME 2
#define TAG_BY_WHEN 3
#define TAG_COMMENT 5
#define TAG_SUMMARY 6

@interface PMDetailNewsViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goBackPreviousViewButton;
@property (weak, nonatomic) PMHerokCacheRequest *sharedHerokRequest;
@property (weak, nonatomic) PMTweeterUtility *tweeterUtil;

@end

@implementation PMDetailNewsViewController
@synthesize barItemTitle = _barItemTitle;
@synthesize goBackPreviousViewButton = _goBackPreviousViewButton;
@synthesize sharedHerokRequest = _sharedHerokRequest;
@synthesize tweeterUtil = _tweeterUtil;
@synthesize newsData = _newsData;

#pragma mark - setter/getter
- (void) setNewsData:(PMNews *)newsData
{
  _newsData = newsData;
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

- (void)compositeForAuthorCell:(UITableViewCell *) cell {
  UILabel *creator_name = (UILabel *)[cell viewWithTag:TAG_AUTHOR];
  UILabel *screen_name = (UILabel *)[cell viewWithTag:TAG_SCREEN_NAME];
  UIImageView* profile = (UIImageView *)[cell viewWithTag:TAG_PROFILE];
  screen_name.text = [@"@" stringByAppendingFormat:@"%@", [self.newsData newsAuthor]];
  NSLog(@"%@", [self.newsData newsAuthor]);
  [self.tweeterUtil loadUserProfile:[self.newsData newsAuthor] withCompleteHandler:^(UIImage *profilePic) {
    profile.image = profilePic;
  }];
}

- (void)compositeForNewsCell:(UITableViewCell *) cell {
  UILabel* summary = (UILabel *)[cell viewWithTag:TAG_SUMMARY];
  summary.text = [self.newsData newsSummary];
}

- (void)compositeForCommentCell:(UITableViewCell *) cell {
  UILabel* commenter = (UILabel *)[cell viewWithTag:TAG_AUTHOR];
  UILabel* by_when = (UILabel *)[cell viewWithTag:TAG_BY_WHEN];
  UILabel* comment = (UILabel *)[cell viewWithTag:TAG_COMMENT];
  UIImageView *profile = (UIImageView *)[cell viewWithTag:TAG_PROFILE];
  
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
  id delegate = [[UIApplication sharedApplication] delegate];
  self.sharedHerokRequest = [delegate valueForKey:PMHEROKREQUEST_KEY];
  self.tweeterUtil = [delegate valueForKey:PMTWEETERUTILITY_KEY];
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
  // load news
  [self.newsData getNewsCommentWithHandler:^(NSArray *data) {
  }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Target action
- (IBAction)goBackPreviousView:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table View implementation
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // un-implemented
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 2;
  } else {
    if (self.newsData.newsComments == nil)
      return 1;
    else 
      return [self.newsData.newsComments count]; // need to changed
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 2; // 2 cells. One for Story & Comment
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
  if (section == 0) {
    return @"";
  } else {
    return @"Replies";
  }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifierForAuthor = @"cell for author";
  static NSString *CellIdentifierForNews = @"cell for news";
  static NSString *CellIdentifierForComment = @"cell for comment";
  NSString *cellID;
  if (indexPath.row == 0 && indexPath.section == 0)
    cellID = CellIdentifierForAuthor;
  else if (indexPath.row == 1 && indexPath.section == 0) 
    cellID = CellIdentifierForNews;
  else
    cellID = CellIdentifierForComment;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil) {
    NSLog(@"What is going here, cell==nil: %@", cellID);
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
  }
  if (indexPath.row == 0 && indexPath.section == 0) 
    [self compositeForAuthorCell:cell];
  else if (indexPath.row == 1 && indexPath.section == 0)
    [self compositeForNewsCell:cell];
  else 
    [self compositeForCommentCell:cell];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0 && indexPath.section == 0) {
    return 64;
  } else if (indexPath.row == 1 && indexPath.section == 0) {
    return 100;
  } else {
    return 62;
  }
}


@end
