//
//  LCNetworkClient.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "LCNetworkClient.h"
#import "LCHTTPRequestOperation.h"
#import "LCJSONRequestOperation.h"

@implementation LCNetworkClient

+ (id)sharedClient
{
    static LCNetworkClient *_sharedClient = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSURL *url = [NSURL URLWithString:LCDOMAIN];
        _sharedClient = [[self alloc] initWithBaseURL:url type:LCNETWORK_CLIENT_TYPE_STRING];
    });
    
    return _sharedClient;
}

+ (id)sharedJsonClient
{
    static LCNetworkClient *_sharedJsonClient = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSURL *url = [NSURL URLWithString:LCDOMAIN];
        _sharedJsonClient = [[self alloc] initWithBaseURL:url type:LCNETWORK_CLIENT_TYPE_JSON];
    });
    
    return _sharedJsonClient;
}

- (id)initWithBaseURL:(NSURL *)url type:(LCNETWORK_CLIENT_TYPE)type
{
    if ((self = [super initWithBaseURL:url]))
    {
        self.clientType = type;
        
        switch (type)
        {
            case LCNETWORK_CLIENT_TYPE_JSON:
            {
                [self registerHTTPOperationClass:[LCJSONRequestOperation class]];
                break;
            }
            
            case LCNETWORK_CLIENT_TYPE_STRING:
            default:
            {
                [self registerHTTPOperationClass:[LCHTTPRequestOperation class]];
                break;
            }
        }
        

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
