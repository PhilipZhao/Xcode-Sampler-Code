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
//#import "UIImage+Resize.h"
#import "PMRoundedFloatingPanel.h"

#define SEGUE_SHOW_NEWS @"showNewsDetail"
#define TAG_TITILE      1
#define TAG_WHO         2
#define TAG_AGO         3
#define TAG_IMG         4
#define TAG_SPINNER     5
#define TAG_SCREEN_NAME 6
#define TAG_NUM_COMMENT 7
#define TAG_IMG_COMMENT 8
#define TAG_NUM_LIKE    9
#define TAG_IMG_LIKE    10
#define TAG_SEPERATOR   11

#define PADDING 5

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


#pragma mark - Private Function
- (void) reloadTableViewDataSource 
{
    // submit request to Server to reload data information
    [self updateNewsWithCurrentAddress:self.curr_address option:PMHerokCacheForceToReload withCompleteBlock: ^(){
        [self doneLoadingTableViewData];
    }];
    self.reloadTable = YES;
}

#pragma mark - Segue way
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_SHOW_NEWS]) {
      [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:PMNotificationBottomBarHide] forKey:BOTTOM_BAR_KEY];
      [[NSNotificationCenter defaultCenter] postNotificationName:PMNotificationBottomBar 
                                                          object:[UIApplication sharedApplication] 
                                                        userInfo:userInfo];
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
                if (result == PMComposeViewControllerResultDone) {
                  [PMRoundedFloatingPanel presentRoundedFloatingPanel:SubmitSucess delay:0 sender:self.view];
                }
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
          NSLog(@"[List]Address:%@", address);  
          [self updateNewsWithCurrentAddress:address option:PMHerokCacheFromCache withCompleteBlock:^(){}];
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceiveNewAddress:) name:PMNotificationLocationNewAddress object:self.sharedUtility];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceiveNewsData:) name:PMNotificationHerokCacheRequestNewData object:self.sharedHerokRequest];
    self.viewIsDisappear = YES;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  [self setTableView:nil];
  [self setRefreshTableHeaderView:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated 
{
  [super viewWillAppear:animated];
  self.viewIsDisappear = NO;
  self.hidesBottomBarWhenPushed = NO;
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
  //self.tableData = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notification Center
- (void)notificationReceiveNewAddress:(NSNotification *)notification 
{
  NSDictionary *location = [notification.userInfo valueForKey:PMInfoAddress];
  NSLog(@"[List]Address:%@", location);
  if (self.viewIsDisappear) {
    self.curr_address = location;
    return;
  }
  [self updateNewsWithCurrentAddress:location option:PMHerokCacheFromCache withCompleteBlock:^(){}];
}

- (void)notificationReceiveNewsData:(NSNotification *)notification
{
    //if (self.viewIsDisappear) return;
  NSLog(@"[List]Receive new data from Model");
    if (notification.userInfo == nil) {
        [self updateNewsWithCurrentAddress:self.curr_address option:PMHerokCacheFromCache withCompleteBlock: ^(){
        }];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
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
        NSLog(@"Cell identifier not found, reinitialize table cell");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        /* add custom subclass into it */
    }
    
    // create view and label references
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TAG_TITILE];
    UILabel *who = (UILabel *)[cell.contentView viewWithTag:TAG_WHO];
    UILabel *screen_name = (UILabel *)[cell.contentView viewWithTag:TAG_SCREEN_NAME];
    UILabel *when_ago = (UILabel *)[cell.contentView viewWithTag:TAG_AGO];
    //UILabel *numComment = (UILabel *)[cell.contentView viewWithTag:TAG_NUM_COMMENT];
    //UILabel *numLike = (UILabel *)[cell.contentView viewWithTag:TAG_NUM_LIKE];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMG];
    
    // fetch news
    PMNews *single_news = [self.tableData objectAtIndex:indexPath.row];
    
    //reusable resources
    CGRect reusable_frame;
    CGSize reusable_width;
    
    // for title view
    title.text = [single_news newsTitle];
    reusable_frame = title.frame;
    reusable_frame.size = [title.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(230, 35)];
    reusable_frame.origin.x = 65;
    reusable_frame.origin.y = 24;    
    title.frame = reusable_frame;
    
    //for who view
    who.text = [single_news newsAuthor];
    reusable_frame = who.frame;
    reusable_width = [who.text sizeWithFont:[UIFont systemFontOfSize:10]];
    reusable_frame.size = [who.text sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:CGSizeMake(reusable_width.width, 10)];
    reusable_frame.origin.x = 65;
    reusable_frame.origin.y = 8; 
    who.frame = reusable_frame;
    
    //for screen nanme
    screen_name.text = [@"@" stringByAppendingString:[single_news newsScreenName]];
    reusable_frame = screen_name.frame;
    reusable_width = [screen_name.text sizeWithFont:[UIFont systemFontOfSize:10]];
    reusable_frame.size = [screen_name.text sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:CGSizeMake(reusable_width.width, 10)];
    reusable_frame.origin.x = who.frame.size.width + who.frame.origin.x + 2;
    reusable_frame.origin.y = 8; 
    screen_name.frame = reusable_frame;
    
    //for address : to make it stay at the center..
    NSString* address = [single_news newsAddress];
    address = (address == nil) ? @"": [@"at " stringByAppendingString: address];
    PMNewsDateTime dateTime = [single_news newsDateTimeByAgo];
    NSString* singluar = (dateTime.timeSinceNow == 1) ? @"": @"s";
    switch (dateTime.ago) {
        case PMSecondAgo:when_ago.text = [NSString stringWithFormat:@"A few seconds ago %@", address];break;
        case PMMinuteAgo:when_ago.text = [NSString stringWithFormat:@"%d minute%@ ago %@", dateTime.timeSinceNow, singluar, address];break;
        case PMHourAgo:when_ago.text = [NSString stringWithFormat:@"%d hour%@ ago %@", dateTime.timeSinceNow, singluar, address];break;
        case PMDayAgo:when_ago.text = [NSString stringWithFormat:@"%d day%@ ago %@", dateTime.timeSinceNow, singluar, address];break;
        default:break;
    }
    
    // manully set to center, not used for now as story board could set the center option:
    /*
    reusable_frame = when_ago.frame;
    reusable_width = [when_ago.text sizeWithFont:[UIFont systemFontOfSize:10]];
    reusable_frame.size = [when_ago.text sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:CGSizeMake(reusable_width.width, 10)];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    reusable_frame.origin.x = (screenWidth - reusable_width.width)/2;
    when_ago.frame = reusable_frame;
    */
    
    imageView.image = [single_news newsFrontPhoto];
    if (imageView.image == nil) {
        [single_news getNewsFrontPhotoWithBlock:^(UIImage *image) {
            // test code, for demo not recommend
          imageView.image = image;
           /* CGSize new_frame = CGSizeMake(32,32);
            imageView.image = [image resizedImage:new_frame interpolationQuality:(CGInterpolationQuality)3];*/
        }];
    }
    imageView.layer.cornerRadius = 8.0;
    imageView.layer.masksToBounds = YES;    // get the count. Need to update later
    //numLike.text = @"10";
    //numComment.text = @"21";
    
    //set cell background
    cell.contentView.backgroundColor = (indexPath.row % 2 == 0)?[UIColor colorWithPatternImage:[UIImage imageNamed:@"table_row_bg_even.png"]]:[UIColor colorWithPatternImage:[UIImage imageNamed:@"table_row_bg_odd.png"]];
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
    return 82;
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
