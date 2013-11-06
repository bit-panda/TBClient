//
//  Util.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-15.
//  Copyright (c) 2013年 cxz. All rights reserved.
//


#include <sys/types.h>
#include <sys/sysctl.h>

#import "Util.h"

NSString* loadMuLanguage(NSString *keyValue,NSString *defaultLanguage)
{
    return keyValue;
}

NSURLRequest* tweeteroURLRequest(NSURL* url)
{
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	return req;
}

NSMutableURLRequest* tweeteroMutableURLRequest(NSURL* url)
{
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	return req;
}

NSString* platform()
{
    size_t msize;
    sysctlbyname("hw.machine", NULL, &msize, NULL, 0);
    char *machine = malloc(msize);
    sysctlbyname("hw.machine", machine, &msize, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

NSString* platformString()
{
    NSString *plat = platform();
    if ([plat isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([plat isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([plat isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([plat isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([plat isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([plat isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([plat isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([plat isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([plat isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([plat isEqualToString:@"i386"] || [plat isEqualToString:@"x86_64"])         return @"iPhone Simulator";
    return plat;
}