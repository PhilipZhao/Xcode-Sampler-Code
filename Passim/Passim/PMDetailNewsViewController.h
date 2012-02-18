//
//  PMDetailNewsViewController.h
//  Passim
//
//  Created by Philip Zhao on 1/20/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMDetailNewsViewController : UIViewController
@property (nonatomic) id detailNewsViewControllerDelegate;
@property (nonatomic) NSInteger news_id;
@property (strong, nonatomic) NSString *barItemTitle;

- (IBAction)goBackPreviousView:(id)sender;
@end
