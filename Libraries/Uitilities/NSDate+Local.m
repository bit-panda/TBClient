//
//  NSDate+Local.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-6-12.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "NSDate+Local.h"

@implementation NSDate (Local)

- (NSString *)toString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:self];
}

- (NSString *)toDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:self];
}

- (NSString *)toNoteString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssffffffff"];
    
    return [formatter stringFromDate:self];
}

+(NSDate*)dateFromString:(NSString*)uiDate
{
    return [self dateFromString:uiDate formatter:@"yyyy-MM-dd HH:mm:ss"];
}

+(NSDate*)dateFromString:(NSString*)uiDate formatter:(NSString *)formatterString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:formatterString];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}

@end
