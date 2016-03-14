//
//  STCartTableViewCell.m
//  SublimeTea
//
//  Created by Arpit Mishra on 27/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCartTableViewCell.h"
#import "STMacros.h"

@implementation STCartTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownAction:onView:)];
    [_qtyTextbox.superview addGestureRecognizer:tap];
    
    _qtyTextbox.borderStyle = UITextBorderStyleNone;
    _qtyTextbox.layer.borderWidth = 0.5f;
    _qtyTextbox.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _qtyTextbox.layer.cornerRadius = 2;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 5)];
    imgView.image = [UIImage imageNamed:@"down-arrow"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, CGRectGetHeight(_qtyTextbox.frame))];
    [paddingView addSubview:imgView];
    _qtyTextbox.rightView = paddingView;
    _qtyTextbox.rightViewMode = UITextFieldViewModeAlways;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)removeBtnAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(itemDidRemoveFromCart:)]) {
        [self.delegate itemDidRemoveFromCart:sender];
    }
}
- (void)dropDownAction:(UITapGestureRecognizer *)tapGestureRecongnizer onView:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(droDownAction:tapGesture:)]) {
        [self.delegate droDownAction:self.qtyTextbox tapGesture:tapGestureRecongnizer];
    }
}
@end
