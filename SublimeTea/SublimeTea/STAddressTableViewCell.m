//
//  STAddressTableViewCell.m
//  SublimeTea
//
//  Created by Apple on 29/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STAddressTableViewCell.h"
#import "STUtility.h"

@implementation STAddressTableViewCell

- (void)drawRect:(CGRect)rect {
    
    UITapGestureRecognizer *stateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateFieldDropDownAction:)];
    stateTap.numberOfTapsRequired = 1;
    [self.stateTextField.superview addGestureRecognizer:stateTap];
    
    UITapGestureRecognizer *countryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countryFiledDropDownAction:)];
    countryTap.numberOfTapsRequired = 1;
    [self.countryTextField.superview addGestureRecognizer:countryTap];
    

    _addressTextView.layer.borderWidth = 1;
    _addressTextView.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _addressTextView.layer.cornerRadius = 2;
    
    _cityTextField.borderStyle = UITextBorderStyleNone;
    _cityTextField.layer.borderWidth = 1;
    _cityTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _cityTextField.layer.cornerRadius = 2;
    
    _stateTextField.borderStyle = UITextBorderStyleNone;
    _stateTextField.layer.borderWidth = 1;
    _stateTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _stateTextField.layer.cornerRadius = 2;
    
    _postalCodeTextField.borderStyle = UITextBorderStyleNone;
    _postalCodeTextField.layer.borderWidth = 1;
    _postalCodeTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _postalCodeTextField.layer.cornerRadius = 2;
    
    _countryTextField.borderStyle = UITextBorderStyleNone;
    _countryTextField.layer.borderWidth = 1;
    _countryTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    _countryTextField.layer.cornerRadius = 2;
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 5)];
    imgView.image = [UIImage imageNamed:@"down-arrow"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, CGRectGetHeight(_stateTextField.frame))];
    [paddingView addSubview:imgView];
    _stateTextField.rightView = paddingView;
    _stateTextField.rightViewMode = UITextFieldViewModeAlways;
    
    UIImageView *countryImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 5)];
    countryImgView.image = [UIImage imageNamed:@"down-arrow"];
    UIView *countryPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, CGRectGetHeight(_countryTextField.frame))];
    [countryPaddingView addSubview:countryImgView];
    
    _countryTextField.rightView = countryPaddingView;
    _countryTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)stateFieldDropDownAction:(UITapGestureRecognizer *)tapGestureRecongnizer {
    if ([self.delegate respondsToSelector:@selector(droDownAction:tapGesture:indexPath:)]) {
        [self.delegate droDownAction:self.stateTextField tapGesture:tapGestureRecongnizer indexPath:self.indexPath];
    }
}
- (void)countryFiledDropDownAction:(UITapGestureRecognizer *)tapGestureRecongnizer {

        if ([self.delegate respondsToSelector:@selector(droDownAction:tapGesture:indexPath:)]) {
            [self.delegate droDownAction:self.countryTextField tapGesture:tapGestureRecongnizer indexPath:self.indexPath];
        }
}
@end
