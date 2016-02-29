//
//  STOrderConfirmationFooterView.m
//  SublimeTea
//
//  Created by Arpit Mishra on 28/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STOrderConfirmationFooterView.h"

@implementation STOrderConfirmationFooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)ordersButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(orderButtonClicked)]) {
        [self.delegate orderButtonClicked];
    }
}

- (IBAction)continueShoppingButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(continueShoppingButtonClicked)]) {
        [self.delegate continueShoppingButtonClicked];
    }
}
@end
