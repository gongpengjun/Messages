//
//  GPJFirstViewController.m
//  Messages
//
//  Created by 巩 鹏军 on 14-1-3.
//  Copyright (c) 2014年 巩 鹏军. All rights reserved.
//

#import "GPJFirstViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "LoginConstants.h"

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]

#define kAlertLogoutTag 1001

@interface GPJFirstViewController () <UITextFieldDelegate>
{
    UIToolbar *toolBar;
    BOOL _textViewFirstFocus;
}
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@end

@implementation GPJFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textViewFirstFocus = YES;
    self.messageTextField.inputAccessoryView = [self accessoryView];
}

- (UIToolbar *)accessoryView
{
	toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	toolBar.tintColor = [UIColor darkGrayColor];
	
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:BARBUTTON(@"Clear", @selector(clearText))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:BARBUTTON(@"Done", @selector(leaveKeyboardMode))];
	toolBar.items = items;
	
	return toolBar;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    if([textField isEqual:self.messageTextField]) {
        [self performSelector:@selector(sendAction:) withObject:nil afterDelay:0];
    }
    return YES;
}

#pragma mark - Image

- (UIImage*)imageToUpload {
    return [UIImage imageNamed:@"logout_button"];
}

#pragma mark - Button Actions

- (IBAction)sendAction:(id)sender
{
    UIImage *image = [self imageToUpload];
    if(self.messageTextField.text.length == 0 || !image)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Message or Image is empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    NSString* username = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
        username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:self];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"http://api.gongpengjun.com:90/messages/comboupload.php";
    NSDictionary *parameters = @{@"name": username, @"message" : self.messageTextField.text};
    [manager POST:url
       parameters:parameters
constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"userfile" fileName:@"logout_button.png" mimeType:@"image/png"];
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              // Configure for text only and offset down
              if([responseObject objectForKey:@"error"]) {
                  [hud hide:NO];
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:responseObject[@"error"][@"prompt"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                  alert.tag = kAlertLogoutTag;
                  [alert show];
              } else {
                  hud.labelText = responseObject[@"message"];
              }
              hud.mode = MBProgressHUDModeText;
              hud.margin = 10.f;
              hud.removeFromSuperViewOnHide = YES;
              [hud hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              hud.mode = MBProgressHUDModeText;
              hud.labelText = [error localizedDescription];
              hud.margin = 10.f;
              hud.removeFromSuperViewOnHide = YES;
              [hud hide:YES afterDelay:1];
          }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kAlertLogoutTag)
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:self];
}

- (void) clearText
{
    if([self.messageTextField isFirstResponder])
        [self.messageTextField setText:@""];
}

- (void) leaveKeyboardMode
{
	[self.view endEditing:YES];
}

@end
