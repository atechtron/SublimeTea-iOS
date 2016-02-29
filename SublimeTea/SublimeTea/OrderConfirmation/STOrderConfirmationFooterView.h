//
//  STOrderConfirmationFooterView.h
//  SublimeTea
//
//  Created by Arpit Mishra on 28/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STOrderConfirmationFooterViewDelegat <NSObject>
-(void)orderButtonClicked;
-(void)continueShoppingButtonClicked;
@end

@interface STOrderConfirmationFooterView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIButton *ordersButton;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingBUtton;
@property (weak, nonatomic) id<STOrderConfirmationFooterViewDelegat> delegate;

- (IBAction)ordersButtonAction:(UIButton *)sender;
- (IBAction)continueShoppingButtonAction:(UIButton *)sender;
@end
