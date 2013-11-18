//
//  LCAccountManager.m
//  TBClient
//
//  Created by bitpanda on 13-11-18.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCAccountManager.h"

@implementation LCAccountManager

+ (LCAccount *)current
{
    static LCAccount *currentAccount;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        currentAccount = [[LCAccount alloc] init];
    });
    
    return currentAccount;
}

@end
