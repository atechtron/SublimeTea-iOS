//
//  STCartTableViewCell.h
//  SublimeTea
//
//  Created by Arpit Mishra on 27/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STCartTableViewCellDelegate <NSObject>

- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture;
- (void)itemDidRemoveFromCart:(UIButton *)sender;

@end

@interface STCartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *porudctImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;
@property (weak, nonatomic) IBOutlet UITextField *qtyTextbox;
@property (weak, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;
@property (weak, nonatomic) IBOutlet UILabel *buyLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;

@property (weak, nonatomic) id <STCartTableViewCellDelegate> delegate;

- (IBAction)removeBtnAction:(UIButton *)sender;
@end
