//
//  NSString+Utilities.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-6-9.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (BOOL)isEmptyOrWhitespace
{
    // A nil or NULL string is not the same as an empty string
    return 0 == self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

@end
