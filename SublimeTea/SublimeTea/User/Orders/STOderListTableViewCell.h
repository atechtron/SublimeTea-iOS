//
//  STOderListTableViewCell.h
//  SublimeTea
//
//  Created by Arpit Mishra on 28/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STOderListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *prodImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
