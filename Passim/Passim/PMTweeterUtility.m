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
@property (strong, nonatomic) NSMutableDictionary *profileDic;
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@implementation PMTweeterUtility
#pragma mark -
@synthesize delegate = _delegate;
@synthesize accountStore = _accountStore;
@synthesize accountType = _accountType;
@synthesize userAccount = _userAccount;
@synthesize profileDic = _profileDic;
@synthesize userInfo = _userInfo;

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

- (UIImage *)getProfileImageFromUser:(ACAccount *)user
{
    if (user == nil) return nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imgData = [defaults valueForKey:[NSString stringWithFormat:@"%@_profile_image_data", user.username]];
    if (imgData == nil) {
        
        [PMTweeterUtility NTRequestForProfieImage:user.username withCompletedHandler:^(NSData *imgData) {
            [self updateUser:user withProfileImageData:imgData];
        }];
    }
    return [UIImage imageWithData:imgData];
}

- (void)loadUserProfile:(NSString *)screen_name withCompleteHandler:(void (^)(UIImage *))handler
{
  if ([self.profileDic objectForKey:screen_name] != nil) {
    handler((UIImage *)[self.profileDic objectForKey:screen_name]);
    return;
  }
  [PMTweeterUtility NTRequestForProfieImage:screen_name withCompletedHandler:^(NSData *imgData){
    UIImage *profile = [UIImage imageWithData:imgData];
    if (profile != nil) [self.profileDic setObject:profile forKey:screen_name];
    dispatch_async(dispatch_get_main_queue(), ^{handler(profile);});
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
          NSLog(@"%@, %@", self.userAccount.identifier, self.userAccount.accountDescription);
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

- (void) getDefaultsUserNameWithCompleteHandler:(void (^)(NSString *)) handler 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *key = [[self getDefaultsScreenName] stringByAppendingString:@"_user_name"];
  NSString *userName = [defaults objectForKey:key];
  if (userName == nil)
    [self getDefaultsUserInfoWithCompleteHandler:^(NSDictionary *userInfo) {
      handler([userInfo objectForKey:@"name"]);
      [defaults setValue:[userInfo objectForKey:@"name"] forKey:key];
      [defaults synchronize];
    }];
  else
    handler(userName);
}

- (void) getDefaultsUserInfoWithCompleteHandler:(void (^)(NSDictionary *))handler
{
  if (self.userInfo != nil) {
    handler(self.userInfo);
    return;
  }
  NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] initWithCapacity:1]; 
  [requestDict setValue:[self getDefaultsScreenName] forKey:@"screen_name"];
  TWRequest *getRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/users/show.json"]
                                               parameters:requestDict 
                                            requestMethod:TWRequestMethodGET];
  [getRequest setAccount:self.userAccount];
  [getRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    if (responseData != nil) {
      NSError *jsonParsingError;
      NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
      NSLog(@"%@", info);
      self.userInfo = info;
      handler(info);
    }
  }];
  
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

- (void)followOnTwitter:(NSString *)follow_screen_name withCompleteHandler:(void (^)(NSData *))handler
{
  NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] initWithCapacity:2]; 
  [requestDict setValue:follow_screen_name forKey:@"screen_name"];
  [requestDict setValue:@"true" forKey:@"follow"];
  TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/friendships/create.json"] 
                                               parameters:requestDict 
                                            requestMethod:TWRequestMethodPOST];
  [postRequest setAccount:self.userAccount];
  [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
    NSLog(@"%@", output);
    if (responseData != nil) handler(responseData);
  }];
}

- (void)unfollowOnTwitter:(NSString *)unfollow_screen_name withCompleteHandler:(void (^)(NSData *))handler
{
  NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] initWithCapacity:2]; 
  [requestDict setValue:unfollow_screen_name forKey:@"screen_name"];
  TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/friendships/destroy.json"] 
                                               parameters:requestDict 
                                            requestMethod:TWRequestMethodPOST];
  [postRequest setAccount:self.userAccount];
  [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
    NSLog(@"%@", output);
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSLog(@"%@", response);
    if (responseData != nil) handler(responseData);
  }];
}

- (void)getUserFullName:(NSString *) screen_name
{
  
}

@end
