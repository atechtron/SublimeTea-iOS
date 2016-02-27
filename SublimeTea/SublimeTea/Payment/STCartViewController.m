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

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "MRMSiOS.h"
#import "PaymentModeViewController.h"

@interface STCartViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *jsondict;
}
@end

@implementation STCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STCartFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STCartFooterView"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
- (void)viewWillAppear {
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
#pragma mark-
#pragma UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cartCell";
    STCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"Product Description %ld",indexPath.row +1];
    cell.descriptionLabel.text = @"Short product description ...";
    cell.priceLabel.text = @"1500";
    cell.porudctImageView.image = [UIImage imageNamed:@"teaCup.jpeg"];
    cell.qtyTextbox.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.qtyTextbox.layer.borderWidth = .8;
    [cell.checkboxButton addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    STCartFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STCartFooterView"];
    footerView.topBorderView.backgroundColor = [UIColor blackColor];
    [footerView.continueShoppingButton addTarget:self action:@selector(continueShoppingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView.checkoutButton addTarget:self action:@selector(continueShoppingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    footerView.continueShoppingButton.layer.borderWidth = 1;
    footerView.continueShoppingButton.layer.borderColor = [UIColor blackColor].CGColor;
    footerView.continueShoppingButton.layer.cornerRadius = 7;
    
    footerView.checkoutButton.layer.borderWidth = 1;
    footerView.checkoutButton.layer.borderColor = [UIColor blackColor].CGColor;
    footerView.checkoutButton.layer.cornerRadius = 7;
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 77;
}

- (void)checkBoxAction:(UIButton *)sender {
    
}

- (void)continueShoppingButtonAction {
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    [self.navigationController popToViewController:viewControllerArray[2] animated:YES];
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
