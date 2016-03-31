//
//  STCartProdTotalTableViewCell.h
//  SublimeTea
//
//  Created by sanket likhe on 29/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STCartTableViewCellDelegate <NSObject>

- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture;
- (void)itemDidRemoveFromCart:(UIButton *)sender;

@end

@interface STCartProdTotalTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel     *productNameLabel;
@property (nonatomic, weak) IBOutlet UILabel     *mrpValueLabel;
@property (nonatomic, weak) IBOutlet UILabel     *splMrpValueLabel;
@property (nonatomic, weak) IBOutlet UILabel     *savingsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel     *prodTotalValueLabel;
@property (nonatomic, weak) IBOutlet UIButton    *removeProdButton;
@property (nonatomic, weak) IBOutlet UITextField *prodQuantityTextField;

@property (weak, nonatomic) id <STCartTableViewCellDelegate> delegate;

- (IBAction)removeBtnAction:(UIButton *)sender;

@end
