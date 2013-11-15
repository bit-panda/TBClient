//
//  LCLoopLoadManager.m
//  TBClient
//
//  Created by bitpanda on 13-11-15.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCLoopLoadManager.h"

@implementation LCLoopLoadManager

+ (LCLoopLoadManager *)sharedInstance
{
    static LCLoopLoadManager *sharedManager;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        sharedManager = [[LCLoopLoadManager alloc] init];
    });
    
    return sharedManager;
}

- (id) init
{
    self = [super init];
    if (self) {
        step = kLCLOOP_STATUS_STEP_INIT;
    }
    
    return self;
}

- (void)start
{
    running = YES;
    [self runLoop];
}

- (void)runLoop
{
    if (!running)
    {
        return;
    }
    
    switch (step)
    {
        case kLCLOOP_STATUS_STEP_INIT:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_INIT_DATA:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_INIT_DATA:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_LOAD_VERIFYIMAGE:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOAD_VERIFYIMAGE:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_INIT_LOGIN:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_INIT_LOGIN:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_LOGIN:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOGIN_SUCCESS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOGIN_FAILED:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_LOAD_TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOAD_TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_CHECK__TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_CHECK__TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_ISSURE__TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_ISSURE__TICKETS_SUCCESS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_ISSURE__TICKETS_FAILED:
        {
            
            break;
        }
            
        case kLCLOOP_STATUS_STEP_DONE:
        default:
        {
            running = NO;
            break;
        }
    }
    
}
@end
