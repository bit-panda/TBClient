//
//  LCBackgroundRunner.m
//  TBClient
//
//  Created by bitpanda on 13-11-15.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCBackgroundRunner.h"

@implementation LCBackgroundRunner

+ (LCBackgroundRunner *)sharedInstance
{
    static LCBackgroundRunner *sharedRunner;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        sharedRunner = [[LCBackgroundRunner alloc] init];
    });
    
    return sharedRunner;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        ;
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark - public method

- (void)hold
{
    holding = YES;
    while (holding)
    {
        [NSThread sleepForTimeInterval:1];
        /** clean the runloop for other source */
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
    }
}

- (void)stop
{
    holding = NO;
}

- (void)run
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask;
    
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [self hold];
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
}

@end
