//
//  LCNetworkClient.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "SNNetworkClient.h"
#import "SNNetworking.h"

#define LCDOMAIN            @"https://dynamic.12306.cn/"

@interface LCNetworkClient : SNNetworkClient

+ (id)sharedClient;
- (void)initDefaultParameters;

@end
