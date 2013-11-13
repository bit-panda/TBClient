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

@interface LCHomeViewController ()
{
    NSString *username;
    NSString *password;
    NSString *verifyCode;
    NSString *loginRand;
 
    UIButton *loginButton;
    UITextView *verifyTextView;
    UIImageView *verifyImageView;
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
        username = @"bi7trace";
        password = @"my_local";
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
    
    [self initLoginData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
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
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"null" forKey:@"form_tk"];
    [params setObject:@"undefined" forKey:@"myversion"];
    [params setObject:@"Y" forKey:@"refundFlag"];
    [params setObject:@"N" forKey:@"refundLogin"];
    [params setObject:verifyTextView.text forKey:@"randCode"];
    [params setObject:loginRand forKey:@"loginRand"];
    
    [[LCNetworkEngine sharedInstance] loginWithName:username password:password extraParams:params CompletionHandler:^(BOOL success, id responseObject, NSError *error) {
        NSString *html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",html);
        [self initLeftTicket];
        
    }];
    
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
