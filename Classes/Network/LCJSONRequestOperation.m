//
//  LCJSONRequestOperation.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "LCJSONRequestOperation.h"
#import "SNNetworking.h"

@interface LCJSONRequestOperation (LCNetworking)
@property (readwrite, nonatomic, retain) NSError *JSONError;
@end

@implementation LCJSONRequestOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request
{
    // 只接受普通request
    NSString *requestTag = [request valueForHTTPHeaderField:kSNNetworkRequestHeaderTagName];
    BOOL isNormalRequest = [requestTag isEqualToString:kSNNetworkRequestHeaderTagValueNormal] || [requestTag isEqualToString:kSNNetworkRequestHeaderTagValueUpload];
    
    return isNormalRequest;
}

+ (NSSet *)acceptableContentTypes
{
    // 接受 text/html 作为响应头
    return [NSSet setWithObjects:@"text/html", @"application/json", @"text/json", @"text/javascript", nil];
}

- (id)responseJSON
{    
    id responseJSON = [super responseJSON];

    return responseJSON;
}

@end
