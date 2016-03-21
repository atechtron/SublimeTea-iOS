//
//  STLoginViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STLoginViewController : STViewController
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UILabel *userNameHeadingLabel;
@property (weak, nonatomic) IBOutlet UITextField *useraNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordHeaderLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassword;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *checkBoxTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;


- (IBAction)forgorPasswordButtonAction:(UIButton *)sender;
- (IBAction)submitButtonAction:(UIButton *)sender;
- (IBAction)checkBoxStateDidChanged:(UIButton *)checkBox;
@end
