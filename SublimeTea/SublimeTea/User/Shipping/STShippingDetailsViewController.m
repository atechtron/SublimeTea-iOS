//
//  STShippingDetailsViewController.m
//  SublimeTea
//
//  Created by Apple on 07/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STShippingDetailsViewController.h"
#import "STCouponTableViewCell.h"
#import "STDropDownTableViewCell.h"
#import "STPrfileTableViewCell.h"
#import "STPhoneNumberTableViewCell.h"
#import "STPopoverTableViewController.h"
#import "STOrderListHeaderView.h"
#import "STUtility.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "MRMSiOS.h"
#import "PaymentModeViewController.h"
#import "STGlobalCacheManager.h"
#import "STAddress.h"
#import "STPlaceOrder.h"

@interface STShippingDetailsViewController ()<UITableViewDataSource, UITableViewDelegate, STDropDownTableViewCellDeleagte, STPopoverTableViewControllerDelegate, UIPopoverPresentationControllerDelegate, STCouponTableViewCellDelegate,UITextFieldDelegate, UITextViewDelegate>
{
    NSArray *listOfStates;
    NSMutableDictionary *jsondict;
    NSDictionary *selectedCountryDict;
    NSDictionary *billingSelectedCountryDict;
    STPopoverTableViewController *popoverViewController;
    STAddress *address;
}

@property(nonatomic,retain)UIPopoverPresentationController *statesPopover;

@property(weak,nonatomic) UITextField *nameTextField;
@property(weak,nonatomic) UITextView  *addressTextView;
@property(weak,nonatomic) UITextField *cityTextField;
@property(weak,nonatomic) UITextField *stateTextField;
@property(weak,nonatomic) UITextField *postalCodeTextField;
@property(weak,nonatomic) UITextField *countryextField;
@property(weak,nonatomic) UITextField *emailTextField;
@property(weak,nonatomic) UITextField *phoneTextField;

@property(weak,nonatomic) UITextField *billingNameTextField;
@property(weak,nonatomic) UITextView  *billingAddressTextView;
@property(weak,nonatomic) UITextField *billingCityTextField;
@property(weak,nonatomic) UITextField *billingStateTextField;
@property(weak,nonatomic) UITextField *billingPostalCodeTextField;
@property(weak,nonatomic) UITextField *billingCountryextField;
@property(weak,nonatomic) UITextField *billingEmailTextField;
@property(weak,nonatomic) UITextField *billingPhoneTextField;

@property(weak,nonatomic) UITextField *couponCodeTextField;

@property(nonatomic) BOOL isShippingISBillingAddress;
@end

@implementation STShippingDetailsViewController

- (void)setIsShippingISBillingAddress:(BOOL)isShippingISBillingAddress {
    _isShippingISBillingAddress = isShippingISBillingAddress;
    address.isBillingIsShipping = isShippingISBillingAddress;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    address = [STAddress new];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.isShippingISBillingAddress = YES;
    
    [STUtility stopActivityIndicatorFromView:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self prepareCountryData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [STUtility startActivityIndicatorOnView:nil withText:@"Loading, Please wait..."];
    //    self.navigationController.navigationBarHidden = YES;
    
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
- (void)prepareCountryData {
    NSDictionary *dataDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kCountries_key];
    if (!dataDict) {
        NSError *err;
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"country_states_city" ofType:@"json"]];
        NSJSONSerialization *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&err];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[STGlobalCacheManager defaultManager] addItemToCache:jsonDict withKey:kCountries_key];
            [STUtility stopActivityIndicatorFromView:nil];
        });
    }
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
-(void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


- (IBAction)paymentButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
    // Check Internet Connsection
    if ([STUtility isNetworkAvailable] && [self validateInputs]) {
        if (self.isShippingISBillingAddress) {
            [self setAddress];
            [STUtility startActivityIndicatorOnView:nil withText:@"Loading..."];
            STPlaceOrder *ordercreation = [[STPlaceOrder alloc] init];
            ordercreation.address = address;
            [ordercreation placeOrder];
//            [STUtility stopActivityIndicatorFromView:nil];
//            [self proceedForPayment];
        }
    }
    //        else if (self.isBillingAddressScreen) {
    //            [self proceedForPayment];
    //        }
    //        else {
    //            UINavigationController *navCtrl = self.navigationController;
    //            STShippingDetailsViewController *billingController = [self.storyboard instantiateViewControllerWithIdentifier:@"STShippingDetailsViewController"];
    //            billingController.isBillingAddressScreen = YES;
    //            [navCtrl pushViewController:billingController animated:YES];
    //        }
    //    }
}
- (void)proceedForPayment {
    
    float MERCHANT_PRICE = 1;
    NSString *MERCHANT_REFERENCENO = @"14695";
    
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
    paymentView.strDisplayCurrency =@"INR";
    paymentView.strDescription = @"Test Description";
    paymentView.strDescription = @"Test Description";
    
    paymentView.strBillingName = @"Test";
    paymentView.strBillingAddress = @"Bill address";
    paymentView.strBillingCity =@"Bill City";
    paymentView.strBillingState = @"TN";
    paymentView.strBillingPostal =@"625000";
    paymentView.strBillingCountry = @"IND";
    paymentView.strBillingEmail =@"test@testmail.com";
    paymentView.strBillingTelephone =@"9363469999";
    
    // Non mandatory parameters
    paymentView.strDeliveryName = @"";
    paymentView.strDeliveryAddress = @"";
    paymentView.strDeliveryCity = @"";
    paymentView.strDeliveryState = @"";
    paymentView.strDeliveryPostal =@"";
    paymentView.strDeliveryCountry = @"";
    paymentView.strDeliveryTelephone =@"";
    //    paymentView.strBillingName = self.nameTextField.text;
    //    paymentView.strBillingAddress = self.addressTextView.text;
    //    paymentView.strBillingCity = self.cityTextField.text;
    //    paymentView.strBillingState = self.stateTextField.text;
    //    paymentView.strBillingPostal = self.postalCodeTextField.text;
    //    paymentView.strBillingCountry = self.countryextField.text;
    //    paymentView.strBillingEmail = self.emailTextField.text;
    //    paymentView.strBillingTelephone = self.phoneTextField.text;
    //
    //    paymentView.strDeliveryName = self.nameTextField.text;
    //    paymentView.strDeliveryAddress = self.addressTextView.text;
    //    paymentView.strDeliveryCity = self.cityTextField.text;
    //    paymentView.strDeliveryState = self.stateTextField.text;
    //    paymentView.strDeliveryPostal = self.postalCodeTextField.text;
    //    paymentView.strDeliveryCountry = self.countryextField.text;
    //    paymentView.strDeliveryTelephone = self.phoneTextField.text;
    
    
    //If you want to add any extra parameters dynamically you have to add the Key and value as we //mentioned below
    //        [dynamicKeyValueDictionary setValue:@"savings" forKey:@"account_detail"];
    //        [dynamicKeyValueDictionary setValue:@"gold" forKey:@"merchant_type"];
    //      paymentView.dynamicKeyValueDictionary = dynamicKeyValueDictionary;
    
    
    [self.navigationController pushViewController:paymentView animated:NO];
}

- (BOOL)validateInputs {
    BOOL status = NO;
    NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *addressStr = [self.addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *cityStr = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *stateStr = [self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *postalCodeStr = [self.postalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *countryStr = [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    status = [self validateName:nameStr
                        address:addressStr
                           city:cityStr
                          state:stateStr
                     postalCode:postalCodeStr
                        country:countryStr
                        emailID:emailStr
                          phone:phoneStr];
    if (!self.isShippingISBillingAddress) {
        
        NSString *nameStr = [self.billingNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addressStr = [self.billingAddressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cityStr = [self.billingCityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stateStr = [self.billingStateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *postalCodeStr = [self.billingPostalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *countryStr = [self.billingCountryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailStr = [self.billingEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *phoneStr = [self.billingPhoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        status = [self validateName:nameStr
                            address:addressStr
                               city:cityStr
                              state:stateStr
                         postalCode:postalCodeStr
                            country:countryStr
                            emailID:emailStr
                              phone:phoneStr];
    }
    
    return status;
}
- (BOOL)validateName:(NSString *)nameStr
             address:(NSString *)addressStr
                city:(NSString *)cityStr
               state:(NSString *)stateStr
          postalCode:(NSString *)postalCodeStr
             country:(NSString *)countryStr
             emailID:(NSString *)emailStr
               phone:(NSString *)phoneStr {
    
    BOOL status = NO;
    NSArray *nameCompnents = [nameStr componentsSeparatedByString:@" "];
    if (nameStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Name is required!"];
    }
    else if (nameCompnents.count < 1){
        [self showAlertWithTitle:@"Message" msg:@"Last Name is required!"];
    }
    else if (addressStr.length == 0)
    {
        [self showAlertWithTitle:@"Message" msg:@"Address is required!"];
    }
    else if (cityStr.length == 0){
        [self showAlertWithTitle:@"Message" msg:@"City is required!"];
    }
    else if (stateStr.length == 0){
        [self showAlertWithTitle:@"Message" msg:@"State is required!"];
    }
    else if (postalCodeStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Postalcode is required!"];
    }
    else if (countryStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Country is required!"];
    }
    else if (emailStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Email is required!"];
    }
    else if (phoneStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Phone is required!"];
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
- (NSArray *)getCountriesCode {
    NSDictionary *countriesDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kCountries_key];
    NSArray *countries = [countriesDict allValues];
    return countries;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 1;
    if (!self.isShippingISBillingAddress) {
        count = 2;
    }
    return count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
        {
            NSString *cellIdentifier = @"textFieldCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextFieldTitleLabel.text = @"Name";
            if (indexPath.section == 0) {
                self.nameTextField = _cell.profileTextField;
            }
            else {
                self.billingNameTextField = _cell.profileTextField;
            }
            cell = _cell;
            break;
        }
        case 1:
        {
            NSString *cellIdentifier = @"textViewCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextViewTitleLabel.text = @"Shipping Address";
            if (indexPath.section == 0) {
                self.addressTextView = _cell.profileTextView;
            }
            else {
                self.billingAddressTextView = _cell.profileTextView;
            }
            cell = _cell;
            break;
        }
        case 2:
        {
            NSString *cellIdentifier = @"dropDownCell";
            STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.delegate = self;
            _cell.indexPath = indexPath;
            _cell.dropDownTextField.tag = indexPath.row;
            _cell.dropDownTitleLabel.text = @"Shipping State";
            _cell.textFieldTitleLabel.text = @"Shipping City";
            if (indexPath.section == 0) {
                self.cityTextField = _cell.textField;
                self.stateTextField = _cell.dropDownTextField;
            }
            else {
                self.billingCityTextField = _cell.textField;
                self.billingStateTextField = _cell.dropDownTextField;
            }
            cell = _cell;
            break;
        }
        case 3:
        {
            NSString *cellIdentifier = @"dropDownCell";
            STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.delegate = self;
            _cell.indexPath = indexPath;
            _cell.dropDownTextField.tag = indexPath.row;
            _cell.dropDownTitleLabel.text = @"Shipping Country";
            _cell.textFieldTitleLabel.text = @"Shipping Postal Code";
            if (indexPath.section == 0) {
                self.postalCodeTextField = _cell.textField;
                self.countryextField = _cell.dropDownTextField;
            }
            else {
                self.billingPostalCodeTextField = _cell.textField;
                self.billingCountryextField = _cell.dropDownTextField;
            }
            cell = _cell;
            break;
        }
        case 4:
        {
            NSString *cellIdentifier = @"textFieldCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextFieldTitleLabel.text = @"Shipping Email";
            if (indexPath.section == 0) {
                self.emailTextField = _cell.profileTextField;
            }else {
                self.billingEmailTextField = _cell.profileTextField;
            }
            cell = _cell;
            break;
        }
        case 5:
        {
            NSString *cellIdentifier = @"phoneNumberCell";
            STPhoneNumberTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.titleLabel.text = @"Shipping Phone";
            _cell.phoneCountryCodeTextBox.text = @"+91";
            if (indexPath.section == 0) {
                self.phoneTextField = _cell.phoneTextField;
            }
            else {
                self.billingPhoneTextField = _cell.phoneTextField;
            }
            cell = _cell;
            break;
        }
        case 6:
        {
            if (indexPath.section == 0) {
                NSString *cellIdentifier = @"checkBoxButtonCell";
                STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                _cell.delegate = self;
                _cell.indexPath = indexPath;
                _cell.firstradioButtonTitlrLabel.text = @"Use my shipping address as my billing address";
                _cell.secondRadioButtonTtitleLabel.text = @"Ship to different address";
                UIImage *unselectedCheckBox = [UIImage imageNamed:@"chekboxUnselected"];
                UIImage *selectedCheckBox = [UIImage imageNamed:@"checkboxSelected"];
                if(self.isShippingISBillingAddress)
                {
                    [_cell.firstRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
                    [_cell.secondRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
                }
                else
                {
                    [_cell.firstRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
                    [_cell.secondRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
                }
                cell = _cell;
            }
            else {
                NSString *cellIdentifier = @"couponCell";
                STCouponTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                _cell.delegate = self;
                _cell.titleLabel.text = @"Discount Coupon";
                self.couponCodeTextField = _cell.couponTextField;
                cell = _cell;
            }
            
            break;
        }
            
        default:
            break;
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    NSString *titleStr = @"Shipping Details";
    if (section == 1) {
        titleStr = @"Billing Address";
    }
    footerView.titleLabel.text = titleStr;
    footerView._backgroundView.backgroundColor = [UIColor whiteColor];
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 62;
}
#pragma mark-
#pragma STDropDownTableViewCellDeleagte

- (void)dropDownItemDidSelect:(NSIndexPath *)tindexPath withCell:(UITableViewCell *)cell {
    
}
- (void)checkBoxStateDidChanged:(UITableViewCell *)cell senderControl:(id)checkBox {
    [self.tableView beginUpdates];
    UIImage *unselectedCheckBox = [UIImage imageNamed:@"chekboxUnselected"];
    UIImage *selectedCheckBox = [UIImage imageNamed:@"checkboxSelected"];
    STDropDownTableViewCell *checkBoxCell = (STDropDownTableViewCell *)cell;
    if ([checkBox isEqual:checkBoxCell.firstRadioButton] || [checkBox isEqual:checkBoxCell.firstradioButtonTitlrLabel]) {
        [checkBoxCell.secondRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
        [checkBoxCell.firstRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
        self.isShippingISBillingAddress = YES;
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        [self.paymentBtn setTitle:@"Proceed to Payments" forState:UIControlStateNormal];
    }
    else {
        [checkBoxCell.firstRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
        [checkBoxCell.secondRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
        self.isShippingISBillingAddress = NO;
        [self.tableView reloadData];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        //        [self.paymentBtn setTitle:@"Next" forState:UIControlStateNormal];
    }
    address.isBillingIsShipping = self.isShippingISBillingAddress;
    [self.tableView endUpdates];
}
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath {
    
    popoverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STPopoverTableViewController"];
    popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
    popoverViewController.delegate = self;
    popoverViewController.parentIndexPath = indexPath;
    NSLog(@"%d",sender.tag);
    NSLog(@"%d",indexPath.section);
    
    switch (indexPath.section) {
        case 0:
        {
            switch (sender.tag) {
                case 2:
                {
                    if (selectedCountryDict) {
                        popoverViewController.itemsArray = [selectedCountryDict [@"states"] allValues];
                        NSLog(@"%@",popoverViewController.itemsArray);
                    }
                    break;
                }
                case 3:
                {
                    popoverViewController.itemsArray = [self getCountriesCode];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            NSLog(@"%d",indexPath.section);
            switch (sender.tag) {
                case 2:
                {
                    if (billingSelectedCountryDict) {
                        popoverViewController.itemsArray = [billingSelectedCountryDict [@"states"] allValues];
                        NSLog(@"%@",popoverViewController.itemsArray);
                    }
                    break;
                }
                case 3:
                {
                    popoverViewController.itemsArray = [self getCountriesCode];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    
    
    
//    if (indexPath.section == 0) {
//        if (sender.tag == 2) {// states
//            if (selectedCountryDict) {
//                popoverViewController.itemsArray = [selectedCountryDict [@"states"] allValues];
//                NSLog(@"%@",popoverViewController.itemsArray);
//            }
//        }
//        else if (sender.tag ==3)// countries
//        {
//            popoverViewController.itemsArray = [self getCountriesCode];
//        }
//    }
//    else { // billing address
//        if (sender.tag == 2) {// states
//            if (billingSelectedCountryDict) {
//                popoverViewController.itemsArray = [billingSelectedCountryDict [@"states"] allValues];
//                NSLog(@"%@",popoverViewController.itemsArray);
//            }
//        }
//        else if (sender.tag ==3)// countries
//        {
//            popoverViewController.itemsArray = [self getCountriesCode];
//        }
//    }
    
    _statesPopover = popoverViewController.popoverPresentationController;
    _statesPopover.delegate = self;
    _statesPopover.sourceView = sender;
    _statesPopover.sourceRect = sender.rightView.frame;
    [self presentViewController:popoverViewController animated:YES completion:nil];
}
- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark-
#pragma STPopoverTableViewControllerDelegate

- (void)itemDidSelect:(NSIndexPath *)indexpath selectedItemString:(NSString *)selectedItemStr parentIndexPath:(NSIndexPath *)pIndexPath{
    if (selectedItemStr.length) {
        
        id view =  _statesPopover.sourceView;
        if ([view isEqual:self.countryextField]) {
            if (indexpath.section == 0) {
             self.countryextField.text = selectedItemStr;
            }
            else {
                self.billingCountryextField.text = selectedItemStr;
            }
            NSDictionary *datadict = [self getCountriesCode][indexpath.row];
            if (pIndexPath.section == 0) {
                selectedCountryDict = datadict;
            }
            else {
                billingSelectedCountryDict = datadict;
            }
        }
        else if ([view isEqual:self.stateTextField]) {
            if (indexpath.section == 0) {
                self.stateTextField.text = selectedItemStr;
            }
            else {
                self.billingStateTextField.text = selectedItemStr;
            }
        }
    }
    [popoverViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-
#pragma STCouponTableViewCellDelegate
- (void)applyCouponAction:(UIButton *)sender onCell:(UITableViewCell *)cell {
    
}

#pragma mark -
#pragma UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}
- (void)setAddress {
    
    if (self.isShippingISBillingAddress) {
        
        NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addressStr = [self.addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cityStr = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stateStr = [self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *postalCodeStr = [self.postalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *countryStr = [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *nameComponents = [nameStr componentsSeparatedByString: @" "];
        
        address.shipAddress.firstname = nameComponents.count ? nameComponents[0] :@"";
        NSMutableString *lastNameStr = [NSMutableString new];
        if(nameComponents.count > 1){
        for (NSInteger idx = 1; idx < nameComponents.count; idx ++) {
            [lastNameStr appendString:nameComponents[idx]];
        }
        }
        address.shipAddress.lastname = lastNameStr;
        address.shipAddress.city = cityStr;
        address.shipAddress.state = stateStr;
        address.shipAddress.postcode = postalCodeStr;
        address.shipAddress.country_id = countryStr;
        address.shipAddress.email = emailStr;
        address.shipAddress.telephone = phoneStr;
        address.shipAddress.street = addressStr;
        
    }
    else {
        NSString *nameStr = [self.billingNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addressStr = [self.billingAddressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cityStr = [self.billingCityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stateStr = [self.billingStateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *postalCodeStr = [self.billingPostalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *countryStr = [self.billingCountryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailStr = [self.billingEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *phoneStr = [self.billingPhoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *couponCodeStr = [self.couponCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *nameComponents = [nameStr componentsSeparatedByString: @" "];
        
        address.shipAddress.firstname = nameComponents.count ? nameComponents[0] :@"";
        NSMutableString *lastNameStr = [NSMutableString new];
        for (NSInteger idx = 1; idx <= nameComponents.count; idx ++) {
            [lastNameStr appendString:nameComponents[idx]];
        }
        address.billedAddress.lastname = lastNameStr;
        address.billedAddress.city = cityStr;
        address.billedAddress.state = stateStr;
        address.billedAddress.postcode = postalCodeStr;
        address.billedAddress.country_id = countryStr;
        address.billedAddress.email = emailStr;
        address.billedAddress.telephone = phoneStr;
        address.billedAddress.street = addressStr;
        address.billedAddress.couponCode = couponCodeStr;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark -
#pragma UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {

}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView isEqual:self.addressTextView]) {
        
    }
}
@end
