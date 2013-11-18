//
//  LCLoopLoadManager.m
//  TBClient
//
//  Created by bitpanda on 13-11-15.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCLoopLoadManager.h"
#import "LCNetworkEngine.h"
#import "ImageLoader.h"
#import "LCAccountManager.h"
#import "LCTicket.h"

@implementation LCLoopLoadManager

@synthesize step;

+ (LCLoopLoadManager *)sharedInstance
{
    static LCLoopLoadManager *sharedManager;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        sharedManager = [[LCLoopLoadManager alloc] init];
    });
    
    return sharedManager;
}

- (void) dealloc
{
    [_verifyImageView release], _verifyImageView = nil;
    
    if (loginRand)
    {
        [loginRand release], loginRand = nil;
    }
    
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        step = kLCLOOP_STATUS_STEP_INIT;
        
        username = @"bi7trace";
        password = @"my_local";
    }
    
    return self;
}

- (void)start
{
    running = YES;
    [self runLoop];
}

- (void) stop
{
    running = NO;
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
            [self initLoginData];
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_INIT_DATA:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_INIT_DATA:
        {
            [self loadVerifyImage];
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_LOAD_VERIFYIMAGE:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOAD_VERIFYIMAGE:
        {
            [self readyForLogin];
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_INIT_LOGIN:
        {
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_INIT_LOGIN:
        {
            [self loginAction];
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_LOGIN:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOGIN_SUCCESS:
        {
            [self initLeftTicket];
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOGIN_FAILED:
        {
            if (loginFailedType == kLCLoginFailedTypeErrorVerifycode)
            {
                step = kLCLOOP_STATUS_STEP_DID_INIT_DATA;
                [self runLoop];
            }
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_CHECK__TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_CHECK__TICKETS:
        {
            [self getLeftTicket];
            break;
        }
        case kLCLOOP_STATUS_STEP_WILL_LOAD_TICKETS:
        {
            
            break;
        }
        case kLCLOOP_STATUS_STEP_DID_LOAD_TICKETS:
        {
            [NSThread sleepForTimeInterval:1];
            [self initLeftTicket];
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


#pragma mark - action
- (void)initLoginData
{
    step = kLCLOOP_STATUS_STEP_WILL_INIT_DATA;
    [[LCNetworkEngine sharedInstance] initCookieWithCompletionHandler:^(BOOL success, id responseObject, NSError *error) {
//        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",html);
        
        step = kLCLOOP_STATUS_STEP_DID_INIT_DATA;
        [self runLoop];
    }];
}

- (void)loadVerifyImage
{
    step = kLCLOOP_STATUS_STEP_WILL_LOAD_VERIFYIMAGE;
    [[ImageLoader sharedLoader] setImageWithURL:@"https://dynamic.12306.cn/otsweb/passCodeNewAction.do?module=login&rand=sjrand" toView:self.verifyImageView];
}

- (void)readyForLogin
{
    if (loginRand)
    {
        [loginRand release];
    }
    
    step = kLCLOOP_STATUS_STEP_WILL_INIT_LOGIN;
    [[LCNetworkEngine sharedInstance] readyLoginWithCompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        loginRand = [[responseObject objectForKey:@"loginRand"] retain];
        
        step = kLCLOOP_STATUS_STEP_DID_INIT_LOGIN;
        [self runLoop];
    }];
}

- (void)loginAction
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"null" forKey:@"form_tk"];
    [params setObject:@"undefined" forKey:@"myversion"];
    [params setObject:@"Y" forKey:@"refundFlag"];
    [params setObject:@"N" forKey:@"refundLogin"];
    [params setObject:self.verifyCodeString forKey:@"randCode"];
    [params setObject:loginRand forKey:@"loginRand"];
    
    step = kLCLOOP_STATUS_STEP_WILL_LOGIN;
    [[LCNetworkEngine sharedInstance] loginWithName:[LCAccountManager current].nickname password:[LCAccountManager current].password extraParams:params CompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([html rangeOfString:[LCAccountManager current].username].location != NSNotFound)
        {
            step = kLCLOOP_STATUS_STEP_DID_LOGIN_SUCCESS;
        }
        else
        {
            step = kLCLOOP_STATUS_STEP_DID_LOGIN_FAILED;
        }

        [self runLoop];
    }];
    
}

- (void)initLeftTicket
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[LCAccountManager current].date forKey:@"orderRequest.train_date"];
    [params setObject:[[LCAccountManager current] destinationCode] forKey:@"orderRequest.from_station_telecode"];
    [params setObject:[[LCAccountManager current] fromstationCode] forKey:@"orderRequest.to_station_telecode"];
    [params setObject:[LCAccountManager current].trainNumber forKey:@"orderRequest.train_no"];
    [params setObject:[LCAccountManager current].trainPassType forKey:@"trainPassType"];
    [params setObject:[LCAccountManager current].trainPassClass forKey:@"trainClass"];
    [params setObject:[[LCAccountManager current] includeStudentCode] forKey:@"includeStudent"];
    [params setObject:[LCAccountManager current].seatTypeAndNumber forKey:@"seatTypeAndNum"];
    [params setObject:[LCAccountManager current].time forKey:@"orderRequest.start_time_str"];
    
    step = kLCLOOP_STATUS_STEP_WILL_CHECK__TICKETS;
    [[LCNetworkEngine sharedInstance] leftTicketInitWithExtraParams:params CompletionHandler:^(BOOL success, id responseObject, NSError *error) {
//        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",html);
        step = kLCLOOP_STATUS_STEP_DID_CHECK__TICKETS;
        [self runLoop];
    }];
    
    
}

- (void)getLeftTicket
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[LCAccountManager current].date forKey:@"orderRequest.train_date"];
    [params setObject:[[LCAccountManager current] destinationCode] forKey:@"orderRequest.from_station_telecode"];
    [params setObject:[[LCAccountManager current] fromstationCode] forKey:@"orderRequest.to_station_telecode"];
    [params setObject:[LCAccountManager current].trainNumber forKey:@"orderRequest.train_no"];
    [params setObject:[LCAccountManager current].trainPassType forKey:@"trainPassType"];
    [params setObject:[LCAccountManager current].trainPassClass forKey:@"trainClass"];
    [params setObject:[[LCAccountManager current] includeStudentCode] forKey:@"includeStudent"];
    [params setObject:[LCAccountManager current].seatTypeAndNumber forKey:@"seatTypeAndNum"];
    [params setObject:[LCAccountManager current].time forKey:@"orderRequest.start_time_str"];
    
    step = kLCLOOP_STATUS_STEP_WILL_LOAD_TICKETS;
    [[LCNetworkEngine sharedInstance] leftTicketWithExtraParams:params CompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",html);
        
        if ([html isEqualToString:@"-10"])
        {
            step = kLCLOOP_STATUS_STEP_DONE;
            self.countOfLogin = 111;
        }
        else
        {
            NSArray *array = [LCTicket ticketListWithHtml:responseObject];
            
            step = kLCLOOP_STATUS_STEP_DID_LOAD_TICKETS;
            self.countOfGetTickets += 1;
            
            [self runLoop];
        }

    }];
}

@end
