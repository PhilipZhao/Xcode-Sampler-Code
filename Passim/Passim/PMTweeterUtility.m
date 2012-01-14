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

@end
@implementation PMTweeterUtility
@synthesize accountStore = _accountStore;
@synthesize accountType = _accountType;

- (id)init 
{
  if (self = [super init]) {
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  }
  return self;
}

- (void)requireAccessUserAccount
{
  
}

- (NSString *)getDefaultsScreenName 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults stringForKey:PREFER_SCREEN_NAME];
}

@end
