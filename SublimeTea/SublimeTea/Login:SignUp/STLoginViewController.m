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

@interface STLoginViewController ()<UITextFieldDelegate>

@end

@implementation STLoginViewController

- (void)viewDidLoad {
    self.menuButtonHidden = YES;
    self.hideRightBarItems = YES;
    [super viewDidLoad];
    
    self.useraNameTextField.delegate = self;
    self.passwordTextfield.delegate = self;
    self.useraNameTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextfield.returnKeyType = UIReturnKeyDone;
    self.passwordTextfield.enablesReturnKeyAutomatically = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
}
- (void)viewWillAppear:(BOOL)animated {
    self.errorLabel.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}
- (IBAction)forgorPasswordButtonAction:(UIButton *)sender {
}

- (IBAction)submitButtonAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        // call webservice
//        [self startUserSession];
        [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
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
- (void)startUserSession {
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *requestBody = @"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
    "<soapenv:Header/>"
    "<soapenv:Body>"
    "<urn:startSession soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"/>"
    "</soapenv:Body>"
    "</soapenv:Envelope>";
    
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                     methodType:@"POST"
                                                                           body:requestBody
                                                            responseHeaderBlock:^(NSURLResponse *response)
                                              {
                                                  
                                              }successBlock:^(NSData *responseData){
                                                  NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                                  NSLog(@"%@",xmlDic);
                                                  NSDictionary *resultDict = xmlDic[@"SOAP-ENV:Body"][@"ns1:startSessionResponse"][@"startSessionReturn"];
                                                  NSString *sessionId = resultDict[@"__text"];
                                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                  [defaults setObject:sessionId forKey:kUSerSession_Key];
                                                  [self userLogIn];
                                              }failureBlock:^(NSError *error) {
                                                  [STUtility stopActivityIndicatorFromView:nil];
                                                  [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                              message:@"Unexpected error has occured, Please try after some time."
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles: nil] show];
                                                  NSLog(@"SublimeTea-STSignUpViewController-startSession:- %@",error);
                                              }];
    
    [httpRequest start];
}

-(void)userLogIn {
    NSString *userNameStr = [self.useraNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *PasswordStr = [self.passwordTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId = [defaults objectForKey:kUSerSession_Key];
    
    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:login soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<username xsi:type=\"xsd:string\">%@</username>"
                             "<apiKey xsi:type=\"xsd:string\">%@</apiKey>"
                             "</urn:login>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",userNameStr,sessionId];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                      NSLog(@"%@",xmlDic);
                                      
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      
                                      [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      NSLog(@"SublimeTea-STSignUpViewController-userLogIn:- %@",error);
                                  }];
    
    [httpRequest start];
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
