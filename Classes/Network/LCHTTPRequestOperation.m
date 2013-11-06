//
//  LCHTTPRequestOperation.m
//  TBClient
//
//  Created by bitpanda on 13-11-6.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCHTTPRequestOperation.h"
#import "SNNetworking.h"

@interface LCHTTPRequestOperation (LCNetworking)

@property (readwrite, nonatomic, retain) NSError *JSONError;

@end


@implementation LCHTTPRequestOperation


+ (BOOL)canProcessRequest:(NSURLRequest *)request
{
    return YES;
}

+ (NSSet *)acceptableContentTypes
{
    // 接受 text/html 作为响应头
    return [NSSet setWithObjects:@"text/html", @"application/json", @"text/json", @"text/javascript", nil];
}

@end
