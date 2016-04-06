//
//  STDropDownTableViewCell.m
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STDropDownTableViewCell.h"
#import "STMacros.h"
#import "STUtility.h"

@implementation STDropDownTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownAction:)];
//    tap.numberOfTapsRequired = 1;
//    [self.dropDownTextField.superview addGestureRecognizer:tap];
//    
//    UITapGestureRecognizer *CheckboxLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkBoxButtonAction:)];
//    [self.firstradioButtonTitlrLabel.superview addGestureRecognizer:CheckboxLabelTap];
//    [self.secondRadioButtonTtitleLabel.superview addGestureRecognizer:CheckboxLabelTap];
    
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.layer.borderWidth = 1;
    _textField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _textField.layer.cornerRadius = 2;
    
    [_dropDownTextField setUserInteractionEnabled:YES];
    _dropDownTextField.borderStyle = UITextBorderStyleNone;
    _dropDownTextField.layer.borderWidth = 1;
    _dropDownTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _dropDownTextField.layer.cornerRadius = 2;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 5)];
    imgView.image = [UIImage imageNamed:@"down-arrow"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, CGRectGetHeight(_dropDownTextField.frame))];
    [paddingView addSubview:imgView];
    _dropDownTextField.rightView = paddingView;
    _dropDownTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dropDownAction:(UITapGestureRecognizer *)tapGestureRecongnizer {
    if ([self.delegate respondsToSelector:@selector(droDownAction:tapGesture:indexPath:)]) {
        [self.delegate droDownAction:self.dropDownTextField tapGesture:tapGestureRecongnizer indexPath:self.indexPath];
    }
}
- (IBAction)checkBoxButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(checkBoxStateDidChanged:senderControl:)]) {
        [self.delegate checkBoxStateDidChanged:self senderControl:sender];
    }
}
@end
