//
//  LCLoopLoadManager.h
//  TBClient
//
//  Created by bitpanda on 13-11-15.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum kLCLOOP_STATUS_STEP
{
    kLCLOOP_STATUS_STEP_INIT = 0,
    
    kLCLOOP_STATUS_STEP_WILL_INIT_DATA,
    kLCLOOP_STATUS_STEP_DID_INIT_DATA,
    
    kLCLOOP_STATUS_STEP_WILL_LOAD_VERIFYIMAGE,
    kLCLOOP_STATUS_STEP_DID_LOAD_VERIFYIMAGE,
    
    kLCLOOP_STATUS_STEP_WILL_INIT_LOGIN,
    kLCLOOP_STATUS_STEP_DID_INIT_LOGIN,
    
    kLCLOOP_STATUS_STEP_WILL_LOGIN,
    kLCLOOP_STATUS_STEP_DID_LOGIN_SUCCESS,
    kLCLOOP_STATUS_STEP_DID_LOGIN_FAILED,
    
    kLCLOOP_STATUS_STEP_WILL_LOAD_TICKETS,
    kLCLOOP_STATUS_STEP_DID_LOAD_TICKETS,
    
    kLCLOOP_STATUS_STEP_WILL_CHECK__TICKETS,
    kLCLOOP_STATUS_STEP_DID_CHECK__TICKETS,
    
    kLCLOOP_STATUS_STEP_WILL_ISSURE__TICKETS,
    kLCLOOP_STATUS_STEP_DID_ISSURE__TICKETS_SUCCESS,
    kLCLOOP_STATUS_STEP_DID_ISSURE__TICKETS_FAILED,
    
    kLCLOOP_STATUS_STEP_DONE
}kLCLOOP_STATUS_STEP;


typedef enum kLCLoginFailedType
{
    kLCLoginFailedTypeUnknown = 0,
    kLCLoginFailedTypeErrorUsername,
    kLCLoginFailedTypeErrorPassword,
    kLCLoginFailedTypeErrorVerifycode
    
}kLCLoginFailedType;

@interface LCLoopLoadManager : NSObject
{
    kLCLOOP_STATUS_STEP step;
    BOOL running;
}

+ (LCLoopLoadManager *)sharedInstance;

@end
