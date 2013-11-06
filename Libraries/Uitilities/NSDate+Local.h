//
//  NSDate+Local.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-6-12.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Local)

- (NSString *)toString;
- (NSString *)toDateString;
- (NSString *)toNoteString;
+(NSDate*)dateFromString:(NSString*)uiDate;
+(NSDate*)dateFromString:(NSString*)uiDate formatter:(NSString *)formatterString;
@end
