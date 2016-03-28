//
//  STOrderConfirmationViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STOrderConfirmationViewController.h"
#import "STOderListTableViewCell.h"
#import "STOrderConfirmationFooterView.h"
#import "STOrderConfirmationHeaderView.h"
#import "STUtility.h"
#import "STProductCategoriesViewController.h"
#import "STOrderListViewController.h"
#import "STCart.h"
#import "STGlobalCacheManager.h"

@interface STOrderConfirmationViewController ()<UITableViewDataSource, UITableViewDelegate, STOrderConfirmationFooterViewDelegat>

@property (strong,nonatomic)NSArray *itemArray;
@property(strong, nonatomic)NSMutableDictionary *jsondict;
@end

@implementation STOrderConfirmationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.itemArray = [[STCart defaultCart] productsDataArr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResponseNew:) name:@"JSON_NEW" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JSON_DICT" object:nil userInfo:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderConfirmationHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderConfirmationHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderConfirmationFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderConfirmationFooterView"];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) ResponseNew:(NSNotification *)message
{
    if ([message.name isEqualToString:@"JSON_NEW"])
    {
        dbLog(@"Response = %@",[message object]);
        _jsondict = [message object];
    }
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
    return self.itemArray.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"orderConfirmationCell";
    STOderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    Product *prod = self.itemArray[indexPath.row];
    
    NSString *prodId = prod.prodDict[@"product_id"][@"__text"];
    NSString *name = prod.prodDict[@"name"][@"__text"];
    NSString *shortDesc = prod.prodDict[@"short_description"][@"__text"];
    double price = [prod.prodDict[@"special_price"][@"__text"]doubleValue];

    NSArray *prodImgArr = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
    if (prodImgArr.count) {
        NSDictionary *imgUrlDict = [prodImgArr lastObject];
        NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
        dbLog(@"Image URL %@",imgUrl);
        NSData *imgData = (NSData *)[[STGlobalCacheManager defaultManager] getItemForKey:imgUrl];
        if (imgData) {
            UIImage *prodImg = [UIImage imageWithData:imgData];
            if (prodImg) {
                [UIView transitionWithView:cell.prodImageView duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                       cell.prodImageView.image = prodImg;
                                       cell.prodImageView.contentMode = UIViewContentModeScaleAspectFit;
                                   } completion:nil];
            }
        }
    }
    
    
    
    
    cell.titleLabel.text = [name uppercaseString];
    cell.descriptionLabel.text = shortDesc;
    cell.priceLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%.2f",price]];
    cell.statusLabel.text = @"Status: Order Placed";
    NSString *itemStr = prod.prodQty > 1 ? @"ITEMS" :@"ITEM";
    cell.qtyLabel.text = [NSString stringWithFormat:@"QUANTITY: %ld (%@)",(long)prod.prodQty,itemStr];
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderConfirmationHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderConfirmationHeaderView"];
//    footerView.titleLabel.text = @"Orders";
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 273;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    STOrderConfirmationFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderConfirmationFooterView"];
    footerView.delegate = self;
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 80;
}

- (void)orderButtonClicked {
    STOrderListViewController *orderListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STOrderListViewController"];
    [self.navigationController pushViewController:orderListViewController animated:YES];
}
- (void)continueShoppingButtonClicked {
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    if (viewControllerArray.count > 3 && [viewControllerArray[3] isKindOfClass:[STProductCategoriesViewController class]]) {
        [self.navigationController popToViewController:viewControllerArray[3] animated:YES];
    }
    else {
        STProductCategoriesViewController *productCategoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductCategoriesViewController"];
        [self.navigationController pushViewController:productCategoriesViewController animated:YES];
    }
}
@end
