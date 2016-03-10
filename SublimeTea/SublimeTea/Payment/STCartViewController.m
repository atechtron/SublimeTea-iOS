//
//  STCartViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCartViewController.h"
#import "STCartTableViewCell.h"
#import "STCartFooterView.h"
#import "STOrderListHeaderView.h"
#import "STProductCategoriesViewController.h"
#import "STUtility.h"

#import "STCart.h"
#import "STGlobalCacheManager.h"
#import "STShippingDetailsViewController.h"

@interface STCartViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic)NSArray *cartArr;
@end

@implementation STCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STCartFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STCartFooterView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];

    self.cartArr = [[STCart defaultCart] productsDataArr];
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
- (void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark-
#pragma UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cartArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cartCell";
    STCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    Product *prod = self.cartArr[indexPath.row];
    
    NSString *prodId = prod.prodDict[@"product_id"][@"__text"];
    NSString *name = prod.prodDict[@"name"][@"__text"];
    NSString *shortDesc = prod.prodDict[@"short_description"][@"__text"];
    NSString *price = prod.prodDict[@"special_price"][@"__text"];
    NSLog(@"%@",prod.prodDict);
    NSArray *prodImgArr = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
    if (prodImgArr.count) {
        NSDictionary *imgUrlDict = [prodImgArr lastObject];
        NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
        NSLog(@"Image URL %@",imgUrl);
        NSData *imgData = (NSData *)[[STGlobalCacheManager defaultManager] getItemForKey:imgUrl];
        if (imgData) {
            UIImage *prodImg = [UIImage imageWithData:imgData];
            if (prodImg) {
                [UIView transitionWithView:cell.porudctImageView duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                       cell.porudctImageView.image = prodImg;
                                       cell.porudctImageView.contentMode = UIViewContentModeScaleAspectFit;
                                   } completion:nil];
            }
        }
    }
    
    
    cell.titleLabel.text = name;
    cell.descriptionLabel.text = shortDesc;
    cell.priceLabel.text = @"Price";
    cell.priceTitleLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%f",[price floatValue]]];
    cell.qtyTextbox.text = prod.prodQty> 0 ?[NSString stringWithFormat:@"%ld",(long)prod.prodQty]:@"";
    cell.qtyTextbox.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.qtyTextbox.layer.borderWidth = .8;
    [cell.checkboxButton addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    STCartFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STCartFooterView"];
    footerView.topBorderView.backgroundColor = [UIColor blackColor];
    [footerView.continueShoppingButton addTarget:self action:@selector(continueShoppingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView.checkoutButton addTarget:self action:@selector(checkoutButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    return footerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    headerView._backgroundView.backgroundColor = [UIColor whiteColor];
    headerView.titleLabel.text = @"Our Cart";
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 77;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 62;
}
- (void)checkBoxAction:(UIButton *)sender {
    UIImage *checkBoxSelectedImg = [UIImage imageNamed:@"checkboxSelected"];
    UIImage *checkBoxUnSelectedImg = [UIImage imageNamed:@"chekboxUnselected"];
    if ([sender.imageView.image isEqual:checkBoxSelectedImg]) {
        [sender setImage:checkBoxUnSelectedImg forState:UIControlStateNormal];
    }
    else{
        [sender setImage:checkBoxSelectedImg forState:UIControlStateNormal];
    }
}

- (void)continueShoppingButtonAction {
    
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    if (viewControllerArray.count > 3 && [viewControllerArray[3] isKindOfClass:[STProductCategoriesViewController class]]) {
        [self.navigationController popToViewController:viewControllerArray[3] animated:YES];
    }
    else {
        STProductCategoriesViewController *productCategoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductCategoriesViewController"];
        [self.navigationController pushViewController:productCategoriesViewController animated:YES];
    }
}

- (void)checkoutButtonAction {
    if(self.cartArr.count)
        [self performSegueWithIdentifier:@"shippingSegue" sender:self];
}

@end
