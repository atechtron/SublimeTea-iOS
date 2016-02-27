//
//  STOrderListViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STOrderListViewController : STViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;

- (IBAction)continueShoppingButtonAction:(UIButton *)sender;
@end
