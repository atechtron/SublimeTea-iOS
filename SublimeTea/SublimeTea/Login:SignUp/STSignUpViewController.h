//
//  STSignUpViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STSignUpViewController : STViewController
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)submitButtonAction:(UIButton *)sender;
@end
