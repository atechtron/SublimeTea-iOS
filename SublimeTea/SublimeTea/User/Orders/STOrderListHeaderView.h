//
//  STOrderListHeaderView.h
//  SublimeTea
//
//  Created by Arpit Mishra on 28/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STOrderListHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *_backgroundView;
@end
