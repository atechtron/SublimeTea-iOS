//
//  STDropDownTableViewCell.h
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STDropDownTableViewCellDeleagte <NSObject>

- (void)dropDownItemDidSelect:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell;
- (void)checkBoxStateDidChanged:(UITableViewCell *)cell senderControl:(id)checkBox;
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath;

@end

@interface STDropDownTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic)NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *textFieldTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *dropDownTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *dropDownTextField;

@property (weak, nonatomic) IBOutlet UIButton *firstRadioButton;
@property (weak, nonatomic) IBOutlet UILabel *firstradioButtonTitlrLabel;
@property (weak, nonatomic) IBOutlet UIButton *secondRadioButton;
@property (weak, nonatomic) IBOutlet UILabel *secondRadioButtonTtitleLabel;

@property (weak, nonatomic) id<STDropDownTableViewCellDeleagte> delegate;

- (IBAction)checkBoxButtonAction:(UIButton *)sender;
@end
