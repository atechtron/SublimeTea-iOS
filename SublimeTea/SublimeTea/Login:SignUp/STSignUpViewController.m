//
//  STSignUpViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STSignUpViewController.h"
#import "STUtility.h"
#import "STHttpRequest.h"

@interface STSignUpViewController ()<UITextFieldDelegate>

@end

@implementation STSignUpViewController

- (void)viewDidLoad {
    self.menuButtonHidden = YES;
    self.hideRightBarItems = YES;
    //    self.hideLeftBarItems = NO;
    
    [super viewDidLoad];
    self.mobileNumberTextField.enablesReturnKeyAutomatically = YES;
    self.mobileNumberTextField.returnKeyType = UIReturnKeyDone;
    self.emailAddressTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.confirmPasswordTextField.returnKeyType = UIReturnKeyNext;
    self.mobileNumberTextField.keyboardType = UIKeyboardTypePhonePad;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
    
    [self updateUI];
}
- (void)updateUI {
    
    self.emailAddressTextField.borderStyle = UITextBorderStyleNone;
    self.emailAddressTextField.layer.borderWidth = 1;
    self.emailAddressTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.emailAddressTextField.layer.cornerRadius = 2;
    
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.layer.borderWidth = 1;
    self.passwordTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.passwordTextField.layer.cornerRadius = 2;
    
    self.confirmPasswordTextField.borderStyle = UITextBorderStyleNone;
    self.confirmPasswordTextField.layer.borderWidth = 1;
    self.confirmPasswordTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.confirmPasswordTextField.layer.cornerRadius = 2;
    
    self.mobileNumberTextField.borderStyle = UITextBorderStyleNone;
    self.mobileNumberTextField.layer.borderWidth = 1;
    self.mobileNumberTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.mobileNumberTextField.layer.cornerRadius = 2;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)viewDidTapped:(id)sender {
    self.contentScrollView.contentOffset = CGPointMake(0, 0);
    [self.view endEditing:YES];
}
- (BOOL)validateInputs {
    BOOL status = NO;
    NSString *emailStr = [self.emailAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordStr = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *confirmPasswordStr = [self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mobNumStr = [self.mobileNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (emailStr.length > 0 && passwordStr.length >= 6 && confirmPasswordStr.length > 0 && mobNumStr.length > 0) {
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if ([emailTest evaluateWithObject:emailStr] == NO) {
            [self showAlertWithTitle:@"Message" msg:@"Valid Email required!"];
            status = NO;
            self.errorLabel.hidden = NO;
        }
        else {
            status = YES;
            self.errorLabel.hidden = YES;
        }
    }
    else {
        //        self.errorLabel.text = @"UserName and Password is required.";
        if (passwordStr.length <= 6) {
            [self showAlertWithTitle:@"Message" msg:@"Password should be more than 6 characters."];
        }
        self.errorLabel.hidden = NO;
    }
    if (![passwordStr isEqualToString:confirmPasswordStr]) {
        self.errorLabel.text = @"Please enter valid data.";
        self.errorLabel.hidden = NO;
        status = NO;
    }
    
    return status;
}
- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
- (IBAction)submitButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
        [self userRegistration];
        
    }
}
- (void)userRegistration {
    
    NSString *emailStr = [self.emailAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordStr = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //        NSString *confirmPasswordStr = [self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //        NSString *mobNumStr = [self.mobileNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *requestBody = [STConstants signUpRequestBodyWIthEmail:emailStr
                                                        andPassword:passwordStr];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      dbLog(@"%@",response);
                                  }successBlock:^(NSData *responseData){
                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                      dbLog(@"%@",xmlDic);
                                      if(!xmlDic[@"SOAP-ENV:Body"][@"SOAP-ENV:Fault"])
                                      {
                                          [self getUserList];
                                      }
                                      else {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"SignUp Failed, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                      }
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      dbLog(@"SublimeTea-STSignUpViewController-submitButtonAction:- %@",error);
                                  }];
    
    [httpRequest start];
}
-(void)getUserList {
    
    NSString *requestBody = [STConstants customerListReuestBody];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                      dbLog(@"%@",xmlDic);
                                      [self parseUserListResponseWithDict:xmlDic];
                                      
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      dbLog(@"SublimeTea-STSignUpViewController-userLogIn:- %@",error);
                                  }];
    
    [httpRequest start];
}
- (void)parseUserListResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSArray *userList = responseDict[@"SOAP-ENV:Body"][@"ns1:customerCustomerListResponse"][@"storeView"][@"item"];
        if (userList.count) {
            NSString *userNameStr = [self.emailAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"email.__text LIKE %@",userNameStr];
            NSArray *filteredUsersArr = [userList filteredArrayUsingPredicate:filterPredicate];
            if (filteredUsersArr.count) {
                NSDictionary *userInfoDict = filteredUsersArr[0];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:userInfoDict forKey:kUserInfo_Key];
                dbLog(@"User Details: %@",[defaults objectForKey:kUserInfo_Key]);
                [STUtility stopActivityIndicatorFromView:nil];
                
                [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
            }
            else { // Login Failed
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:@"SignUp Failed, Please try after some time."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
            }
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
-(void)loadDashboard {
    [self performSegueWithIdentifier:@"dashBoardFromSignUpSegue" sender:self
     ];
}
#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow: (NSNotification*) aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float kbHeight = kbSize.height < kbSize.width ? kbSize.height : kbSize.width;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
}

-(void)keyboardWillHide: (NSNotification*) aNotification {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if (![sender isEqual:self.emailAddressTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailAddressTextField]) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordTextField]) {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.confirmPasswordTextField]){
        [self.mobileNumberTextField becomeFirstResponder];
    }
    else {
        [self submitButtonAction:self.submitButton];
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _mobileNumberTextField) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 10;
    }
    return YES;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}



@end
