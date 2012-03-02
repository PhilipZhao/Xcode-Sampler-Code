//
//  PMDetailNewsViewController.h
//  Passim
//
//  Created by Philip Zhao on 1/20/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMNews.h"

@interface PMDetailNewsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString  *barItemTitle;
@property (strong, nonatomic) PMNews    *newsData;
- (IBAction)returnPreviousView:(id)sender;
-(IBAction)goBackPreviousView:(id)sender;
@end
