//
//  LCNetworkEngine.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCNetworkClient.h"

#define TBClient_Host_Url                @"https://dynamic.12306.cn/"
#define TBClient_Init_Cookie_Url         @"otsweb/loginAction.do?method=init"
#define TBClient_Get_Rand_Code_Url       @"otsweb/passCodeAction.do?rand=sjrand"
#define TBClient_Refresh_Rand_Code_Url   @""
#define TBClient_Init_Login_Aysn_Url     @"otsweb/loginAction.do?method=loginAysnSuggest"
#define TBClient_Login_Url               @"otsweb/loginAction.do?method=login"
#define TBClient_Inquire_Tickets_Url     @"otsweb/order/querySingleAction.do?method=queryLeftTicket"

typedef void(^LCActivityCompletionHandler)(BOOL success,id responseObject, NSError *error);

@interface LCNetworkEngine : NSObject

+ (LCNetworkEngine *)sharedInstance;

//统计app打开次数
- (SNHTTPRequestOperationWrapper *)initCookieWithCompletionHandler:(LCActivityCompletionHandler)completionHandler;


@end
