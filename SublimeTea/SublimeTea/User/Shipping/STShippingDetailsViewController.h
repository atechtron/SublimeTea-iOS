//
//  STShippingDetailsViewController.h
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STShippingDetailsViewController : STViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *paymentBtn;
@property (nonatomic)BOOL isBillingAddressScreen;

- (IBAction)paymentButtonAction:(UIButton *)sender;

@end
