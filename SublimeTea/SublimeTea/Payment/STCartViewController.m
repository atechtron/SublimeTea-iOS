//
//  STCartViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCartViewController.h"
//#import "STCartTableViewCell.h"
//#import "STCartFooterView.h"
//#import "STOrderListHeaderView.h"
#import "STProductCategoriesViewController.h"
#import "STUtility.h"
#import "STCart.h"
#import "STGlobalCacheManager.h"
#import "STShippingDetailsViewController.h"
#import "STPopoverTableViewController.h"
#import "STCartSubTotalTableViewCell.h"
#import "STCartProdTotalTableViewCell.h"

@interface STCartViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STCartTableViewCellDelegate, UIPopoverPresentationControllerDelegate,STPopoverTableViewControllerDelegate>

@property(nonatomic,strong)UIPopoverPresentationController *statesPopover;
@property(weak,nonatomic)STPopoverTableViewController *popoverCtrl;
@property (strong, nonatomic)NSMutableArray *cartArr;

@property (weak, nonatomic) UITextField *qtyTxtField;
@end

@implementation STCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"STCartFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STCartFooterView"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    
//    self.tableView.estimatedRowHeight = 44;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
    
    self.cartArr = [[[STCart defaultCart] productsDataArr] mutableCopy];
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
- (NSArray *)getQTYArr {
    NSMutableArray *tempATYArr = [NSMutableArray new];
    NSInteger count = 0;
    do {
        ++count;
        [tempATYArr addObject:[NSNumber numberWithInteger:count]];
        
    } while (count != kMaxQTY);
    return tempATYArr;
}

#pragma mark-
#pragma UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //FIXME: need to ask about this!!
    return self.cartArr.count + 1;  // plus 1 because of 1st row!!
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld, %ld",indexPath.row, self.cartArr.count);
    if (indexPath.row == 0) {
        STCartSubTotalTableViewCell *subTotalCell = [tableView dequeueReusableCellWithIdentifier:@"STCartSubTotalTableViewCell" forIndexPath:indexPath];
        subTotalCell.subTotalValueLabel.text = @"\u20B9 124";
        subTotalCell.totalItemsValueLabel.text = @"1";
        subTotalCell.shippingChargesValueLabel.text = @"\u20B9 123";
        return subTotalCell;
    }else{
        STCartProdTotalTableViewCell *prodTotalCell = [tableView dequeueReusableCellWithIdentifier:@"STCartProdTotalTableViewCell" forIndexPath:indexPath];
        prodTotalCell.delegate = self;
        if (self.cartArr.count > indexPath.row) {
            Product *prod = self.cartArr[indexPath.row];
//            NSString *prodId = prod.prodDict[@"product_id"][@"__text"];
            NSString *name = prod.prodDict[@"name"][@"__text"];
//            NSString *shortDesc = prod.prodDict[@"short_description"][@"__text"];
            NSString *price = prod.prodDict[@"special_price"][@"__text"];
            NSLog(@"%@",prod.prodDict);
            prodTotalCell.productNameLabel.text = name;
            //        prodTotalCell.descriptionLabel.text = shortDesc;
            //        prodTotalCell.priceTitleLabel.text = @"Price";
            prodTotalCell.prodTotalValueLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%f",[price floatValue]]];
            prodTotalCell.prodQuantityTextField.text = prod.prodQty> 0 ?[NSString stringWithFormat:@"%ld",(long)prod.prodQty]:@"";
            prodTotalCell.prodQuantityTextField.tag = indexPath.row;
            prodTotalCell.prodQuantityTextField.delegate = self;
            self.qtyTxtField = prodTotalCell.prodQuantityTextField;
            
            prodTotalCell.removeProdButton.tag = indexPath.row;
            
            //        [prodTotalCell.checkboxButton addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            prodTotalCell.prodQuantityTextField.text = @"1";
            prodTotalCell.prodTotalValueLabel.text = @"\u20B9 10";
        }
        
        prodTotalCell.mrpValueLabel.text = @"\u20B9 12";
        prodTotalCell.splMrpValueLabel.text = @"\u20B9 10";
        prodTotalCell.savingsValueLabel.text = @"\u20B9 2";
        
        return prodTotalCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 103;
    }
    return 195;
}

//    static NSString *cellidentifier = @"cartCell";
//    STCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
//    cell.delegate = self;
//    Product *prod = self.cartArr[indexPath.row];
//    
//    NSString *prodId = prod.prodDict[@"product_id"][@"__text"];
//    NSString *name = prod.prodDict[@"name"][@"__text"];
//    NSString *shortDesc = prod.prodDict[@"short_description"][@"__text"];
//    NSString *price = prod.prodDict[@"special_price"][@"__text"];
//    NSLog(@"%@",prod.prodDict);
//    NSArray *prodImgArr = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
//    if (prodImgArr.count) {
//        NSDictionary *imgUrlDict = [prodImgArr lastObject];
//        NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
//        NSLog(@"Image URL %@",imgUrl);
//        NSData *imgData = (NSData *)[[STGlobalCacheManager defaultManager] getItemForKey:imgUrl];
//        if (imgData) {
//            UIImage *prodImg = [UIImage imageWithData:imgData];
//            if (prodImg) {
//                [UIView transitionWithView:cell.porudctImageView duration:0.5
//                                   options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//                                       cell.porudctImageView.image = prodImg;
//                                       cell.porudctImageView.contentMode = UIViewContentModeScaleAspectFit;
//                                   } completion:nil];
//            }
//        }
//    }
//    
//    cell.checkboxButton.tag = indexPath.row;
//    cell.titleLabel.text = name;
//    cell.descriptionLabel.text = shortDesc;
//    cell.priceTitleLabel.text = @"Price";
//    cell.priceLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%f",[price floatValue]]];
//    cell.qtyTextbox.text = prod.prodQty> 0 ?[NSString stringWithFormat:@"%ld",(long)prod.prodQty]:@"";
//    cell.qtyTextbox.tag = indexPath.row;
//    cell.qtyTextbox.delegate = self;
//    self.qtyTxtField = cell.qtyTextbox;
//    
//    cell.removeBtn.tag = indexPath.row;
//    
//    [cell.checkboxButton addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//    return cell;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    STCartFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STCartFooterView"];
//    footerView.topBorderView.backgroundColor = [STUtility getSublimeHeadingBGColor];
//    [footerView.continueShoppingButton addTarget:self action:@selector(continueShoppingButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    [footerView.checkoutButton addTarget:self action:@selector(checkoutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//    return footerView;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    STOrderListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
//    headerView._backgroundView.backgroundColor = [UIColor whiteColor];
//    headerView.titleLabel.text = @"Our Cart";
//    return headerView;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 77;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 62;
//}
- (void)checkBoxAction:(UIButton *)sender {
    UIImage *checkBoxSelectedImg = [UIImage imageNamed:@"checkboxSelected"];
    UIImage *checkBoxUnSelectedImg = [UIImage imageNamed:@"chekboxUnselected"];
    if ([sender.imageView.image isEqual:checkBoxSelectedImg]) {
        [sender setImage:checkBoxUnSelectedImg forState:UIControlStateNormal];
    }
    else{
        [sender setImage:checkBoxSelectedImg forState:UIControlStateNormal];
    }
    Product *prod = self.cartArr[sender.tag];
    prod.buy = YES;
    [self.cartArr replaceObjectAtIndex:sender.tag withObject:prod];
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

- (void)checkoutButtonAction:(UIButton *)sender {
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
        [self performSegueWithIdentifier:@"shippingSegue" sender:self];
    }
}
- (BOOL)validateInputs {
    BOOL status = NO;
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"prodQty == %d",0];
    NSArray *prodWithZeroQty = [self.cartArr filteredArrayUsingPredicate:filterPredicate];
    if (self.cartArr.count == 0) {
        [self showAlertWithTitle:@"Messgae" msg:@"Cart is empty"];
    }
    else if (prodWithZeroQty.count > 0) {
        [self showAlertWithTitle:@"Messgae" msg:@"Product qyuantity should be atleast one."];
    }
    else {
        status = YES;
    }
    return status;
}
- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
#pragma mark-
#pragma STCartTableViewDelegate
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture {
    self.popoverCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"STPopoverTableViewController"];
    self.popoverCtrl.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverCtrl.delegate = self;
    self.popoverCtrl.itemsArray = [self getQTYArr];
    _statesPopover = self.popoverCtrl.popoverPresentationController;
    _statesPopover.delegate = self;
    _statesPopover.sourceView = sender;
    _statesPopover.sourceRect = sender.rightView.frame;
    [self presentViewController:self.popoverCtrl animated:YES completion:nil];
}
- (void)itemDidRemoveFromCart:(UIButton *)sender {
    
    [[STCart defaultCart] removeProductFromCart:sender.tag];
    self.cartArr = [[STCart defaultCart] productsDataArr];
    NSString *cartCount = [NSString stringWithFormat:@"%ld",(long)[[STCart defaultCart] numberOfProductsInCart]];
    cartBadgeView.badgeText = [cartCount integerValue]>0?cartCount:@"";
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag+1 inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark-
#pragma STPopoverTableViewControllerDelegate

- (void)itemDidSelect:(NSIndexPath *)indexpath selectedItemString:(NSString *)selectedItemStr parentIndexPath:(NSIndexPath *)pIndexPath{
    NSNumber *qty = [self getQTYArr][indexpath.row];
    
    [[STCart defaultCart] updateProductToCartAtIndex:_statesPopover.sourceView.tag withQty:[qty integerValue]];
    self.cartArr = [[STCart defaultCart] productsDataArr];
    
//    [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.qtyTxtField.text = [NSString stringWithFormat:@"%@",qty];
    [self.popoverCtrl dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-
#pragma UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark-
#pragma UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSString *qtyStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    Product *prod = self.cartArr[textField.tag];
    prod.prodQty = [qtyStr integerValue];
    [self.cartArr replaceObjectAtIndex:textField.tag withObject:prod];
}
@end
