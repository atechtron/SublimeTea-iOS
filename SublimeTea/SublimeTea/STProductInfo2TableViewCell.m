//
//  STProductInfo2TableViewCell.m
//  SublimeTea
//
//  Created by Arpit Mishra on 26/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STProductInfo2TableViewCell.h"

@implementation STProductInfo2TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addToCartAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addToCartClicked:)]) {
        [self.delegate addToCartClicked:self.addToCartButton.tag];
    }
}

- (IBAction)upArrowButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(qtyDiddecremented:)]) {
        [self.delegate qtyDidIncremented:self];
    }
}

- (IBAction)downArrowButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(qtyDidIncremented:)]) {
        [self.delegate qtyDiddecremented:self];
    }
}
@end
