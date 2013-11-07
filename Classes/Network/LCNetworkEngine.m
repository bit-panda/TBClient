//
//  LCNetworkEngine.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "LCNetworkEngine.h"
#import "SynthesizeSingleton.h"
#import "LCJSONNetworkClient.h"

@implementation LCNetworkEngine

SYNTHESIZE_SINGLETON_FOR_CLASS(LCNetworkEngine)

+ (LCNetworkEngine *)sharedInstance
{
    return [self sharedLCNetworkEngine];
}

//统计app打开次数
- (SNHTTPRequestOperationWrapper *)initCookieWithCompletionHandler:(LCActivityCompletionHandler)completionHandler
{
    LCNetworkClient *sharedNetworkClient = [LCNetworkClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    SNNetworkAddRequestParameter(params, @"appid", [LCGlobalManager currentBusiness].appid);
    
    return [sharedNetworkClient getPath:TBClient_Init_Cookie_Url parameters:params completionBlock:^(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject, NSError *error) {
        if (error)
        {
            if (completionHandler)
            {
                completionHandler(NO,nil,error);
            }
        }
        else
        {
            if (responseObject)
            {
                completionHandler(NO,responseObject, error);
            }
        }
    }];
}

- (SNHTTPRequestOperationWrapper *)readyLoginWithCompletionHandler:(LCActivityCompletionHandler)completionHandler
{
    LCJSONNetworkClient *sharedNetworkClient = [LCJSONNetworkClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [sharedNetworkClient getPath:TBClient_Init_Login_Aysn_Url parameters:params completionBlock:^(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject, NSError *error) {
        if (error)
        {
            if (completionHandler)
            {
                completionHandler(NO,nil,error);
            }
        }
        else
        {
            if (responseObject)
            {
                completionHandler(NO,responseObject, error);
            }
        }
    }];
}

- (SNHTTPRequestOperationWrapper *)loginWithName:(NSString *)name password:(NSString *)password extraParams:(NSDictionary *)extraParams CompletionHandler:(LCActivityCompletionHandler)completionHandler
{
    LCNetworkClient *sharedNetworkClient = [LCNetworkClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:extraParams];
    SNNetworkAddRequestParameter(params, @"uname", name);
    SNNetworkAddRequestParameter(params, @"appid", password);
    
    return [sharedNetworkClient getPath:TBClient_Login_Url parameters:params completionBlock:^(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject, NSError *error) {
        if (error)
        {
            if (completionHandler)
            {
                completionHandler(NO,nil,error);
            }
        }
        else
        {
            if (responseObject)
            {
                completionHandler(NO,responseObject, error);
            }
        }
    }];
}

@end
