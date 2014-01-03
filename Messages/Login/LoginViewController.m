//
//  LoginViewController.m
//  LoginExample
//
//  Created by Frederik Jacques on 13/03/13.
//  Copyright (c) 2013 thenerd. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginView.h"
#import "LoginConstants.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()
@property (nonatomic, strong) LoginView *loginView;;
@end

@implementation LoginViewController

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.loginView = [[LoginView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.view addSubview:self.loginView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateHandler:) name:AUTHENTICATE_NOTIFICATION object:nil];
    [self.loginView showKeyboard];
}

- (void)authenticateHandler:(NSNotification *)notification {
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    
    NSDictionary *userDict = [notification userInfo];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"http://api.gongpengjun.com:90/messages/login.php";
    NSDictionary *parameters = @{@"username": userDict[@"username"], @"password" : userDict[@"password"]};
    [manager POST:url
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              if([responseObject objectForKey:@"error"]) {
                  [hud hide:NO];
                  [self showAlertWithTitle:@"ERROR" message:responseObject[@"error"][@"prompt"]];
              } else {
                  NSLog(@"%s,%d %@",__FUNCTION__,__LINE__,responseObject[@"message"]);
                  [hud hide:NO];
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userLoggedIn"];
                  [[NSUserDefaults standardUserDefaults] setObject:userDict[@"username"] forKey:@"username"];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [hud hide:NO];
              [self showAlertWithTitle:@"ERROR" message:[error localizedDescription]];
          }];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

- (void)dealloc {
    NSLog(@"[LoginViewController] Dealloc");
    self.loginView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AUTHENTICATE_NOTIFICATION object:self.view];
}

@end
