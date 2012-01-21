//
//  PMListViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/14/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMListViewController.h"

#define SEGUE_SHOW_NEWS @"showNewsDetail"

@interface PMListViewController ()
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL reloadTable;
@end

@implementation PMListViewController
@synthesize tableView = _tableView;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize reloadTable = _reloadTable;

#pragma mark - Setter/Getter
- (EGORefreshTableHeaderView *)refreshTableHeaderView 
{
  if (_refreshTableHeaderView == nil) {
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshTableHeaderView.delegate = self;
  }
  return _refreshTableHeaderView;
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
    // set up controller segue.destinationViewController
  }
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.tableView addSubview: self.refreshTableHeaderView];
  [self.refreshTableHeaderView refreshLastUpdatedDate];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
  // Return the number of rows in the section.
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"cell for news";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    // add custom subclass into it
  }
  // Configure the cell...
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
