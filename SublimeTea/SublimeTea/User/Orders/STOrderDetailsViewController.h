//
//  STOrderDetailsViewController.h
//  SublimeTea
//
//  Created by Apple on 28/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STOrderDetailsViewController : STViewController

@property (strong, nonatomic) NSDictionary *selectedOrderDict;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;

- (IBAction)continueShoppingButtonAction:(UIButton *)sender;
@end
