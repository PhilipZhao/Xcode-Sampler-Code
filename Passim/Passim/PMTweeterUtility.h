//
//  PMTweeterUtility.h
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMTweeterUtility : NSObject

- (NSString *)getDefaultsScreenName;
- (void) updateDefaultsScreenName:(NSString *)screen_name;
- (BOOL) canAccessTweeter;
- (void)requireAccessUserAccountWithCompleteHandler:(void (^)(BOOL granted)) handler;
@end
