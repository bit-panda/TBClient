//
//  LCJSONNetworkClient.h
//  TBClient
//
//  Created by cxz(@bitpanda) on 13-11-6.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "SNNetworkClient.h"
#define LCJSONDOMAIN            @"https://dynamic.12306.cn/"

@interface LCJSONNetworkClient : SNNetworkClient

+ (id)sharedClient;
+ (id)sharedJsonClient;
@end
