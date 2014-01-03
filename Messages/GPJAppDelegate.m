//
//  GPJAppDelegate.m
//  Messages
//
//  Created by 巩 鹏军 on 14-1-3.
//  Copyright (c) 2014年 巩 鹏军. All rights reserved.
//

#import "GPJAppDelegate.h"
#import "LoginViewController.h"
#import "LoginConstants.h"
#import "CookieManager.h"

@implementation GPJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CookieManager loadCookies];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutHandler:) name:LOGOUT_NOTIFICATION object:nil];
    [self performSelector:@selector(startLogin) withObject:nil afterDelay:0];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Login

- (void)startLogin
{
    BOOL isUserLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"];
    
    if( !isUserLoggedIn ){
        [self showLoginViewAnimated:NO];
    }
}

- (void)showLoginViewAnimated:(BOOL)animated
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.window.rootViewController presentViewController:loginVC animated:animated completion:nil];
    
}

- (void)logoutHandler:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [CookieManager deleteCookies];
    [self showLoginViewAnimated:YES];
}

@end
