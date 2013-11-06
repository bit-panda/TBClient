//
//  Util.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-15.
//  Copyright (c) 2013年 cxz. All rights reserved.
//



#import <Foundation/Foundation.h>

/**
 import进来自定义的基于iOS SDK的拓展类。
 */
#import "LCVars.h"
#import "UIImage+Local.h"
#import "UITabBar+Background.h"
#import "NSObject+SafeBlock.h"
#import "NSDictionary+Activity.h"
#import "NSString+Utilities.h"
#import "NSDate+Local.h"
#import "UIColor+Local.h"

NSString* loadMuLanguage(NSString *keyValue,NSString *defaultLanguage);

NSURLRequest* tweeteroURLRequest(NSURL* url);
NSMutableURLRequest* tweeteroMutableURLRequest(NSURL* url);
NSString* platform();
NSString* platformString();

