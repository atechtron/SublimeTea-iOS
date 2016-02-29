//
//  STLoginViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STLoginViewController.h"
#import "STUtility.h"

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
