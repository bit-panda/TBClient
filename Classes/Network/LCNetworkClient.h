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

typedef enum
{
    LCNETWORK_CLIENT_TYPE_STRING = 0,
    LCNETWORK_CLIENT_TYPE_JSON = 1,
} LCNETWORK_CLIENT_TYPE;

@interface LCNetworkClient : SNNetworkClient

@property (nonatomic, assign) LCNETWORK_CLIENT_TYPE clientType;

+ (id)sharedClient;
+ (id)sharedJsonClient;
- (void)initDefaultParameters;

@end
