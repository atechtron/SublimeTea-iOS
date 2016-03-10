//
//  STDropDownTableViewCell.m
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STDropDownTableViewCell.h"
#import "STMacros.h"

@implementation STDropDownTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownAction:onView:)];
    [self.dropDownTextField.superview addGestureRecognizer:tap];
    
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.layer.borderWidth = 1;
    _textField.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _textField.layer.cornerRadius = 2;
    
    _dropDownTextField.borderStyle = UITextBorderStyleNone;
    _dropDownTextField.layer.borderWidth = 1;
    _dropDownTextField.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _dropDownTextField.layer.cornerRadius = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dropDownAction:(UITapGestureRecognizer *)tapGestureRecongnizer onView:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(droDownAction:tapGesture:)]) {
        [self.delegate droDownAction:self.dropDownTextField tapGesture:tapGestureRecongnizer];
    }
}
- (IBAction)checkBoxButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(checkBoxStateDidChanged:)]) {
        [self.delegate checkBoxStateDidChanged:self];
    }
}
@end
