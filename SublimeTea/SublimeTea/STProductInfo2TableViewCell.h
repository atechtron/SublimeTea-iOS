//
//  STProductInfo2TableViewCell.h
//  SublimeTea
//
//  Created by Arpit Mishra on 26/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STProductInfo2TableViewCellDelegate <NSObject>
- (void)addToCartClicked:(NSInteger)index;
@end

@interface STProductInfo2TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *topBorderImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *qtyContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *amountBorderImageView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *upArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *downArrowButton;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;
@property (weak, nonatomic) id<STProductInfo2TableViewCellDelegate> delegate;

- (IBAction)addToCartAction:(UIButton *)sender;
- (IBAction)upArrowButtonAction:(UIButton *)sender;
- (IBAction)downArrowButtonAction:(UIButton *)sender;
@end
