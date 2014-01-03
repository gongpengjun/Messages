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

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]

@interface GPJFirstViewController () <UITextFieldDelegate>
{
    UIToolbar *toolBar;
    BOOL _textViewFirstFocus;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@end

@implementation GPJFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textViewFirstFocus = YES;
    self.nameTextField.inputAccessoryView = [self accessoryView];
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
    if([textField isEqual:self.nameTextField]) {
        [self.messageTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    } else if([textField isEqual:self.messageTextField]) {
        [self performSelector:@selector(sendAction:) withObject:nil afterDelay:0];
    }
    return YES;
}

#pragma mark - Button Actions

- (IBAction)sendAction:(id)sender
{
    
    if(self.nameTextField.text.length == 0 || self.messageTextField.text.length == 0)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Name or Message is empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"http://api.gongpengjun.com:90/messages/post.php";
    NSDictionary *parameters = @{@"name": self.nameTextField.text, @"message" : self.messageTextField.text};
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = responseObject[@"message"];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [error localizedDescription];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:3];
    }];
}

- (void) clearText
{
    if([self.nameTextField isFirstResponder])
        [self.nameTextField setText:@""];
    if([self.messageTextField isFirstResponder])
        [self.messageTextField setText:@""];
}

- (void) leaveKeyboardMode
{
	[self.view endEditing:YES];
}


@end
