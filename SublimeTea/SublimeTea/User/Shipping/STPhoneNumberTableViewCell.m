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
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end