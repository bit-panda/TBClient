//
//  LCNetworkEngine.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "LCNetworkEngine.h"
#import "SynthesizeSingleton.h"
#import "NSString+Utilities.h"

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
    LCNetworkClient *sharedNetworkClient = [LCNetworkClient sharedJsonClient];
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
    SNNetworkAddRequestParameter(params, @"loginUser.user_name", name);
    SNNetworkAddRequestParameter(params, @"user.password", password);
    
    return [sharedNetworkClient postPath:TBClient_Login_Url parameters:params completionBlock:^(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject, NSError *error) {
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

- (SNHTTPRequestOperationWrapper *)leftTicketInitWithExtraParams:(NSDictionary *)extraParams CompletionHandler:(LCActivityCompletionHandler)completionHandler
{
    LCNetworkClient *sharedNetworkClient = [LCNetworkClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:extraParams];
    
    
    return [sharedNetworkClient getPath:TBClient_Init_Tickets_Url parameters:params completionBlock:^(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject, NSError *error) {
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

- (SNHTTPRequestOperationWrapper *)leftTicketWithExtraParams:(NSDictionary *)extraParams CompletionHandler:(LCActivityCompletionHandler)completionHandler
{
    LCNetworkClient *sharedNetworkClient = [LCNetworkClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:extraParams];

    
    NSMutableString *paramString = [NSMutableString stringWithString:@""];

    NSMutableArray *paramsSort = [NSMutableArray array];
    [paramsSort addObject:@"orderRequest.train_date"];
    [paramsSort addObject:@"orderRequest.from_station_telecode"];
    [paramsSort addObject:@"orderRequest.to_station_telecode"];
    [paramsSort addObject:@"orderRequest.train_no"];
    [paramsSort addObject:@"trainPassType"];
    [paramsSort addObject:@"trainClass"];
    [paramsSort addObject:@"includeStudent"];
    [paramsSort addObject:@"seatTypeAndNum"];
    [paramsSort addObject:@"orderRequest.start_time_str"];
    
    [paramsSort enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [paramString appendFormat:@"&%@=%@",[(NSString *)obj URLEncode], [[params objectForKey:obj] URLEncode]];
    }];
    
    
    return [sharedNetworkClient getPath:[NSString stringWithFormat:@"%@%@",TBClient_Inquire_Tickets_Url, [paramString stringByRemovingPercentEncoding]] parameters:nil completionBlock:^(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject, NSError *error) {
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
