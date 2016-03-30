//
//  STUserProfileViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface Address:NSObject
@property (nonatomic,strong)NSString  *city;
@property (nonatomic,strong)NSString  *country_id;
@property (nonatomic,strong)NSString  *firstname;
@property (nonatomic,strong)NSString  *lastname;
@property (nonatomic,strong)NSString  *postcode;
//@property (nonatomic,strong)NSString  *region_id;
@property (nonatomic,strong)NSString  *region;
@property (nonatomic,strong)NSString  *street;
@property (nonatomic)NSInteger is_default_billing;
@property (nonatomic)NSInteger is_default_shipping;

@end

@interface STUserProfileViewController : STViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *ordersButton;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;

- (IBAction)ordersButtonAction:(UIButton *)sender;
- (IBAction)saveChangesButtonAction:(UIButton *)sender;

@end
