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
#import "PMDetailNewsViewController.h"
#import "PMStandKeyConstant.h"
#import "PMNotification.h"
#import "PMNews.h"

#define SEGUE_SHOW_NEWS @"showNewsDetail"
#define TAG_TITILE  1
#define TAG_WHO     2
#define TAG_AGO     3
#define TAG_IMG     4
#define TAG_SPINNER 5

@interface PMListViewController ()
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL reloadTable;

@property (weak, nonatomic) PMLocationUtility *sharedUtility;
@property (weak, nonatomic) PMHerokCacheRequest *sharedHerokRequest;
@property (weak, nonatomic) PMTweeterUtility *tweeterUtil;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSDictionary *curr_address;
@property (nonatomic) BOOL viewIsDisappear;
@property (strong, nonatomic) NSIndexPath* currentIndexPath;
@end

@implementation PMListViewController

@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize reloadTable = _reloadTable;
@synthesize tableData = _tableData;
@synthesize sharedUtility = _sharedUtilty;
@synthesize sharedHerokRequest = _sharedHerokRequest;
@synthesize tweeterUtil = _tweeterUtil;
@synthesize curr_address = _curr_address;
@synthesize tableView = _tableView;
@synthesize viewIsDisappear = _viewIsDisappear;
@synthesize currentIndexPath = _currentIndexPath;

#pragma mark - Setter/Getter
- (EGORefreshTableHeaderView *)refreshTableHeaderView 
{
  if (_refreshTableHeaderView == nil) {
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshTableHeaderView.delegate = self;
  }
  return _refreshTableHeaderView;
}

- (void) setTableData:(NSMutableArray *)tableData
{
  if (_tableData != tableData) {
    _tableData = tableData;
    [self.tableView reloadData];
  }
}

#pragma mark - Private Function
- (void) reloadTableViewDataSource 
{
  // submit request to Server to reload data information
  [self updateNewsWithCurrentAddress:self.curr_address option:PMHerokCacheForceToReload withCompleteBlock: ^(){
    [self doneLoadingTableViewData];
  }];
  self.reloadTable = YES;
}

- (void)doneLoadingTableViewData
{
#warning incompleted implementation
	//  model should call this when its done loading
	self.reloadTable = NO;
	[self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];	
}

- (void)updateNewsWithCurrentAddress:(NSDictionary *) newAddress 
                              option:(PMHerokCacheOption) option 
                   withCompleteBlock:(void (^)()) handler
{
  self.curr_address = newAddress;
  void (^completeBlock)(NSArray *) = ^(NSArray *newsData) {
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:[newsData count]];
    for (NSDictionary *singleNews in newsData) {
      [data addObject:singleNews];
    }
    self.tableData = data;
    handler();
  };
  [self.sharedHerokRequest newsBasedOnRegion:newAddress 
                                      option:option 
                           withCompleteBlock:completeBlock];
}

#pragma mark - Segue way
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:SEGUE_SHOW_NEWS]) {
    if ([segue.destinationViewController respondsToSelector:@selector(setBarItemTitle:)])
      [segue.destinationViewController setBarItemTitle:@"List view"];
    if ([segue.destinationViewController respondsToSelector:@selector(setNewsData:)] && [sender isKindOfClass:[PMNews class]])
      [segue.destinationViewController setNewsData:sender];
  } else if ([segue.identifier isEqualToString:SEGUE_COMPOSITE_NEWS]) {
    if ([segue.destinationViewController isKindOfClass:[PMComposeNewsViewController class]]) {
      PMComposeNewsViewController *vc = (PMComposeNewsViewController *)segue.destinationViewController;
      [vc setValue:self.curr_address forKey:POST_ADDRESS];
      NSString *screen_name = [self.tweeterUtil getDefaultsScreenName];
      [vc setValue:screen_name forKey:POST_AUTHOR];
      CLLocation *location = [self.sharedUtility getUserCurrentLocationWithSender:self];
      [vc setValue:location forKey:POST_LOCATION];
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
  self.tableView.delegate = self;
  
  id delegate = [[UIApplication sharedApplication] delegate];
  self.sharedUtility = [delegate valueForKey:PMUTILITY_KEY];
  self.sharedHerokRequest = [delegate valueForKey:PMHEROKREQUEST_KEY];
  self.tweeterUtil = [delegate valueForKey:PMTWEETERUTILITY_KEY];
  CLLocation *userLocation = [self.sharedUtility getUserCurrentLocationWithSender:self];
  if (userLocation != nil) {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    [self.sharedUtility addressInformationBaseOnLocation:location sender:self completedBlock:^(NSDictionary *address) {
      [self updateNewsWithCurrentAddress:address option:PMHerokCacheFromCache withCompleteBlock:^(){}];
    }];
  }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceiveNewAddress:) name:PMNotificationLocationNewAddress object:self.sharedUtility];
  self.viewIsDisappear = YES;
}

- (void)viewDidUnload
{
  [self setTableView:nil];
  [self setRefreshTableHeaderView:nil];
  [super viewDidUnload];
  [[NSNotificationCenter defaultCenter] removeObject:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
  [super viewWillAppear:animated];
  self.viewIsDisappear = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [[self.tableView cellForRowAtIndexPath:self.currentIndexPath] setSelected:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  self.viewIsDisappear = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notification Center
- (void)notificationReceiveNewAddress:(NSNotification *)notification 
{
  NSDictionary *location = [notification.userInfo valueForKey:PMInfoAddress];
  if (self.viewIsDisappear) {
    self.curr_address = location;
    return;
  }
  [self updateNewsWithCurrentAddress:location option:PMHerokCacheFromCache withCompleteBlock:^(){}];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.tableData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
  return @"Stories around me";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"cell for news";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    NSLog(@"Something must be wrong");
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    // add custom subclass into it
  }
  UILabel *title = (UILabel *)[cell.contentView viewWithTag:TAG_TITILE];
  UILabel *who = (UILabel *)[cell.contentView viewWithTag:TAG_WHO];
  UILabel *when_ago = (UILabel *)[cell.contentView viewWithTag:TAG_AGO];
  UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMG];
  UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:TAG_SPINNER];
  PMNews *single_news = [self.tableData objectAtIndex:indexPath.row];
  title.text = [single_news newsTitle];
  UIImage * img = [single_news newsFrontPhoto];
  if (img == nil) {
    [spinner startAnimating];
    [single_news getNewsFrontPhotoWithBlock:^(UIImage *image) {
      // test code, for demo not recommend
      imageView.image = image;
      [spinner stopAnimating];
    }];
  } else {
    imageView.image = img;
  }
  who.text = [@"By " stringByAppendingFormat:@"%@", [single_news newsAuthor]];
  float minutesAgo = [single_news newsDateTimeByAgo];
  if (minutesAgo < 1)
    when_ago.text = [@"few seconds ago at " stringByAppendingFormat:@"%@", [single_news newsAddress]];
  else 
    when_ago.text = [NSString stringWithFormat:@"%d minutes ago at %@", (NSInteger)minutesAgo, [single_news newsAddress]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // perform segue way
  // set up the sender to be table cell
  [self performSegueWithIdentifier:SEGUE_SHOW_NEWS sender:[self.tableData objectAtIndex:indexPath.row]];
  self.currentIndexPath = indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 91;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
	[self.refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}


#pragma mark - EGORefreshTableHeaderViewDelegate method
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];	
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
