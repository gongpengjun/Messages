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
#import "UIImage+Resize.h"

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]

#define kAlertLogoutTag 1001

@interface GPJFirstViewController () <UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIToolbar *toolBar;
    BOOL _textViewFirstFocus;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, strong) UIImage *gottenImage;
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
    //NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    if([textField isEqual:self.messageTextField]) {
        [self performSelector:@selector(sendAction:) withObject:nil afterDelay:0];
    }
    return YES;
}

#pragma mark - Image

- (IBAction)imageButtonAction:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    as.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [as showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self takePhoto];
    } else {
        [self choosePhotos];
    }
}

- (void)takePhoto {
    //NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"There is no camera!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];        
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)choosePhotos {
    //NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    if(image) {
        [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.gottenImage = [self resizedImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
                [MBProgressHUD hideHUDForView:picker.view animated:YES];
                [picker dismissViewControllerAnimated:YES completion:nil];
            });
        });
    } else {
        self.gottenImage = nil;
        self.imageView.image = [UIImage imageNamed:@"placeholder"];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#define kUploadImageMaxSize 1600

- (UIImage*)resizedImage:(UIImage*)originalImage {
    if(!originalImage)
        return nil;
    double factor = (double)originalImage.size.width / (double)originalImage.size.height;
    CGFloat width  = 0;
    CGFloat height = 0;
    if (originalImage.size.height > originalImage.size.width) {
        height = kUploadImageMaxSize;
        width  = kUploadImageMaxSize * factor;
    } else {
        width  = kUploadImageMaxSize;
        height = kUploadImageMaxSize / factor;
    }
    
    UIImage* retImage = originalImage;
    if (MAX(originalImage.size.height, originalImage.size.width) > kUploadImageMaxSize) {
        retImage = [originalImage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationHigh];
    }
    return retImage;
}

#pragma mark - Button Actions

- (IBAction)sendAction:(id)sender
{
    UIImage *image = self.gottenImage;
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
    //NSLog(@"%s,%d manager.responseSerializer.acceptableContentTypes:%@",__FUNCTION__,__LINE__,manager.responseSerializer.acceptableContentTypes);
    NSString *url = @"http://api.gongpengjun.com:90/messages/comboupload.php";
    NSDictionary *parameters = @{@"name": username, @"message" : self.messageTextField.text};
    [manager POST:url
       parameters:parameters
constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
    // the data size of jpg is much smaller than png (1200x1600:1.5MB(jpg)/3.5MB(png))
#if 1
    [formData appendPartWithFileData:UIImageJPEGRepresentation(image,1) name:@"userfile" fileName:@"image.jpg" mimeType:@"image/jpeg"];
#else
    [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"userfile" fileName:@"image.png" mimeType:@"image/png"];
#endif
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //NSLog(@"%s,%d JSON: %@",__FUNCTION__,__LINE__,responseObject);
              // Configure for text only and offset down
              if([responseObject objectForKey:@"error"]) {
                  [hud hide:NO];
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:responseObject[@"error"][@"prompt"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                  if([responseObject[@"error"][@"code"] integerValue] == 40001)
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
              NSLog(@"%s,%d %@",__FUNCTION__,__LINE__,error);
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
    self.gottenImage = nil;
    self.imageView.image = [UIImage imageNamed:@"placeholder"];
}

- (void) leaveKeyboardMode
{
	[self.view endEditing:YES];
}

@end
