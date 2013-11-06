//
//  NSDictionary+Activity.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "NSDictionary+Activity.h"

@implementation NSDictionary (Activity)

- (NSString *)activityStringForKey:(id)key
{
    NSString *object = [self objectForKey:key];
    
    if (![object isKindOfClass:[NSString class]])
    {
        object = @"";
    }
    
    return object;
}

- (BOOL)menuBoolForKey:(id)key
{
    NSString *object = [self objectForKey:key];
    if (!object || ![object isKindOfClass:[NSString class]])
    {
        return NO;
    }
    
    if ([[object lowercaseString] isEqualToString:@"true"])
    {
        return  YES;
    }
    
    return NO;
}

- (id)objectForKey:(id)aKey defaultValue:(id)value
{
    NSObject *object = [self objectForKey:aKey];
    
    if (!object)
    {
        object = value;
    }
    
    return object;
}

- (id)objectForKey:(id)aKey class:(Class)theClass defaultValue:(id)value
{
    NSObject *object = [self objectForKey:aKey];
    
    if (!object || ![object isKindOfClass:theClass])
    {
        object = value;
    }
    else if ([object isKindOfClass:[NSString class]] && [(NSString *)object length] == 0)
    {
        object = value;
    }
    
    return object;
}

@end
