//
//  STPrfileTableViewCell.m
//  SublimeTea
//
//  Created by Arpit Mishra on 29/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STPrfileTableViewCell.h"
#import "STMacros.h"
NSInteger const kAddAddressBtnCellTag = 109893;
NSInteger const kChangePwdBtnCellTag = 187930;

@implementation STPrfileTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
    _profileTextField.layer.borderWidth = 1;
    _profileTextField.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _profileTextField.layer.cornerRadius = 2;
    
    _profileTextView.layer.borderWidth = 1;
    _profileTextView.layer.borderColor = UIColorFromRGB(168, 123, 69, 1).CGColor;
    _profileTextView.layer.cornerRadius = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)profileButtonAction:(UIButton *)sender {
    if (self.tag == kAddAddressBtnCellTag && [self.delegate respondsToSelector:@selector(addNewAddressesAtIndexPath:)]) {
        [self.delegate addNewAddressesAtIndexPath:self.currentIndexPath];
    }
    else {
        [self.delegate editPasswordAtIndexPath:self.currentIndexPath];
    }
}
@end
