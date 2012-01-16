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
    [self NTRequestForProfieImage:user];
  }
  return [UIImage imageWithData:imgData];
}

- (void)NTRequestForProfieImage:(ACAccount *) account;
{
  TWRequest *getRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:TWAPI_PROFILE_IMAGE] 
                                              parameters: [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:account.username, @"bigger", nil] 
                                                                                      forKeys: [NSArray arrayWithObjects:@"screen_name",@"size", nil]] 
                                           requestMethod:TWRequestMethodGET];
  [getRequest setAccount:account];
  [getRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    if (responseData != nil) {
      [self updateUser:account withProfileImageData:responseData];
    }
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
          [self NTRequestForProfieImage:self.userAccount];
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
