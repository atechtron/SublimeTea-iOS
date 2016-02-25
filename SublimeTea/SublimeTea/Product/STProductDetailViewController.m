//
//  STProductDetailViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STProductDetailViewController.h"
#import "STProductInfoTableViewCell.h"
#import "STProductInfo2TableViewCell.h"
#import "STProductDescriptionTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface STProductDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation STProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.tableView registerNib:[UINib nibWithNibName:@"STProductInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"productInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STProductInfo2TableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"productAddToCartCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STProductDescriptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"productDescriptioncell"];
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
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
        {
            static NSString *cellidentifier = @"productInfoCell";
            STProductInfoTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
            _cell.titleLabel.text = @"Green Long Dong Tea";
            _cell.numLabel.text = @"3160";
            _cell.statusLabel.text = @"in stock";
            _cell.extraLabel.text = @"Put your pincode here";
            cell = _cell;
            break;
        }
        case 1:
        {
            static NSString *cellidentifier = @"productAddToCartCell";
            STProductInfo2TableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
            NSString *desc = @"This is a pure Green Tea. Fresh tender tea leaves are carefully processed to minimize oxidation and rolled using a very special process.";
            NSString *SKU = @"Tea007";
            NSString *categ = @"Pure Green Tea, Tea Bags";
            NSString *descriptionStr = [NSString stringWithFormat:@"%@\n%@\n%@",desc,SKU,categ];
            _cell.descriptionLabel.text = descriptionStr;
            _cell.qtyLabel.text = @"290";
            _cell.qtyLabel.backgroundColor = [UIColor orangeColor];
            _cell.qtyLabel.layer.borderWidth = 1;
            _cell.qtyLabel.layer.cornerRadius = _cell.amountLabel.frame.size.height/2;
            _cell.qtyLabel.clipsToBounds = YES;
            _cell.qtyLabel.layer.borderColor = [UIColor clearColor].CGColor;
            _cell.qtyLabel.text = [NSString stringWithFormat:@"Qty\n%d",2];
            cell = _cell;

            break;
        }
        case 2:
        {
            static NSString *cellidentifier = @"productDescriptioncell";
            STProductDescriptionTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
            _cell.topBorderImageView = nil;
            _cell.descriptionLabel.text = @"This is a pure Green Tea. Fresh tender tea leaves are carefully processed to minimize oxidation and rolled using a very special process.";
            cell = _cell;

            break;
        }
        default:
            cell = [[UITableViewCell alloc] init];
            break;
    }
    return cell;
}

@end
