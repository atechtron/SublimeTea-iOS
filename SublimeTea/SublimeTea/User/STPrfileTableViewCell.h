//
//  STPrfileTableViewCell.h
//  SublimeTea
//
//  Created by Arpit Mishra on 29/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const kAddAddressBtnCellTag;
extern NSInteger const kChangePwdBtnCellTag;

@protocol STProfileTableViewCellDelegate <NSObject>

- (void) addNewAddressesAtIndexPath:(NSIndexPath *)indexPath;
- (void) editPasswordAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface STPrfileTableViewCell : UITableViewCell

@property (strong,nonatomic)NSIndexPath *currentIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *profileTextFieldTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *profileTextField;

@property (weak, nonatomic) IBOutlet UILabel *profileTextViewTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *profileTextView;

@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (weak, nonatomic) id<STProfileTableViewCellDelegate> delegate;

- (IBAction)profileButtonAction:(UIButton *)sender;
@end
