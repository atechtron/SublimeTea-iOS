//
//  STLoginViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STLoginViewController.h"
#import "STUtility.h"
#import "STHttpRequest.h"
#import "NSString+NSHash.h"

@interface STLoginViewController ()<UITextFieldDelegate>

@end

@implementation STLoginViewController

- (void)viewDidLoad {
    self.menuButtonHidden = YES;
    self.hideRightBarItems = YES;
    //    self.hideLeftBarItems = NO;
    [super viewDidLoad];
    
    self.useraNameTextField.delegate = self;
    self.passwordTextfield.delegate = self;
    self.useraNameTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextfield.returnKeyType = UIReturnKeyDone;
    self.passwordTextfield.enablesReturnKeyAutomatically = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
    
    //    UITapGestureRecognizer *checkBoxTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkBoxStateDidChanged:)];
    //    [self.checkBoxTextLabel.superview addGestureRecognizer:checkBoxTap];
    
    [self updateUI];
}

- (void)updateUI {
    self.useraNameTextField.borderStyle = UITextBorderStyleNone;
    self.useraNameTextField.layer.borderWidth = 1;
    self.useraNameTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.useraNameTextField.layer.cornerRadius = 2;
    
    self.passwordTextfield.borderStyle = UITextBorderStyleNone;
    self.passwordTextfield.layer.borderWidth = 1;
    self.passwordTextfield.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.passwordTextfield.layer.cornerRadius = 2;
    
    UIImage *unselectedCheckBox = [UIImage imageNamed:@"chekboxUnselected"];
    [self.checkBoxButton setImage:unselectedCheckBox forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.errorLabel.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter 	defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
//    return [self validateInputs];
//}

- (IBAction)checkBoxStateDidChanged:(UIButton *)checkBox {
    
    UIImage *unselectedCheckBox = [UIImage imageNamed:@"chekboxUnselected"];
    UIImage *selectedCheckBox = [UIImage imageNamed:@"checkboxSelected"];
    
    if ([self.checkBoxButton.imageView.image isEqual:unselectedCheckBox]) {
        [self.checkBoxButton setImage:selectedCheckBox forState:UIControlStateNormal];
        self.passwordTextfield.secureTextEntry = NO;
    }
    else {
        [self.checkBoxButton setImage:unselectedCheckBox forState:UIControlStateNormal];
        self.passwordTextfield.secureTextEntry = YES;
    }
}

- (void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}
- (IBAction)forgorPasswordButtonAction:(UIButton *)sender {
}

- (IBAction)submitButtonAction:(UIButton *)sender {
    //     [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
    [self.view endEditing:YES];
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        // call webservice
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sessionId = [defaults objectForKey:kUSerSession_Key];
        [STUtility startActivityIndicatorOnView:nil withText:@"Brewing"];
        if (sessionId.length) {
            [self userLogInWIthSessionId:sessionId];
        }
        else {
            [AppDelegate startSession];
            [self submitButtonAction:self.submitButton];
        }
        
        //        [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
    }
}

- (BOOL)validateInputs {
    BOOL status = NO;
    NSString *userNameStr = [self.useraNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *PasswordStr = [self.passwordTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (userNameStr.length == 0) {
        self.errorLabel.text = @"UserName is required.";
        self.errorLabel.hidden = NO;
    }
    else if (PasswordStr.length == 0)
    {
        self.errorLabel.text = @"Password is required.";
        self.errorLabel.hidden = NO;
    }
    
    if (userNameStr.length > 0 && PasswordStr.length > 0) {
        status = YES;
        self.errorLabel.hidden = YES;
    }else {
        self.errorLabel.text = @"UserName and Password is required.";
        self.errorLabel.hidden = NO;
    }
    
    return status;
}

-(void)userLogInWIthSessionId:(id)Obj {
    if ([self validateInputs]){
        
        NSString *sessionId = Obj;
        if (![Obj isKindOfClass:[NSString class]]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *_sessionId = [defaults objectForKey:kUSerSession_Key];
            sessionId = _sessionId;
        }
        
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
                                          [self parseResponseWithDict:xmlDic];
                                          
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
}
- (void)parseResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSArray *userList = responseDict[@"SOAP-ENV:Body"][@"ns1:customerCustomerListResponse"][@"storeView"][@"item"];
        if (userList.count) {
            NSString *userNameStr = [self.useraNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"email.__text LIKE %@",userNameStr];
            NSArray *filteredUsersArr = [userList filteredArrayUsingPredicate:filterPredicate];
            if (filteredUsersArr.count) {
                NSDictionary *userInfoDict = filteredUsersArr[0];
                
                NSDictionary *methodIs = [userInfoDict objectForKey:@"password_hash"];
                NSString *passWordHashStr = [methodIs valueForKey:@"__text"];
                NSArray* pwdSplitValue = [passWordHashStr componentsSeparatedByString: @":"];
                if (pwdSplitValue.count == 2) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:userInfoDict forKey:kUserInfo_Key];
                    dbLog(@"User Details: %@",[defaults objectForKey:kUserInfo_Key]);
                    
                    NSString *passwordStr = [self.passwordTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSString *hashSalt = [pwdSplitValue objectAtIndex:1];
                    NSString *appendedString =[NSString stringWithFormat:@"%@%@",hashSalt,passwordStr];
                    NSString *secureHash= [appendedString MD5];
                    dbLog(@"Secure Password hash: %@\n User Password hash: %@",passWordHashStr,secureHash);
                    if ([secureHash isEqualToString:pwdSplitValue[0]]) { // Valid User Credentials
                        dbLog(@"User Login Sucess.");
                        [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
                    }
                    else {
                        [STUtility stopActivityIndicatorFromView:nil];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                                        message:@"Invalid credentials entered."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles: nil];
                        [alert show];
                    }
                }
            }
            else { // Login Failed
                [STUtility stopActivityIndicatorFromView:nil];
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:@"Login Failed, Please try after some time."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
            }
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
-(void)loadDashboard {
    [self performSegueWithIdentifier:@"dashBoardFromSigInSegue" sender:self
     ];
}
#pragma mark-
#pragma UITextFieldDelegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //    if (textField == self.passwordTextfield) {
    [self.contentScrollView scrollRectToVisible:self.forgotPassword.bounds animated:YES];
    //    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.useraNameTextField) {
        [textField resignFirstResponder];
        [self.passwordTextfield becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self submitButtonAction:self.submitButton];
        //        [self.useraNameTextField becomeFirstResponder];
    }
    return NO;
}
@end
