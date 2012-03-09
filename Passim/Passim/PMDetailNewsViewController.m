//
//  PMDetailNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/20/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMDetailNewsViewController.h"
#import "PMNotification.h"
#import "PMAppDelegate.h"
#import "PMNewsAnnotation.h"

#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#define TAG_AUTHOR        1
#define TAG_SCREEN_NAME   2
#define TAG_BY_WHEN       3
#define TAG_PROFILE       4
#define TAG_COMMENT       5
#define TAG_TITLE         6
#define TAG_SUMMARY       7
#define TAG_SPINNER       8
#define TAG_SHOW_MAP      9 
#define TAG_MAP           10

#define NEWS_TITLE_WIDE   281
#define NEWS_SUMMARY_WIDE 281
#define NEWS_COMMENT_WIDE 220
#define MAX_HEIGH         300
#define PADDING           5
#define MAP_HEIGHT        120

#define SHOW_MAP    @"show map"
#define HIDE_MAP    @"hide map"


@interface PMDetailNewsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *returnPreviousView;
@property (weak, nonatomic) PMHerokCacheRequest *sharedHerokRequest;
@property (weak, nonatomic) PMTweeterUtility *tweeterUtil;
@property (nonatomic) BOOL showGoogleMap;
@end

@implementation PMDetailNewsViewController
@synthesize tableView = _tableView;
@synthesize barItemTitle = _barItemTitle;

@synthesize returnPreviousView = _returnPreviousView;
@synthesize sharedHerokRequest = _sharedHerokRequest;
@synthesize tweeterUtil = _tweeterUtil;
@synthesize newsData = _newsData;
@synthesize showGoogleMap = _showGoogleMap;

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
  creator_name.text = [self.newsData newsAuthor];
  screen_name.text = [@"@" stringByAppendingFormat:@"%@", [self.newsData newsScreenName]];
  profile.layer.cornerRadius = 8.0;
  profile.layer.masksToBounds = YES;
  [self.tweeterUtil loadUserProfile:[self.newsData newsScreenName] withCompleteHandler:^(UIImage* profilePic) {
    profile.image = profilePic;
  }];
}

- (void)compositeForNewsCell:(UITableViewCell *) cell {
  UILabel* title  = (UILabel *)[cell viewWithTag:TAG_TITLE];
  UILabel* summary = (UILabel *)[cell viewWithTag:TAG_SUMMARY];
  title.text = [self.newsData newsTitle];
  summary.text = [self.newsData newsSummary];
  CGRect frame = title.frame;
  frame.size.height = [[self.newsData newsTitle] sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize: CGSizeMake(NEWS_TITLE_WIDE, MAX_HEIGH) lineBreakMode:UILineBreakModeWordWrap].height;
  title.frame = frame;
  frame = summary.frame;
  frame.size.height = [[self.newsData newsSummary] sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize: CGSizeMake(NEWS_SUMMARY_WIDE, MAX_HEIGH) lineBreakMode:UILineBreakModeWordWrap].height;
  summary.frame = frame;
  UIButton* showMap = (UIButton *)[cell viewWithTag:TAG_SHOW_MAP];
  if (self.showGoogleMap)
    showMap.titleLabel.text = HIDE_MAP;
  else
    showMap.titleLabel.text = SHOW_MAP;
  frame = showMap.frame;
  frame.origin.y = [self tableViewHeightForNews] - frame.size.height;
  showMap.frame = frame;
}

- (void)compositeMapCell:(UITableViewCell *) cell {
  MKMapView* mapView = (MKMapView *)[cell viewWithTag:TAG_MAP];
  CGRect frame = CGRectMake(6.0, 5.0, 290.0, MAP_HEIGHT- 10.0);
  mapView.frame = frame;
  PMNewsAnnotation* annotation = [PMNewsAnnotation annotationForNewsObject:self.newsData];
  mapView.scrollEnabled = NO; mapView.zoomEnabled = NO;
  mapView.layer.cornerRadius = 8.0;
  mapView.layer.masksToBounds = YES;
  
  if (mapView.centerCoordinate.latitude != [annotation coordinate].latitude || mapView.centerCoordinate.longitude != [annotation coordinate].longitude ) {
    //[mapView removeAnnotations:[mapView annotations]];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([annotation coordinate], 100, 100);
    MKCoordinateRegion adjustRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustRegion animated:YES];
  }
  if ([[mapView annotations] count] == 0) 
    [mapView addAnnotation:annotation];
}

- (void)compositeForCommentCell:(UITableViewCell *) cell {
  UILabel* commenter = (UILabel *)[cell viewWithTag:TAG_AUTHOR];
  UILabel* by_when = (UILabel *)[cell viewWithTag:TAG_BY_WHEN];
  UILabel* comment = (UILabel *)[cell viewWithTag:TAG_COMMENT];
  UIImageView *profile = (UIImageView *)[cell viewWithTag:TAG_PROFILE];
  // rounded the profile
  profile.layer.cornerRadius = 8.0;   
  profile.layer.masksToBounds = YES;
}

- (CGFloat) tableViewHeightForNews
{
  NSString *newsTitle = [self.newsData newsTitle];
  NSString *newsSummary = [self.newsData newsSummary];
  CGFloat tableHeigh = 0;
  tableHeigh += [newsTitle sizeWithFont: [UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(NEWS_TITLE_WIDE, MAX_HEIGH) lineBreakMode:UILineBreakModeWordWrap].height ;
  tableHeigh += [newsSummary sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(NEWS_SUMMARY_WIDE, MAX_HEIGH) lineBreakMode:UILineBreakModeWordWrap].height;
  tableHeigh += PADDING * 4;
  return tableHeigh;
}

- (GLfloat) tableViewHeightForComment:(NSInteger) commentIndex
{
  // need to figure it out
  return 10.0;
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
  self.showGoogleMap = YES;
}

- (void)viewDidUnload
{
  [self setTableView:nil];
  [self setReturnPreviousView:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // load news
  [self.newsData getNewsCommentWithHandler:^(NSArray *data) {
    NSLog(@"finish data");
    [self.tableView reloadData];
  }];
}

- (void) viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [self setNewsData:nil];
  [self setTableView:nil];
  [self setReturnPreviousView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Target action
- (IBAction)returnPreviousView:(id)sender {
    if (self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:PMNotificationBottomBarShow] forKey:BOTTOM_BAR_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:PMNotificationBottomBar 
                                                            object:[UIApplication sharedApplication] 
                                                          userInfo:userInfo];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
  [self setNewsData:nil];
  [self setBarItemTitle:nil];
}

- (IBAction)showMap:(id)sender {
  self.showGoogleMap = !self.showGoogleMap;
  [self.tableView reloadData];
}

#pragma mark - Table View implementation
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // un-implemented
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0 && self.showGoogleMap) {
    return 3; // with google map
  } else if (section == 0 && !self.showGoogleMap) {
    return 2; // without google map
  } else {
    if (self.newsData.newsComments == nil)
      return 1;
    else 
      return [self.newsData.newsComments count];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 2; // 2 cells. One for Story and 1 for Comment
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
  static NSString *CellIdentifierForLoading = @"cell for loading comment";
  static NSString *CellIdentifierForMap = @"cell for map view";
  NSString *cellID;
  if (indexPath.row == 0 && indexPath.section == 0)
    cellID = CellIdentifierForAuthor;
  else if (indexPath.row == 1 && indexPath.section == 0) 
    cellID = CellIdentifierForNews;
  else if (indexPath.row == 2 && indexPath.section == 0)
    cellID = CellIdentifierForMap;
  else if (self.newsData.newsComments == nil) 
    cellID = CellIdentifierForLoading;
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
  else if (indexPath.row == 2 && indexPath.section == 0)
    [self compositeMapCell:cell];
  else if (self.newsData.newsComments == nil) 
    ;  // do nothing
  else 
    [self compositeForCommentCell:cell];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0 && indexPath.section == 0) {
    return 64; // header
  } else if (indexPath.row == 1 && indexPath.section == 0) {
    //return 100;
    return [self tableViewHeightForNews];
  } else if (indexPath.row == 2 && indexPath.section == 0) {
    return MAP_HEIGHT;
  } else if (indexPath.row == 0 && indexPath.section == 1 && self.newsData.newsComments == nil) {
    return 42; // for loading comment
  } else {
    return 62;
  }
}

#pragma mark map view delegate
// not need to implement it
@end
