//
//  LCAccount.h
//  TBClient
//
//  Created by bitpanda on 13-11-18.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCAccount : NSObject

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSString *fromstation;
@property (nonatomic, retain) NSString *trainNumber;

@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *time;

@property (nonatomic, retain) NSString *trainPassType;
@property (nonatomic, retain) NSString *trainPassClass;

@property (nonatomic, assign) BOOL includeStudent;
@property (nonatomic, retain) NSString *seatTypeAndNumber;

- (NSString *)includeStudentCode;

- (NSString *)destinationCode;

- (NSString *)fromstationCode;

@end
