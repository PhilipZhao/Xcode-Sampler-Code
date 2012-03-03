//
//  PMRoundedFloatingPanel.m
//  Passim
//
//  Created by Philip Zhao on 2/25/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMRoundedFloatingPanel.h"
#define SUCCESS @"Success"
#define CANCEL  @"Cancel"
#define FAILURE @"Failure"

#define PANEL_WIDE 150
#define PANEL_HEIGH 150
#define FONT_SIZE   18
#define ALPHA_VALUE 0.4
#define TAG_LABEL   1

@interface PMRoundedFloatingPanel()
- (void)presentView:(DisplayType)type duration:(float)duration delay:(float)delay options:(AnimationOption)option completeBlock:(void (^)())handler;
@end

@implementation PMRoundedFloatingPanel
@synthesize parent = _parent;

+ (void)presentRoundedFloatingPanel:(DisplayType) type 
                              delay:(float)       delay
                             sender:(UIView *)    sender
{
  
  CGRect frame = sender.frame;
  frame.origin.x = frame.size.width/2 - PANEL_WIDE/2;
  frame.origin.y = frame.size.height/2 - PANEL_HEIGH/2;
  frame.size.width = PANEL_WIDE;
  frame.size.height = PANEL_HEIGH;
  PMRoundedFloatingPanel *panel = [[PMRoundedFloatingPanel alloc] initWithFrame:frame];
  panel.parent = sender;
  [sender addSubview:panel];
  [panel presentView:type duration:1 delay:delay options:FadeInFadeOut completeBlock:^{
    [panel removeFromSuperview];
  }];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
      // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8];
    self.layer.cornerRadius = 10;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 7.0;
    self.layer.shadowOffset = CGSizeMake(0, 4);
  }
  return self;
}

- (void) presentView:(DisplayType) type 
            duration:(float) duration 
               delay:(float) delay 
             options:(AnimationOption) option 
       completeBlock:(void (^)()) handler
{
  UILabel *label = (UILabel *)[self viewWithTag:TAG_LABEL];
  if (label == nil) {
    label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
  }
  switch (type) {
    case SubmitSucess:
      label.text = SUCCESS;
      break;
    case SubmitCancel:
      label.text = CANCEL;
      break;
    default:
      label.text = @"Unknown issue";
      break;
  }
  CGSize size = [label.text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:CGSizeMake(150, 150)];
  label.frame = CGRectMake((PANEL_WIDE-size.width)/2, (PANEL_HEIGH-size.height)/2, size.width, size.height); // need to change later
  self.alpha = 0;
  void(^animationBlock)(void) = ^{
    self.alpha = 1.0;
  };
  void(^completeBlock)(BOOL) = ^(BOOL finished) {
    if (finished) {
      [UIView animateWithDuration:duration 
                            delay:0 
                          options:UIViewAnimationCurveEaseOut 
                       animations:^{self.alpha = 0;} 
                       completion:^(BOOL finished) {
        if (finished) handler();
      }];
    }
  };
  
  [UIView animateWithDuration:duration 
                        delay:delay 
                      options:UIViewAnimationCurveEaseIn 
                   animations:animationBlock 
                   completion:completeBlock];
}

@end
