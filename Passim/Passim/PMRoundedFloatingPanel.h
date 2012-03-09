//
//  PMRoundedFloatingPanel.h
//  Passim
//
//  Created by Philip Zhao on 2/25/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
enum _DisplayType{
  SubmitSucess,
  SubmitCancel,
  SubmitFailure
};

enum _AnimationOption {
  FadeInFadeOut
};

typedef enum _DisplayType DisplayType;
typedef enum _AnimationOption AnimationOption;

@interface PMRoundedFloatingPanel : UIView
@property (weak, nonatomic) id parent;

+ (void) presentRoundedFloatingPanel:(DisplayType) type 
                              delay:(float)       delay
                             sender:(UIView *)    sender;

- (void) presentView:(DisplayType)     type 
            duration:(float)           duration
               delay:(float)           delay
             options:(AnimationOption) option
       completeBlock:(void (^)())      handler;
@end
