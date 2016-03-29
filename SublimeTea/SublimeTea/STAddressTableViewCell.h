//
//  STAddressTableViewCell.h
//  SublimeTea
//
//  Created by Apple on 29/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STAddressTableViewCellDelegate <NSObject>

- (void)dropDownItemDidSelect:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell;
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath;

@end

@interface STAddressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressTextViewTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;

@property (weak, nonatomic) IBOutlet UILabel *cityTextFieldTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UILabel *stateTextFieldTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *postalCodeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UILabel *countryTitleLabel;

@property (strong, nonatomic) NSIndexPath* indexPath;
@property (weak, nonatomic) id<STAddressTableViewCellDelegate> delegate;
@end
