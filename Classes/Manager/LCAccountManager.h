//
//  LCAccountManager.h
//  TBClient
//
//  Created by bitpanda on 13-11-18.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCAccount.h"

@interface LCAccountManager : NSObject


+ (LCAccount *)current;

@end
