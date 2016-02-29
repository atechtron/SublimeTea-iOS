//
//  STUserProfileViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STUserProfileViewController : STViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *ordersButton;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
- (IBAction)ordersButtonAction:(UIButton *)sender;
- (IBAction)saveChangesButtonAction:(UIButton *)sender;

@end
