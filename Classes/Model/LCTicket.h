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
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *trainCode;


+ (NSArray *)ticketListWithHtml:(NSData *)html;

+ (LCTicket *)ticketWithNode:(HTMLNode *)node;
@end
