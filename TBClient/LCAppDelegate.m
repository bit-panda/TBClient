//
//  LCAppDelegate.m
//  TBClient
//
//  Created by bitpanda on 13-11-5.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCAppDelegate.h"
#import "LCHomeViewController.h"
#import "LCBackgroundRunner.h"

@implementation LCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[[LCHomeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[LCBackgroundRunner sharedInstance] run];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LCBackgroundRunner sharedInstance] stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
