//
//  LCJSONNetworkClient.m
//  TBClient
//
//  Created by cxz(@bitpanda) on 13-11-6.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCJSONNetworkClient.h"
#import "LCJSONRequestOperation.h"

@implementation LCJSONNetworkClient

+ (id)sharedClient
{
    static LCJSONNetworkClient *_sharedClient = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSURL *url = [NSURL URLWithString:LCJSONDOMAIN];
        _sharedClient = [[self alloc] initWithBaseURL:url];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if ((self = [super initWithBaseURL:url]))
    {
        [self registerHTTPOperationClass:[LCJSONRequestOperation class]];
        //        [self registerErrorHandlerClass:[XX class]];
        
        [self initDefaultParameters];
        
        
        
        self.handleSafeBlockObjectDeallocNotification = YES;
    }
    
    return self;
}


- (void)initDefaultParameters
{
    
}

- (void)setDefaultHttpHeaderForRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:11.0) Gecko/20100101 Firefox/11.0" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"dynamic.12306.cn" forHTTPHeaderField:@"Host"];
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                       tag:(NSString *)tag
                   appendDefaultParameters:(BOOL)appendDefaultParameters
{
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters tag:tag appendDefaultParameters:appendDefaultParameters];
    
    
    return request;
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
{
    NSMutableURLRequest *request = [super multipartFormRequestWithMethod:method path:path parameters:parameters constructingBodyWithBlock:block];
    
    
    return request;
}

@end
