//
//  LCTicketsViewController.h
//  TBClient
//
//  Created by bitpanda on 13-11-20.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCViewController.h"

@interface LCTicketsViewController : LCViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *ticketList;

@end
