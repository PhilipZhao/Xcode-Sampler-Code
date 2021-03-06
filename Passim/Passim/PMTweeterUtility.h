//
//  PMTweeterUtility.h
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@class PMTweeterUtility;
@protocol PMTweeterUtilityDelegate <NSObject>
- (void)tweeterUtil:(PMTweeterUtility *)  sender 
                user: (ACAccount *)       account 
  updateProfileImage:(UIImage *)          profile_image;
@end

@interface PMTweeterUtility : NSObject
@property (weak, nonatomic) id<PMTweeterUtilityDelegate> delegate;

- (void)loadUserProfile:(NSString *)           screen_name 
     withCompleteHandler:(void (^)(UIImage *))  handler;

/**
 * To get defaults screen name of particular user
 */
- (NSString *)getDefaultsScreenName;
- (void)getDefaultsUserNameWithCompleteHandler:(void (^)(NSString *)) handler;
- (void)getDefaultsUserInfoWithCompleteHandler:(void (^)(NSDictionary *)) handler;

/**
 * To update defaults screen name
 */
- (void)updateDefaultsScreenName:(NSString *)screen_name;
- (BOOL)canAccessTweeter;
- (void)requireAccessUserAccountWithCompleteHandler:(void (^)(BOOL granted, BOOL hasAccountInSystem)) handler;
- (UIImage *)getCurrentUserProfile;
- (void)tweeter:(NSString *)tweet withURL:(NSURL *)url;

- (void)followOnTwitter:(NSString *)                      follow_screen_name 
    withCompleteHandler:(void (^)(NSData *responseData))  handler;

- (void)unfollowOnTwitter:(NSString *)                     unfollow_screen_name 
      withCompleteHandler:(void (^)(NSData *responseData)) handler;
@end
