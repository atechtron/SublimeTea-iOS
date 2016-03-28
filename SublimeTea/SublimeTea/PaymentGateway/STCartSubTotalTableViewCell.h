//
//  STCartSubTotalTableViewCell.h
//  SublimeTea
//
//  Created by sanket likhe on 29/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCartSubTotalTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *subTotalValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalItemsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *shippingChargesValueLabel;

@end
