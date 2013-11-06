//
//  NSDictionary+Activity.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Activity)

- (NSString *)activityStringForKey:(id)key;
- (BOOL)menuBoolForKey:(id)key;
- (id)objectForKey:(id)aKey defaultValue:(id)value;
- (id)objectForKey:(id)aKey class:(Class)theClass defaultValue:(id)value;

@end
