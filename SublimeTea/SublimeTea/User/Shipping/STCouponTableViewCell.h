//
//  STCouponTableViewCell.h
//  SublimeTea
//
//  Created by Apple on 08/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STCouponTableViewCellDelegate <NSObject>
- (void)applyCouponAction:(UIButton *)sender onCell:(UITableViewCell *)cell;
@end

@interface STCouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *couponTextField;
@property (weak, nonatomic) IBOutlet UIButton *applyCouponButton;
@property (weak,nonatomic) id<STCouponTableViewCellDelegate> delegate;

- (IBAction)applyCouponButtonAction:(UIButton *)sender;
@end
