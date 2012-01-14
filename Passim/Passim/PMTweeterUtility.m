//
//  PMTweeterUtility.m
//  Passim
//
//  Created by Philip Zhao on 1/13/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//

#import "PMTweeterUtility.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#define PREFER_SCREEN_NAME @"prefer screen_name"

@interface PMTweeterUtility() 
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *accountType;
@property (strong, nonatomic) ACAccount *userAccount;
@property (strong, nonatomic) NSString *preferScreenName;
@end

@implementation PMTweeterUtility
@synthesize accountStore = _accountStore;
@synthesize accountType = _accountType;
@synthesize userAccount = _userAccount;
@synthesize preferScreenName = _preferScreenName;

#pragma mark - Setter/Getter

- (id)init 
{
  if (self = [super init]) {
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  }
  return self;
}

- (void)requireAccessUserAccountWithCompleteHandler:(void (^)(BOOL granted)) handler
{
  if (self.userAccount == nil) {
    // ask for require
    [self.accountStore requestAccessToAccountsWithType:self.accountType withCompletionHandler:^(BOOL granted, NSError *error) {
      if (granted) {
        NSArray *accountArray = [self.accountStore accountsWithAccountType:self.accountType];
        if ([accountArray count] == 0) {
        } else {
          self.userAccount = [accountArray objectAtIndex:0];
          if (![self.userAccount.username isEqualToString:[self getDefaultsScreenName]]) {
            [self updateDefaultsScreenName:self.userAccount.username];
          }
          handler(granted);
        }
      } else {
        NSLog(@"Failed to access the user account");
        handler(granted);
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
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults stringForKey:PREFER_SCREEN_NAME];
}

- (void) updateDefaultsScreenName:(NSString *)screen_name
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:screen_name forKey:PREFER_SCREEN_NAME];
  [defaults synchronize];
}
@end
