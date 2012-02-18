//
//  PMCommentComposerViewController.m
//  Passim
//
//  Created by Philip Zhao on 2/17/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMCommentComposerViewController.h"
#import "PMAppDelegate.h"

@interface PMCommentComposerViewController ()

@end

@implementation PMCommentComposerViewController
@synthesize commentTextView = _commentTextView;
@synthesize completionHandler = _completionHandler;
@synthesize author_screen_name = _author_screen_name; 
@synthesize news_id = _news_id;

#pragma mark - private function
- (void) packedCommentWithInfo:(NSDictionary *) comment {
  [comment setValue:self.author_screen_name forKey:PASSIM_USER_NAME];
  [comment setValue:[NSNumber numberWithInt:self.news_id] forKey:PASSIM_NEWS_ID];
  [comment setValue:self.commentTextView.text forKey:PASSIM_COMMENT];
}

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
}

- (void)viewDidUnload
{
    [self setCommentTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.commentTextView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)submit:(id)sender {
  if ([self.author_screen_name length] <= 0 && (self.news_id == 0)) {
    self.completionHandler(PMComposeViewControllerResultCancelled);
  } else {
    id delegate = [[UIApplication sharedApplication] delegate];
    PMHerokCacheRequest *request = [delegate valueForKey:PMHEROKREQUEST_KEY];
    NSMutableDictionary *commentInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [self packedCommentWithInfo:commentInfo];
    NSLog(@"%@", commentInfo);
    
  }
}

- (IBAction)cancel:(id)sender {
  self.completionHandler(PMComposeViewControllerResultCancelled);
}
@end
