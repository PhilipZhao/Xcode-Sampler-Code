//
//  PMComposeNewsViewController.h
//  Passim
//
//  Created by Philip Zhao on 1/18/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SEGUE_COMPOSITE_NEWS @"composeNews"

enum PMComposeViewControllerResult {
  PMComposeViewControllerResultCancelled,
  PMComposeViewControllerResultDone
};
typedef enum PMComposeViewControllerResult PMComposeViewControllerResult;

typedef void (^PMComposeViewControllerCompletionHandler)(PMComposeViewControllerResult result);

@interface PMComposeNewsViewController : UIViewController

- (IBAction)submitNews:(UIButton *)sender;
- (IBAction)cancelSumbit:(UIButton *)sender;

@property(nonatomic, copy) PMComposeViewControllerCompletionHandler completionHandler;
@end
