//
//  STDropDownTableViewCell.m
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STDropDownTableViewCell.h"

@implementation STDropDownTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownAction:)];
    [self.dropDownTextField addGestureRecognizer:tap];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dropDownAction:(id)sender {

}
- (IBAction)radioButtonAction:(UIButton *)sender {
}
@end
