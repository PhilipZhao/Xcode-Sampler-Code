//
//  PMTweeterUtility.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMTweeterUtility.h"


// k-v storage for plist
#define PREFER_SCREEN_NAME @"prefer screen_name"

// all the public tweeter api 
#define TWAPI_PROFILE_IMAGE @"http://api.twitter.com/1/users/profile_image"

@interface PMTweeterUtility() 
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *accountType;
@property (strong, nonatomic) ACAccount *userAccount;
@end

@implementation PMTweeterUtility
#pragma mark -
@synthesize delegate = _delegate;
@synthesize accountStore = _accountStore;
@synthesize accountType = _accountType;
@synthesize userAccount = _userAccount;

#pragma mark - private function
- (void)updateUser:(ACAccount *) user withProfileImageData:(NSData *) imgData
{
  NSLog(@"update User with ProfileImage Data");
  if (user == nil) return;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:imgData forKey:[NSString stringWithFormat:@"%@_profile_image_data", user.username]];
  [defaults synchronize];
  [self.delegate tweeterUtil:self user:user updateProfileImage:[UIImage imageWithData:imgData]];
}

- (UIImage *)getProfileImageFromUser:(ACAccount *)user
{
  if (user == nil) return nil;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *imgData = [defaults valueForKey:[NSString stringWithFormat:@"%@_profile_image_data", user.username]];
  if (imgData == nil) {
      //FIXME: the following line produces errors in xcode 4.2 - borui
    [PMTweeterUtility NTRequestForProfieImage:user.username withCompletedHandler:^(NSData *imgData) {
      [self updateUser:user withProfileImageData:imgData];
    }];
  }
  return [UIImage imageWithData:imgData];
}

+ (void)NTRequestForProfieImage:(NSString *)screen_name withCompletedHandler:(void (^)(NSData *imgData)) handler
{
  TWRequest *getRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:TWAPI_PROFILE_IMAGE] 
                                              parameters: [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:screen_name, @"bigger", nil] 
                                                                                      forKeys: [NSArray arrayWithObjects:@"screen_name",@"size", nil]] 
                                           requestMethod:TWRequestMethodGET];
  //[getRequest setAccount:account];
  [getRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    if (responseData != nil) {
      handler(responseData);
      //[self updateUser:account withProfileImageData:responseData];
    }
  }];
}

#pragma mark - class Method
+ (void)loadUserProfile:(NSString *)screen_name withCompleteHandler:(void (^)(UIImage *))handler
{
  [PMTweeterUtility NTRequestForProfieImage:screen_name withCompletedHandler:^(NSData *imgData){
    UIImage *profile = [UIImage imageWithData:imgData];
    handler(profile);
  }];
}

#pragma mark - Setter/Getter

- (id)init 
{
  if (self = [super init]) {
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    self.userAccount = nil;
  }
  return self;
}

- (void)requireAccessUserAccountWithCompleteHandler:(void (^)(BOOL granted, BOOL hasAccountInSystem)) handler
{
  if (self.userAccount == nil) {
    // ask for require
    [self.accountStore requestAccessToAccountsWithType:self.accountType withCompletionHandler:^(BOOL granted, NSError *error) {
      if (granted) {
        NSArray *accountArray = [self.accountStore accountsWithAccountType:self.accountType];
        if ([accountArray count] == 0) {
          handler(granted, NO);
        } else {
          self.userAccount = [accountArray objectAtIndex:0];
          // always load from network 
          NSLog(@"Load user %@'s profile throught Network", self.userAccount.username);
          [PMTweeterUtility NTRequestForProfieImage:self.userAccount.username withCompletedHandler:^(NSData *imgData){
            [self updateUser:self.userAccount withProfileImageData:imgData];
          }];
          if (![self.userAccount.username isEqualToString:[self getDefaultsScreenName]]) {
            [self updateDefaultsScreenName:self.userAccount.username];
            // load image throught the newtwork
          }
          //TODO(PHIL):need to check the timestamp of user profile image and possible reload it from network
          
          handler(granted, YES);
        }
      } else {
        NSLog(@"Failed to access the user account");
        handler(granted, NO);
      }
    }];
  }
}

- (BOOL) canAccessTweeter
{
  return [TWTweetComposeViewController canSendTweet];
}

- (NSString *)getDefaultsScreenName 
{
  if (self.userAccount == nil)
    return nil;
  else 
    return self.userAccount.username;
}

- (void) updateDefaultsScreenName:(NSString *)screen_name
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:screen_name forKey:PREFER_SCREEN_NAME];
  [defaults synchronize];
}

- (UIImage *)getCurrentUserProfile
{
  return [self getProfileImageFromUser:self.userAccount];
}

- (void)tweeter:(NSString *)tweet withURL:(NSURL *)url
{
  // tweeter the message with url
}


@end
