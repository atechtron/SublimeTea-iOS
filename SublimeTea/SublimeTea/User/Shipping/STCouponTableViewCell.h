//
//  STCouponTableViewCell.h
//  SublimeTea
//
//  Created by Apple on 08/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *couponTextField;
@property (weak, nonatomic) IBOutlet UIButton *applyCouponButton;

- (IBAction)applyCouponButtonAction:(UIButton *)sender;
@end
