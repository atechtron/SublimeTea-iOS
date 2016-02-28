//
//  STSignUpViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STSignUpViewController.h"
#import "STUtility.h"
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
    }else {
//        self.errorLabel.text = @"UserName and Password is required.";
        self.errorLabel.hidden = NO;
    }
    if (![passwordStr isEqualToString:confirmPasswordStr]) {
        self.errorLabel.text = @"Password and confirm password should match.";
        self.errorLabel.hidden = NO;
    }
    return status;
}
- (IBAction)submitButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        // call webservice
    }
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
