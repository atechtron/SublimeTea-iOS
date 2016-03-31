//
//  STCartProdTotalTableViewCell.m
//  SublimeTea
//
//  Created by sanket likhe on 29/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCartProdTotalTableViewCell.h"
#import "STMacros.h"
#import "STUtility.h"

@implementation STCartProdTotalTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)drawRect:(CGRect)rect {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownAction:)];
    [self.prodQuantityTextField.superview addGestureRecognizer:tap];
    
    self.prodQuantityTextField.borderStyle = UITextBorderStyleNone;
    self.prodQuantityTextField.layer.borderWidth = 0.5f;
    self.prodQuantityTextField.layer.borderColor = [STUtility getSublimeHeadingBGColor].CGColor;
    self.prodQuantityTextField.layer.cornerRadius = 2;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 5)];
    imgView.image = [UIImage imageNamed:@"down-arrow"];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, CGRectGetHeight(self.prodQuantityTextField.frame))];
    [paddingView addSubview:imgView];
    self.prodQuantityTextField.rightView = paddingView;
    self.prodQuantityTextField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)dropDownAction:(UITapGestureRecognizer *)tapGestureRecongnizer {
    if ([self.delegate respondsToSelector:@selector(droDownAction:tapGesture:)]) {
        [self.delegate droDownAction:self.prodQuantityTextField tapGesture:tapGestureRecongnizer];
    }
}

- (IBAction)removeBtnAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(itemDidRemoveFromCart:)]) {
        [self.delegate itemDidRemoveFromCart:sender];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
