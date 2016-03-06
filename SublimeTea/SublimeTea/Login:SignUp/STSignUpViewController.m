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
    
    [super viewDidLoad];
    self.mobileNumberTextField.enablesReturnKeyAutomatically = YES;
    self.mobileNumberTextField.returnKeyType = UIReturnKeyDone;
    self.emailAddressTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.confirmPasswordTextField.returnKeyType = UIReturnKeyNext;
    self.mobileNumberTextField.keyboardType = UIKeyboardTypePhonePad;
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
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
    self.contentScrollView.contentOffset = CGPointMake(0, self.errorLabel.frame.origin.y);
    [self.view endEditing:YES];
}
- (BOOL)validateInputs {
    BOOL status = NO;
    NSString *emailStr = [self.emailAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordStr = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *confirmPasswordStr = [self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mobNumStr = [self.mobileNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (emailStr.length > 0 && passwordStr.length > 0 && confirmPasswordStr.length > 0 && mobNumStr.length > 0) {
        status = YES;
        self.errorLabel.hidden = YES;
    }
    else {
//        self.errorLabel.text = @"UserName and Password is required.";
        self.errorLabel.hidden = NO;
    }
    if (![passwordStr isEqualToString:confirmPasswordStr]) {
        self.errorLabel.text = @"Please enter valid data.";
        self.errorLabel.hidden = NO;
        status = NO;
    }
    return status;
}
- (IBAction)submitButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        [STUtility startActivityIndicatorOnView:nil withText:@"SigningIn, Please wait.."];
        [self startUserSession];
        
    }
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
                                                  [self userRegistration];
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
- (void)userRegistration {
    
    NSString *emailStr = [self.emailAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordStr = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //        NSString *confirmPasswordStr = [self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //        NSString *mobNumStr = [self.mobileNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId = [defaults objectForKey:kUSerSession_Key];
    
    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:customerCustomerCreate soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                             "<customerData xsi:type=\"urn:customerCustomerEntityToCreate\">"
                             "<email xsi:type=\"xsd:string\">%@</email>"
                             "<password xsi:type=\"xsd:string\">%@</password>"
                             "</customerData>"
                             "</urn:customerCustomerCreate>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",sessionId,emailStr,passwordStr];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                     methodType:@"POST"
                                                                           body:requestBody
                                                            responseHeaderBlock:^(NSURLResponse *response)
                                              {
                                                  NSLog(@"%@",response);
                                              }successBlock:^(NSData *responseData){
                                                  NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                                  NSLog(@"%@",xmlDic);
                                                  if(!xmlDic[@"SOAP-ENV:Body"][@"SOAP-ENV:Fault"])
                                                  {
                                                      [STUtility stopActivityIndicatorFromView:nil];
                                                  
                                                      [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
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
                                                  NSLog(@"SublimeTea-STSignUpViewController-submitButtonAction:- %@",error);
                                              }];
    
    [httpRequest start];
}
-(void)loadDashboard {
    [self performSegueWithIdentifier:@"dashBoardFromSigInSegue" sender:self
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
