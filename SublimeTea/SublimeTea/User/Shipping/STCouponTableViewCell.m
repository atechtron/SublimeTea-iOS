//
//  STCouponTableViewCell.m
//  SublimeTea
//
//  Created by Apple on 08/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCouponTableViewCell.h"
#import "STMacros.h"

@implementation STCouponTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
    _couponTextField.borderStyle = UITextBorderStyleNone;
    _couponTextField.layer.borderWidth = 1;
    _couponTextField.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _couponTextField.layer.cornerRadius = 2;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)applyCouponButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(applyCouponAction:onCell:)]) {
        [self.delegate applyCouponAction:sender onCell:self];
    }
}
@end
