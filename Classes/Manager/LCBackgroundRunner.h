//
//  LCBackgroundRunner.h
//  TBClient
//
//  Created by bitpanda on 13-11-15.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCBackgroundRunner : NSObject
{
    BOOL holding;
}

+ (LCBackgroundRunner *)sharedInstance;

- (void)hold;
- (void)stop;
- (void)run;

@end
