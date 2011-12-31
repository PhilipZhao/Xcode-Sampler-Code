//
//  phpRequestViewController.m
//  fetchRequest
//
//  Created by Philip Zhao on 12/30/11.
//  Copyright (c) 2011 University of Wisconsin-Madison. All rights reserved.
//

#import "phpRequestViewController.h"

#define REQUEST_SAMPLE3 @"http://blooming-sword-3303.herokuapp.com/posts/4.json"

#define REQUEST_SAMPLE1 @"http://ipassim.com/phpMySQL/handleNewsRequest.php?geolat_upper=63.938939868946846&geolong_upper=-47.21773354874881&geolat_lower=29.691152016132396&geolong_lower=-131.5927335487488&mode=NewsOnCloseGeoLocation&num_marker=60"

#define REQUEST_SAMPLE2 @"http://rss.news.yahoo.com/rss/world"

@implementation phpRequestViewController
@synthesize outputArea = _outputArea;

- (IBAction)sendRequest:(UIButton *)sender 
{
  NSString * requestURL;
  if ([sender.titleLabel.text isEqualToString:@"Request 1"]) {
    requestURL = REQUEST_SAMPLE3;
  } else {
    requestURL = REQUEST_SAMPLE2;
  }
  UIActivityIndicatorView *spiner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [spiner startAnimating];
  sender.hidden = YES;
  spiner.frame = sender.frame;
  [self.view addSubview:spiner];
  dispatch_queue_t requestQ = dispatch_queue_create("request from URL", NULL);
  dispatch_async(requestQ, ^{
    NSURL* url = [NSURL URLWithString:requestURL];
    NSData * dataObject = [[NSData alloc] initWithContentsOfURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
      sender.hidden = NO;
      [spiner removeFromSuperview];
      NSString * output = [[NSString alloc] initWithData:dataObject 
                                                encoding:NSASCIIStringEncoding];
      self.outputArea.text = output;
    });
  });
  dispatch_release(requestQ);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return NO;
}

- (void)viewDidUnload {
  [self setOutputArea:nil];
  [super viewDidUnload];
}
@end
