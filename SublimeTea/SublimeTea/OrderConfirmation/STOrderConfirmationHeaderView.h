//
//  STOrderConfirmationHeaderView.h
//  SublimeTea
//
//  Created by Arpit Mishra on 28/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STOrderConfirmationHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIImageView *topBorderImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thankYouLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *orderDescriptionImageView;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@end
