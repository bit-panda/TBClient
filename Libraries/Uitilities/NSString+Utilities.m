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

- (NSString*)encodeURL
{
    return self;
    NSString *newString = NSMakeCollectable([(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), NSUTF8StringEncoding) autorelease]);
    
    if (newString) {
        return newString;
    }
    return @"";
}

- (NSString *)URLEncode
{
    return [self URLEncodeWithEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLEncodeWithEncoding:(NSStringEncoding)encoding
{
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding)) autorelease];
}

@end
