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
        username = @"bitpanda";
        password = @"756panda894";
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
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
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
    }];
    
    [[ImageLoader sharedLoader] setImageWithURL:@"https://dynamic.12306.cn/otsweb/passCodeNewAction.do?module=login&rand=sjrand" toView:verifyImageView];
}

- (void)loginAction
{
    
}


@end
