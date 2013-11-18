//
//  LCHomeViewController.m
//  TBClient
//
//  Created by bitpanda on 13-11-5.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCHomeViewController.h"
#import "LCNetworkEngine.h"
#import "ImageLoader.h"
#import "LCAccountManager.h"
#import "LCLoopLoadManager.h"

@interface LCHomeViewController ()
{
    NSString *username;
    NSString *password;
    NSString *verifyCode;
    NSString *loginRand;
 
    UIButton *loginButton;
    UITextView *verifyTextView;
    UIImageView *verifyImageView;
    UILabel *flagLabel;
}

@end

@implementation LCHomeViewController

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [LCAccountManager current].username = @"张特";
        [LCAccountManager current].nickname = @"bi7trace";
        [LCAccountManager current].password = @"my_local";
        
        [LCAccountManager current].date = [[NSDate date] toDateString];
        [LCAccountManager current].time = @"00:00--24:00";
        
        [LCAccountManager current].trainPassType = @"QB";
        [LCAccountManager current].trainPassClass = @"QB#D#Z#T#K#QT#";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    verifyTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 30, 60, 30)];
    [self.view addSubview:verifyTextView];
    
    verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 60, 30)];
    verifyImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:verifyImageView];
    
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 140, 60, 30)];
    loginButton.backgroundColor = [UIColor blueColor];
    [loginButton addTarget:self action:@selector(readyForLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 100, 30)];
    flagLabel.text = [NSString stringWithFormat:@"%d + %d", [LCLoopLoadManager sharedInstance].countOfGetTickets, [LCLoopLoadManager sharedInstance].countOfLogin];
    [self.view addSubview:flagLabel];
    
    [LCLoopLoadManager sharedInstance].verifyImageView = verifyImageView;
    
    [[LCLoopLoadManager sharedInstance] start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void) refreshLablel
{
    flagLabel.text = [NSString stringWithFormat:@"%d + %d", [LCLoopLoadManager sharedInstance].countOfGetTickets, [LCLoopLoadManager sharedInstance].countOfLogin];
}

- (void)initLoginData
{
    [[LCNetworkEngine sharedInstance] initCookieWithCompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",html);
        [self verifyImage];
    }];
    

}

- (void)verifyImage
{
    [[ImageLoader sharedLoader] setImageWithURL:@"https://dynamic.12306.cn/otsweb/passCodeNewAction.do?module=login&rand=sjrand" toView:verifyImageView];
}

- (void)readyForLogin
{
    [[LCNetworkEngine sharedInstance] readyLoginWithCompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        loginRand = [[responseObject objectForKey:@"loginRand"] retain];
        [self loginAction];
    }];
}

- (void)loginAction
{
    [LCLoopLoadManager sharedInstance].verifyCodeString = verifyTextView.text;
    [LCLoopLoadManager sharedInstance].step = kLCLOOP_STATUS_STEP_DID_LOAD_VERIFYIMAGE;
    [[LCLoopLoadManager sharedInstance] start];
}

- (void)initLeftTicket
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"2013-11-13" forKey:@"orderRequest.train_date"];
    [params setObject:@"BJP" forKey:@"orderRequest.from_station_telecode"];
    [params setObject:@"SHH" forKey:@"orderRequest.to_station_telecode"];
    [params setObject:@"" forKey:@"orderRequest.train_no"];
    [params setObject:@"QB" forKey:@"trainPassType"];
    [params setObject:@"QB#D#Z#T#K#QT#" forKey:@"trainClass"];
    [params setObject:@"00" forKey:@"includeStudent"];
    [params setObject:@"" forKey:@"seatTypeAndNum"];
    [params setObject:@"00:00--24:00" forKey:@"orderRequest.start_time_str"];
    
    [[LCNetworkEngine sharedInstance] leftTicketInitWithExtraParams:params CompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",html);
        
        [self leftTicket];
    }];
    
    
}

- (void)leftTicket
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"2013-11-13" forKey:@"orderRequest.train_date"];
    [params setObject:@"BJP" forKey:@"orderRequest.from_station_telecode"];
    [params setObject:@"SHH" forKey:@"orderRequest.to_station_telecode"];
    [params setObject:@"" forKey:@"orderRequest.train_no"];
    [params setObject:@"QB" forKey:@"trainPassType"];
    [params setObject:@"QB#D#Z#T#K#QT#" forKey:@"trainClass"];
    [params setObject:@"00" forKey:@"includeStudent"];
    [params setObject:@"" forKey:@"seatTypeAndNum"];
    [params setObject:@"00:00--24:00" forKey:@"orderRequest.start_time_str"];
    
    [[LCNetworkEngine sharedInstance] leftTicketWithExtraParams:params CompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",html);
        
        
    }];
    
    
}


@end
