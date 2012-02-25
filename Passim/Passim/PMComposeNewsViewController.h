//
//  PMComposeNewsViewController.h
//  Passim
//
//  Created by Philip Zhao on 1/18/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PMStandKeyConstant.h"

#define SEGUE_COMPOSITE_NEWS @"composeNews"

typedef void (^PMComposeViewControllerCompletionHandler)(PMComposeViewControllerResult result);

@interface PMComposeNewsViewController : UIViewController

@property (strong, nonatomic) NSString      *author_screen_name;
@property (strong, nonatomic) NSDictionary  *address;
@property (strong, nonatomic) CLLocation    *location;

-(IBAction)submitNews:(UIButton *)                sender;
-(IBAction)cancelSumbit:(UIButton *)              sender;
-(IBAction)selectedSegment:(UISegmentedControl *) sender;

@property (weak, nonatomic) IBOutlet UIView     *utilView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView     *locationView;
@property (weak, nonatomic) IBOutlet UIView     *photoView;

@property (nonatomic, copy) PMComposeViewControllerCompletionHandler completionHandler;
@end
