//
//  LCAccount.m
//  TBClient
//
//  Created by bitpanda on 13-11-18.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCAccount.h"

@implementation LCAccount

- (void) dealloc
{
    [_username release], _username = nil;
    [_nickname release], _nickname = nil;
    [_password release], _password = nil;

    [_destination release], _destination = nil;
    [_fromstation release], _fromstation = nil;
    [_trainNumber release], _trainNumber = nil;
    
    [_date release], _date =nil;
    [_time release], _time = nil;
    
    [_trainPassType release], _trainPassType = nil;
    [_trainPassClass release], _trainPassClass = nil;
    
    [_seatTypeAndNumber release], _seatTypeAndNumber = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.username = @"";
        self.nickname = @"";
        self.password = @"";
        
        self.destination = @"";
        self.fromstation = @"";
        
        self.trainNumber = @"";
        self.date = @"";
        self.time = @"";
        
        self.trainPassType = @"";
        self.trainPassClass = @"";
        self.trainNumber = @"";
        
        self.includeStudent = NO;
        self.seatTypeAndNumber = @"";
    }
    
    return self;
}

- (NSString *)includeStudentCode
{
    return self.includeStudent ? @"11" : @"00";
}

- (NSString *)destinationCode
{
    return @"BJP";
}

- (NSString *)fromstationCode
{
    return @"SHH";
}

@end
