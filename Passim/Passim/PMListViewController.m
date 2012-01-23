//
//  PMListViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/14/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMAppDelegate.h"
#import "PMListViewController.h"
#import "PMHerokCacheRequest.h"
#import "PMComposeNewsViewController.h"

#define SEGUE_SHOW_NEWS @"showNewsDetail"
#define TAG_TITILE  1
#define TAG_WHO     2
#define TAG_AGO     3
#define TAG_IMG     4

@interface PMListViewController ()
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL reloadTable;
@property (strong, nonatomic) NSArray *tableData;
@property (weak, nonatomic) PMLocationUtility *sharedUtility;
@property (weak, nonatomic) PMHerokCacheRequest *sharedHerokRequest;
@end

@implementation PMListViewController
@synthesize tableView = _tableView;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize reloadTable = _reloadTable;
@synthesize tableData = _tableData;
@synthesize sharedUtility = _sharedUtilty;
@synthesize sharedHerokRequest = _sharedHerokRequest;

#pragma mark - Setter/Getter
- (EGORefreshTableHeaderView *)refreshTableHeaderView 
{
  if (_refreshTableHeaderView == nil) {
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshTableHeaderView.delegate = self;
  }
  return _refreshTableHeaderView;
}

- (void) setTableData:(NSArray *)tableData
{
  if (_tableData != tableData) {
    _tableData = tableData;
    [self.tableView reloadData];
  }
}

#pragma mark - Private Function
- (void) reloadTableViewDataSource 
{
#warning incompleted implementation
  // submit request to Server to reload data information
  self.reloadTable = YES;
}

- (void)doneLoadingTableViewData
{
#warning incompleted implementation
	//  model should call this when its done loading
	self.reloadTable = NO;
	[self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];	
}

#pragma mark - Segue way
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:SEGUE_SHOW_NEWS]) {
#warning need to implement
  } else if ([segue.identifier isEqualToString:SEGUE_COMPOSITE_NEWS]) {
    if ([segue.destinationViewController isKindOfClass:[PMComposeNewsViewController class]]) {
      NSLog(@"segueway correct");
      PMComposeNewsViewController *vc = (PMComposeNewsViewController *)segue.destinationViewController;
      [vc setCompletionHandler:^(PMComposeViewControllerResult result) {
        if (result == PMComposeViewControllerResultDone) NSLog(@"Done");
        else NSLog(@"Cancel");
        dispatch_async(dispatch_get_main_queue(), ^{
          [segue.destinationViewController dismissModalViewControllerAnimated:YES];
        });
      }];
    }
  }
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.tableView addSubview: self.refreshTableHeaderView];
  [self.refreshTableHeaderView refreshLastUpdatedDate];
  
  id delegate = [[UIApplication sharedApplication] delegate];
  self.sharedUtility = [delegate valueForKey:PMUTILITY_KEY];
  self.sharedHerokRequest = [delegate valueForKey:PMHEROKREQUEST_KEY];

#warning need to set up location
  // may need to set up location and need to send request to Server for location.
}

- (void)viewDidUnload
{
  [self setTableView:nil];
  [self setRefreshTableHeaderView:nil];
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"cell for news";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    // add custom subclass into it
  }
  UILabel *title = (UILabel *)[cell.contentView viewWithTag:TAG_TITILE];
  UILabel *who = (UILabel *)[cell.contentView viewWithTag:TAG_WHO];
  UILabel *when_ago = (UILabel *)[cell.contentView viewWithTag:TAG_AGO];
  UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMG];
  NSDictionary *single_news = [self.tableData objectAtIndex:indexPath.row];
  title.text = [single_news objectForKey:HEROK_NEWS_TITLE];
  who.text = [@"By " stringByAppendingFormat:@"%@", [single_news objectForKey:HEROK_NEWS_AUTHOR]];
  //when_ago = [NSString stringWithFormat:@"%@"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // perform segue way
  // set up the sender to be table cell
  // [self performSegueWithIdentifier:SEGUE_SHOW_NEWS sender:indexPath];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  NSLog(@"scrollViewDIDScroll");
	[self.refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
  NSLog(@"scrollViewDidEndDragging");
	[self.refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}

#pragma mark - EGORefreshTableHeaderViewDelegate method
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
  NSLog(@"egoRefreshTableHeaderDidTriggerRefresh");
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.reloadTable;  // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
  return [NSDate date];  // return the date for last load information
}
@end
