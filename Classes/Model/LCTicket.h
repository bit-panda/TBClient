//
//  LCTicket.h
//  TBClient
//
//  Created by bitpanda on 13-11-18.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import <Foundation/Foundation.h>


@class HTMLNode;

@interface LCTicket : NSObject

@property (nonatomic, retain) NSString *fromStation;
@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *endTime;
@property (nonatomic, retain) NSString *takeTime;
@property (nonatomic, retain) NSString *trainCode;
@property (nonatomic, retain) NSString *trainID;
@property (nonatomic, retain) NSString *onclickInfo;

@property (nonatomic, assign) NSInteger leftSeatsBusiness;
@property (nonatomic, assign) NSInteger leftSeatsSuper;
@property (nonatomic, assign) NSInteger leftSeatsFirst;
@property (nonatomic, assign) NSInteger leftSeatsSecond;
@property (nonatomic, assign) NSInteger leftSeatsAdvanced;
@property (nonatomic, assign) NSInteger leftSeatsSoftSleeper;
@property (nonatomic, assign) NSInteger leftSeatsHardSleeper;
@property (nonatomic, assign) NSInteger leftSeatsSoftSeat;
@property (nonatomic, assign) NSInteger leftSeatsHardSeat;
@property (nonatomic, assign) NSInteger leftSeatsNoSeat;
@property (nonatomic, assign) NSInteger leftSeatsOther;

+ (NSArray *)ticketListWithHtmlData:(NSData *)htmlData;
+ (NSArray *)ticketListWithHtml:(NSString *)html;


+ (LCTicket *)ticketWithNode:(HTMLNode *)node;
@end
