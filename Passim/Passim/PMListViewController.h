//
//  PMListViewController.h
//  Passim
//
//  Created by Philip Zhao on 1/14/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface PMListViewController : UIViewController <UITableViewDelegate, 
                                                    UITableViewDataSource, 
                                                    EGORefreshTableHeaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
