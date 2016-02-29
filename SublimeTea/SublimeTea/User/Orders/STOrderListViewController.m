//
//  STOrderListViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STOrderListViewController.h"
#import "STOderListTableViewCell.h"
#import "STOrderListHeaderView.h"
#import "STDashboardViewController.h"
#import "STUtility.h"

@interface STOrderListViewController ()<UITabBarDelegate, UITableViewDataSource>

@end

@implementation STOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark-
#pragma UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"orderListCell";
    STOderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    cell.titleLabel.text = @"GREEN LONG DING";
    cell.descriptionLabel.text = @"This is a pure Green Tea. Fresh tender tea leaves are carefully processed to minimize oxidation and rolled using a very special process.";
    cell.priceLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%d",200]];
    cell.prodImageView.image = [UIImage imageNamed:@"teaCup.jpeg"];
    cell.statusLabel.text = @"Status: Delivered";
    cell.qtyLabel.text = @"QUANTITY: 2 (ITEMS)";

    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    footerView.titleLabel.text = @"Orders";
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 62;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IBAction)continueShoppingButtonAction:(UIButton *)sender {
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    if(viewControllerArray.count > 2) {
        [self.navigationController popToViewController:viewControllerArray[2] animated:YES];
    }
    else {
        STDashboardViewController *dashBoard = [self.storyboard instantiateViewControllerWithIdentifier:@"STDashboardViewController"];
        [self.navigationController pushViewController:dashBoard animated:YES];
    }
}
@end
