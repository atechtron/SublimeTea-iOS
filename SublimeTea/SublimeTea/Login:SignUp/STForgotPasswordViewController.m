//
//  STForgotPasswordViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STForgotPasswordViewController.h"
#import "STUtility.h"

@interface STForgotPasswordViewController ()

@end

@implementation STForgotPasswordViewController

- (void)viewDidLoad {
//    self.menuButtonHidden = YES;
//    self.hideRightBarItems = YES;
    
    [super viewDidLoad];
    
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.enablesReturnKeyAutomatically = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
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
    [self.view endEditing:YES];
}
- (IBAction)resetButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        // call webservice
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (BOOL)validateInputs {
    BOOL status = NO;
    NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (emailStr.length > 0) {
        status = YES;
        self.errorLabel.hidden = YES;
    }else {
        //        self.errorLabel.text = @"UserName and Password is required.";
        self.errorLabel.hidden = NO;
    }
    return status;
}

#pragma mark -
#pragma UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resetButtonAction:self.resetButton];
    
    return NO;
}

@end
