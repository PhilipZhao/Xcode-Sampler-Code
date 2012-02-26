//
//  PMCommentComposerViewController.h
//  Passim
//
//  Created by Philip Zhao on 2/17/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PMStandKeyConstant.h"

#define SEGUE_COMPOSE_COMMENT @"composeComment"

typedef void (^PMCommentComposeViewControllerCompletionHandler)(PMComposeViewControllerResult result);

@interface PMCommentComposerViewController : UIViewController
-(IBAction)submit:(id)sender;
-(IBAction)cancel:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@property (strong, nonatomic) NSString *author_screen_name;
@property (nonatomic) int news_id;

@property (nonatomic, copy) PMCommentComposeViewControllerCompletionHandler completionHandler;
@end
