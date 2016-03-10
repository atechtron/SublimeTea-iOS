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
#import "STCartHeaderView.h"
#import "STProductCategoriesViewController.h"
#import "STUtility.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "MRMSiOS.h"
#import "PaymentModeViewController.h"
#import "STCart.h"
#import "STGlobalCacheManager.h"

@interface STCartViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *jsondict;
}
@property (strong, nonatomic)NSArray *cartArr;
@end

@implementation STCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STCartFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STCartFooterView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STCartHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STCartHeaderView"];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];

    self.cartArr = [[STCart defaultCart] productsDataArr];
}
- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    
    jsondict = [[NSMutableDictionary alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResponseNew:) name:@"FAILED_DICT" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FAILED_DICT_NEW" object:nil userInfo:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) ResponseNew:(NSNotification *)message
{
    if ([message.name isEqualToString:@"FAILED_DICT"])
    {
        //You will get the failed transaction details in below log and in jsondict.
        NSLog(@"Response json data = %@",[message object]);
        
        jsondict = [message object];
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
    
    footerView.continueShoppingButton.layer.borderWidth = 1;
    footerView.continueShoppingButton.layer.borderColor = [UIColor blackColor].CGColor;
    footerView.continueShoppingButton.layer.cornerRadius = 7;
    
    footerView.checkoutButton.layer.borderWidth = 1;
    footerView.checkoutButton.layer.borderColor = [UIColor blackColor].CGColor;
    footerView.checkoutButton.layer.cornerRadius = 7;
    
    return footerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STCartHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STCartHeaderView"];
    headerView.titleLabel.text = @"Our Cart";
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 77;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
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
    float MERCHANT_PRICE = 1;
    NSString *MERCHANT_REFERENCENO = @"";
    
    PaymentModeViewController *paymentView=[[PaymentModeViewController alloc]init];
    paymentView.strSaleAmount=[NSString stringWithFormat:@"%.2f",MERCHANT_PRICE];
    paymentView.reference_no= MERCHANT_REFERENCENO;
    //NOTE: MERCHANT_PRICE and MERCHANT_REFERENCENO has to be given by Merchant developer
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%.2f",MERCHANT_PRICE]     forKey:@"strSaleAmount"];
    [defaults setObject:MERCHANT_REFERENCENO forKey:@"reference_no"];
    [defaults synchronize];
    
    paymentView.descriptionString = @"Test Description";
    paymentView.strCurrency =   @"INR";
    paymentView.strDisplayCurrency =@"USD";
    paymentView.strDescription = @"Test Description";
    
    paymentView.strBillingName = @"Test";
    paymentView.strBillingAddress = @"Bill address";
    paymentView.strBillingCity =@"Bill City";
    paymentView.strBillingState = @"TN";
    paymentView.strBillingPostal =@"625000";
    paymentView.strBillingCountry = @"IND";
    paymentView.strBillingEmail =@"test@testmail.com";
    paymentView.strBillingTelephone =@"9363469999";
    
    paymentView.strDeliveryName = @"";
    paymentView.strDeliveryAddress = @"";
    paymentView.strDeliveryCity = @"";
    paymentView.strDeliveryState = @"";
    paymentView.strDeliveryPostal =@"";
    paymentView.strDeliveryCountry = @"";
    paymentView.strDeliveryTelephone =@"";
    
    
    //If you want to add any extra parameters dynamically you have to add the Key and value as we //mentioned below
    //        [dynamicKeyValueDictionary setValue:@"savings" forKey:@"account_detail"];
    //        [dynamicKeyValueDictionary setValue:@"gold" forKey:@"merchant_type"];
    //      paymentView.dynamicKeyValueDictionary = dynamicKeyValueDictionary;
    
    [self.navigationController pushViewController:paymentView animated:NO];
}

@end
