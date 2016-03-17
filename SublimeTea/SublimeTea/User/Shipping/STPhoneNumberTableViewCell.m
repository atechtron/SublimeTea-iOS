//
//  STPhoneNumberTableViewCell.m
//  SublimeTea
//
//  Created by Arpit on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STPhoneNumberTableViewCell.h"
#import "STMacros.h"

@implementation STPhoneNumberTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    
    _containerView.layer.borderWidth = 1;
    _containerView.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _containerView.layer.cornerRadius = 2;
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    rightBorder.borderWidth = 1;
    rightBorder.frame = CGRectMake(CGRectGetWidth(_phoneCountryCodeTextBox.frame)-1, -1, 1, CGRectGetHeight(_phoneCountryCodeTextBox.frame));
    
    [_phoneCountryCodeTextBox.layer addSublayer:rightBorder];
    _phoneCountryCodeTextBox.clipsToBounds = NO;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
