//
//  STPhoneNumberTableViewCell.h
//  SublimeTea
//
//  Created by Arpit on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STPhoneNumberTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *phoneCountryCodeTextBox;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@end
