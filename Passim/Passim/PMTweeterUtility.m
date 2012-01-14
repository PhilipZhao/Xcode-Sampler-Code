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
    
  }
  return self;
}

@end
