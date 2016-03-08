//
//  STDropDownTableViewCell.h
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDropDownTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textFieldTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *dropDownTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *dropDownTextField;

@property (weak, nonatomic) IBOutlet UIButton *firstRadioButton;
@property (weak, nonatomic) IBOutlet UILabel *firstradioButtonTitlrLabel;
@property (weak, nonatomic) IBOutlet UIButton *secondRadioButton;
@property (weak, nonatomic) IBOutlet UILabel *secondRadioButtonTtitleLabel;

- (IBAction)radioButtonAction:(UIButton *)sender;
@end
