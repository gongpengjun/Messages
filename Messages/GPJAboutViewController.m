//
//  GPJAboutViewController.m
//  Messages
//
//  Created by 巩 鹏军 on 14-1-3.
//  Copyright (c) 2014年 巩 鹏军. All rights reserved.
//

#import "GPJAboutViewController.h"
#import "GPJAppDelegate.h"
#import "LoginConstants.h"

@interface GPJAboutViewController ()

@end

@implementation GPJAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
        return 2;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.row == 0) {
        static NSString *CellIdentifier = @"UserCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"User";
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
            cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        else
            cell.detailTextLabel.text = @"";
    } else if(indexPath.row == 1) {
        static NSString *CellIdentifier = @"LogoutCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Logout";
    } else {
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1) {
        // do logout
        //NSLog(@"%s,%d Logout",__FUNCTION__,__LINE__);
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:self];        
    }
}

@end
