//
//  simple2View.h
//  simple2View
//
//  Created by Philip Zhao on 12/31/11.
//  Copyright (c) 2011 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface simple2View : UIViewController
@property (strong, nonatomic) IBOutlet UIView *protrait;
@property (strong, nonatomic) IBOutlet UIView *landscape;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *foo;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *bar;

- (IBAction)fooTap:(id)sender;
- (IBAction)barTap:(id)sender;
@end
