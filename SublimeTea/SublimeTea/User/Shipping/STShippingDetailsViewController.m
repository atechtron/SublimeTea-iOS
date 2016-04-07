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
#import "STHttpRequest.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "MRMSiOS.h"
#import "PaymentModeViewController.h"
#import "STGlobalCacheManager.h"
#import "STAddress.h"
#import "STPlaceOrder.h"


@interface STShippingDetailsViewController ()<UITableViewDataSource, UITableViewDelegate, STDropDownTableViewCellDeleagte, STPopoverTableViewControllerDelegate, UIPopoverPresentationControllerDelegate, STCouponTableViewCellDelegate,UITextFieldDelegate, UITextViewDelegate, STPlaceOrderDelegate>
{
    NSArray *listOfStates;
    NSMutableDictionary *jsondict;
    NSDictionary *selectedCountryDict;
    NSDictionary *billingSelectedCountryDict;
    
    NSInteger selectedStatesIdxForShipping;
    NSInteger selectedStatesIdxForBilling;
    
    STPopoverTableViewController *popoverViewController;
    STAddress *address;
}
@property (nonatomic)BOOL isBillingAddress;

@property(nonatomic,retain)UIPopoverPresentationController *statesPopover;

@property(weak,nonatomic) UITextField *firstNameTextField;
@property(weak,nonatomic) UITextField *lastNameTextField;
@property(weak,nonatomic) UITextView  *addressTextView;
@property(weak,nonatomic) UITextField *cityTextField;
@property(weak,nonatomic) UITextField *stateTextField;
@property(weak,nonatomic) UITextField *postalCodeTextField;
@property(weak,nonatomic) UITextField *countryextField;
@property(weak,nonatomic) UITextField *emailTextField;
@property(weak,nonatomic) UITextField *phoneTextField;

@property(weak,nonatomic) UITextField *billingFirstNameTextField;
@property(weak,nonatomic) UITextField *billingLastNameTextField;
@property(weak,nonatomic) UITextView  *billingAddressTextView;
@property(weak,nonatomic) UITextField *billingCityTextField;
@property(weak,nonatomic) UITextField *billingStateTextField;
@property(weak,nonatomic) UITextField *billingPostalCodeTextField;
@property(weak,nonatomic) UITextField *billingCountryextField;
@property(weak,nonatomic) UITextField *billingEmailTextField;
@property(weak,nonatomic) UITextField *billingPhoneTextField;

@property(weak,nonatomic) UITextField *couponCodeTextField;

@property(nonatomic) BOOL isShippingISBillingAddress;

@property(strong, nonatomic)NSArray *listOfCountries;

@property(strong, nonatomic)NSArray *listOfStatesForSelectedCountryForShipping;
@property(strong, nonatomic)NSArray *listOfStatesForSelectedCountryForBilling;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    popoverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STPopoverTableViewController"];
    popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
    popoverViewController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self prepareCountryData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    //    [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
    //    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
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
        dbLog(@"Response json data = %@",[message object]);
        
        jsondict = [message object];
    }
}
-(void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIView *superView = textField.superview.superview;
    dbLog(@"%@",superView);
    if (textField.tag == 3) {
        if ([superView isKindOfClass:[STDropDownTableViewCell class]]) {
            STDropDownTableViewCell *cell = (STDropDownTableViewCell *)superView;
            
            [self droDownAction:textField tapGesture:nil indexPath:cell.indexPath];
        }
        
        return NO;
    }
    else if (textField.tag == 4) {
        if ([superView isKindOfClass:[STDropDownTableViewCell class]]) {
            STDropDownTableViewCell *cell = (STDropDownTableViewCell *)superView;
            [self droDownAction:textField tapGesture:nil indexPath:cell.indexPath];
        }
        return NO;
    }
    return YES;
}
#pragma mark - keypad related methods

- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIEdgeInsets insets = [_tableView contentInset];
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        [_tableView setContentInset:UIEdgeInsetsMake(insets.top, insets.left, 300, insets.right)];
        [[self view] layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIEdgeInsets insets = [_tableView contentInset];
    [UIView animateWithDuration:duration delay:0. options:animationCurve animations:^{
        [_tableView setContentInset:UIEdgeInsetsMake(insets.top, insets.left, 0, insets.right)];
        [[self view] layoutIfNeeded];
    } completion:nil];
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
            [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
            STPlaceOrder *ordercreation = [[STPlaceOrder alloc] init];
            ordercreation.delegate = self;
            ordercreation.address = address;
            [ordercreation placeOrder];
        }
    }
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
    //
    //    paymentView.descriptionString = @"Test Description";
    //    paymentView.strCurrency =   @"INR";
    //    paymentView.strDisplayCurrency =@"INR";
    //    paymentView.strDescription = @"Test Description";
    //    paymentView.strDescription = @"Test Description";
    //
    //    paymentView.strBillingName = @"Test";
    //    paymentView.strBillingAddress = @"Bill address";
    //    paymentView.strBillingCity =@"Kanpur";
    //    paymentView.strBillingState = @"UP";
    //    paymentView.strBillingPostal =@"625000";
    //    paymentView.strBillingCountry = @"IND";
    //    paymentView.strBillingEmail =@"btecharpit@gmail.com";
    //    paymentView.strBillingTelephone =@"9363469999";
    //
    //    // Non mandatory parameters
    //    paymentView.strDeliveryName = @"";
    //    paymentView.strDeliveryAddress = @"";
    //    paymentView.strDeliveryCity = @"";
    //    paymentView.strDeliveryState = @"";
    //    paymentView.strDeliveryPostal =@"";
    //    paymentView.strDeliveryCountry = @"";
    //    paymentView.strDeliveryTelephone =@"";
    
    paymentView.descriptionString = [NSString stringWithFormat:@"%@ %@",self.firstNameTextField.text,self.lastNameTextField.text];
    paymentView.strCurrency =   @"INR";
    paymentView.strDisplayCurrency = @"INR";
    paymentView.strDescription = [NSString stringWithFormat:@"%@ %@",self.firstNameTextField.text,self.lastNameTextField.text];
    paymentView.strBillingName = [NSString stringWithFormat:@"%@ %@",self.firstNameTextField.text,self.lastNameTextField.text];
        paymentView.strBillingAddress = self.addressTextView.text;
        paymentView.strBillingCity = self.cityTextField.text;
        paymentView.strBillingState = self.stateTextField.text;
        paymentView.strBillingPostal = self.postalCodeTextField.text;
        paymentView.strBillingCountry = selectedCountryDict[@"iso3_code"][@"__text"];//self.countryextField.text;
        paymentView.strBillingEmail = self.emailTextField.text;
        paymentView.strBillingTelephone = self.phoneTextField.text;
    
    paymentView.strDeliveryName = self.billingFirstNameTextField.text.length?[NSString stringWithFormat:@"%@ %@",self.billingFirstNameTextField.text,self.billingLastNameTextField.text]:[NSString stringWithFormat:@"%@ %@",self.firstNameTextField.text,self.lastNameTextField.text];
    paymentView.strDeliveryAddress = self.billingAddressTextView.text.length ?self.billingAddressTextView.text:self.addressTextView.text;
    paymentView.strDeliveryCity = self.billingCityTextField.text.length ?self.billingCityTextField.text:self.cityTextField.text;
    paymentView.strDeliveryState = self.billingStateTextField.text.length?self.billingStateTextField.text:self.stateTextField.text;
    paymentView.strDeliveryPostal = self.billingPostalCodeTextField.text.length?self.billingPostalCodeTextField.text:self.postalCodeTextField.text;
    paymentView.strDeliveryCountry = paymentView.strDeliveryCountry.length?billingSelectedCountryDict[@"iso3_code"][@"__text"]:paymentView.strBillingCountry ;//self.billingCountryextField.text.length?self.billingCountryextField.text:self.countryextField.text;
    paymentView.strDeliveryTelephone = self.billingPhoneTextField.text.length?self.billingPhoneTextField.text:self.phoneTextField.text;
    
    
    //If you want to add any extra parameters dynamically you have to add the Key and value as we //mentioned below
    //        [dynamicKeyValueDictionary setValue:@"savings" forKey:@"account_detail"];
    //        [dynamicKeyValueDictionary setValue:@"gold" forKey:@"merchant_type"];
    //      paymentView.dynamicKeyValueDictionary = dynamicKeyValueDictionary;
    
    
    [self.navigationController pushViewController:paymentView animated:NO];
}

- (BOOL)validateInputs {
    BOOL status = NO;
    NSString *firstNameStr = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastNameStr = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *addressStr = [self.addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *cityStr = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *stateStr = [self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *postalCodeStr = [self.postalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *countryStr = [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    status = [self validateName:firstNameStr
                       lastName:lastNameStr
                        address:addressStr
                           city:cityStr
                          state:stateStr
                     postalCode:postalCodeStr
                        country:countryStr
                        emailID:emailStr
                          phone:phoneStr];
    if (!self.isShippingISBillingAddress) {
        
        NSString *firstNameStr = [self.billingFirstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastNameStr = [self.billingLastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addressStr = [self.billingAddressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cityStr = [self.billingCityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stateStr = [self.billingStateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *postalCodeStr = [self.billingPostalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *countryStr = [self.billingCountryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailStr = [self.billingEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *phoneStr = [self.billingPhoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        status = [self validateName:firstNameStr
                           lastName:lastNameStr
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
- (BOOL)validateName:(NSString *)firstNameStr
            lastName:(NSString *)lastNameStr
             address:(NSString *)addressStr
                city:(NSString *)cityStr
               state:(NSString *)stateStr
          postalCode:(NSString *)postalCodeStr
             country:(NSString *)countryStr
             emailID:(NSString *)emailStr
               phone:(NSString *)phoneStr {
    
    BOOL status = NO;
    
    if (firstNameStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Name is required!"];
    }
    else if (lastNameStr.length == 0){
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
    else if (phoneStr.length < 10){
        [self showAlertWithTitle:@"Message" msg:@"Valid Phone number required!"];
    }
    else if (emailStr.length){
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if ([emailTest evaluateWithObject:emailStr] == NO) {
            [self showAlertWithTitle:@"Message" msg:@"Valid Email required!"];
        }
        else {
            status = YES;
        }
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
    NSInteger rowCount = 8;
    if (!self.isShippingISBillingAddress) {
        rowCount = 8;
    }
    return rowCount;
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
            _cell.profileTextFieldTitleLabel.text = @"First Name";
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.text = @"";
            if (indexPath.section == 0) {
                self.firstNameTextField = _cell.profileTextField;
                if(address.shipAddress.firstname.length)
                    _cell.profileTextField.text = address.shipAddress.firstname;
            }
            else {
                self.billingFirstNameTextField = _cell.profileTextField;
                if (address.billedAddress.firstname.length) {
                    _cell.profileTextField.text = address.billedAddress.firstname;
                }
            }
            cell = _cell;
            break;
        }
        case 1:
        {
            NSString *cellIdentifier = @"textFieldCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextFieldTitleLabel.text = @" Last Name";
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.text = @"";
            if (indexPath.section == 0) {
                self.lastNameTextField = _cell.profileTextField;
                if (address.shipAddress.lastname.length) {
                    _cell.profileTextField.text = address.shipAddress.lastname;
                }
            }
            else {
                self.billingLastNameTextField = _cell.profileTextField;
                if (address.billedAddress.lastname.length) {
                    _cell.profileTextField.text = address.billedAddress.lastname;
                }
            }
            cell = _cell;
            break;
        }
        case 2:
        {
            NSString *cellIdentifier = @"textViewCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextViewTitleLabel.text = @"Shipping Address";
            _cell.profileTextView.delegate = self;
            _cell.profileTextView.text = @"";
            if (indexPath.section == 0) {
                self.addressTextView = _cell.profileTextView;
                if (address.shipAddress.street.length) {
                    _cell.profileTextView.text = address.shipAddress.street;
                }
            }
            else {
                self.billingAddressTextView = _cell.profileTextView;
                if (address.billedAddress.street.length) {
                    _cell.profileTextView.text = address.billedAddress.street;
                }
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
            _cell.dropDownTitleLabel.text = @"Shipping State";
            _cell.textFieldTitleLabel.text = @"Shipping City";
            _cell.textField.keyboardType = UIKeyboardTypeDefault;
            _cell.textField.delegate = self;
            _cell.dropDownTextField.delegate = self;
            _cell.dropDownTextField.text = @"";
            _cell.textField.text = @"";
            if (indexPath.section == 0) {
                self.cityTextField = _cell.textField;
                self.stateTextField = _cell.dropDownTextField;
                if (address.shipAddress.region.length) {
                    _cell.dropDownTextField.text = address.shipAddress.region;
                }
                if(address.shipAddress.city.length){
                    _cell.textField.text = address.shipAddress.city;
                }
            }
            else {
                self.billingCityTextField = _cell.textField;
                self.billingStateTextField = _cell.dropDownTextField;
                if (address.billedAddress.region.length) {
                    _cell.dropDownTextField.text = address.billedAddress.region;
                }
                if(address.billedAddress.city.length){
                    _cell.textField.text = address.billedAddress.city;
                }
            }
            cell = _cell;
            break;
        }
        case 4:
        {
            NSString *cellIdentifier = @"dropDownCell";
            STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.delegate = self;
            _cell.indexPath = indexPath;
            _cell.dropDownTextField.tag = indexPath.row;
            _cell.dropDownTitleLabel.text = @"Shipping Country";
            _cell.textFieldTitleLabel.text = @"Shipping Postal Code";
            _cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            _cell.textField.delegate = self;
            _cell.dropDownTextField.delegate = self;
            _cell.dropDownTextField.text = @"";
            _cell.textField.text = @"";
            if (indexPath.section == 0) {
                self.postalCodeTextField = _cell.textField;
                self.countryextField = _cell.dropDownTextField;
                if (address.shipAddress.country_id.length) {
                    _cell.dropDownTextField.text = selectedCountryDict[@"country_id"][@"__text"];
                }
                if (address.shipAddress.postcode.length) {
                    _cell.textField.text = address.shipAddress.postcode;
                }
            }
            else {
                self.billingPostalCodeTextField = _cell.textField;
                self.billingCountryextField = _cell.dropDownTextField;
                if (address.billedAddress.country_id.length) {
                    _cell.dropDownTextField.text = billingSelectedCountryDict[@"country_id"][@"__text"];
                }
                if (address.billedAddress.postcode.length) {
                    _cell.textField.text = address.billedAddress.postcode;
                }
            }
            cell = _cell;
            break;
        }
        case 5:
        {
            NSString *cellIdentifier = @"textFieldCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextFieldTitleLabel.text = @"Shipping Email";
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.text = @"";
            if (indexPath.section == 0) {
                self.emailTextField = _cell.profileTextField;
                if (address.shipAddress.email.length) {
                    _cell.profileTextField.text = address.shipAddress.email;
                }
            }else {
                self.billingEmailTextField = _cell.profileTextField;
                if (address.billedAddress.email.length) {
                    _cell.profileTextField.text = address.billedAddress.email;
                }
            }
            cell = _cell;
            break;
        }
        case 6:
        {
            NSString *cellIdentifier = @"phoneNumberCell";
            STPhoneNumberTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.titleLabel.text = @"Shipping Phone";
            _cell.phoneCountryCodeTextBox.text = @"+91";
            _cell.phoneTextField.delegate = self;
            _cell.phoneTextField.text = @"";
            if (indexPath.section == 0) {
                self.phoneTextField = _cell.phoneTextField;
                if (address.shipAddress.telephone.length) {
                    _cell.phoneTextField.text = address.shipAddress.telephone;
                }
            }
            else {
                self.billingPhoneTextField = _cell.phoneTextField;
                if (address.billedAddress.telephone.length) {
                    _cell.phoneTextField.text = address.billedAddress.telephone;
                }
            }
            cell = _cell;
            break;
        }
        case 7:
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
            else if (indexPath.section == 1)
            {
                cell = [[UITableViewCell alloc] init];
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
    NSString *titleStr = @"";
    footerView.titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    footerView.titleImageView.image = [UIImage imageNamed:@"Shipping details_Logo"];
    if (section == 1) {
        titleStr = @"";
        footerView.titleImageView.image = [UIImage imageNamed:@"billing address_title"];
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
        if (self.tableView.numberOfSections == 2) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        //        [self.paymentBtn setTitle:@"Proceed to Payments" forState:UIControlStateNormal];
    }
    else {
        [checkBoxCell.firstRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
        [checkBoxCell.secondRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
        self.isShippingISBillingAddress = NO;
        [self.tableView reloadData];
        if (self.tableView.numberOfSections == 1) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        //        [self.paymentBtn setTitle:@"Next" forState:UIControlStateNormal];
    }
    address.isBillingIsShipping = self.isShippingISBillingAddress;
    [self.tableView endUpdates];
}
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    popoverViewController.parentIndexPath = indexPath;
    [STUtility startActivityIndicatorOnView:self.view withText:@"Fetching states."];
    switch (indexPath.section) {
        case 0: // Shipping
        {
            self.isBillingAddress = NO;
            switch (sender.tag) {
                case 3: // States
                {
                    if (selectedCountryDict) {
                        NSDictionary *tempSelectedCountryDict = selectedCountryDict;
                        NSString *countryCode = tempSelectedCountryDict[@"country_id"][@"__text"];
                        NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kRegionList_key(countryCode)];
                        if (!dataDict) {
                            [self performSelector:@selector(fetchStatesForCountry:)
                                       withObject:countryCode
                                       afterDelay:0.5];
//                            [self fetchStatesForCountry:countryCode];
                        }
                        else {
                            [self performSelector:@selector(parseRegionListMethodResponseWithDict:)
                                       withObject:dataDict
                                       afterDelay:0.5];
//                            [self parseRegionListMethodResponseWithDict:dataDict];
                        }
                    }
                    else {
                        [STUtility stopActivityIndicatorFromView:nil];
                        [[[UIAlertView alloc] initWithTitle:@"Message!"
                                                    message:@"Please select valid country."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil] show];
                    }
                    break;
                }
                case 4: // Country
                {
                    NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kCountyList_key];
                    if (!dataDict) {
                        [self performSelector:@selector(fetchCountryList)
                                   withObject:nil
                                   afterDelay:0.5];
//                        [self fetchCountryList];
                    }
                    else {
                        [self performSelector:@selector(parseCountriesMethodResponseWithDict:)
                                   withObject:dataDict
                                   afterDelay:0.5];
//                        [self parseCountriesMethodResponseWithDict:dataDict];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: // Billing
        {
            self.isBillingAddress = YES;
            switch (sender.tag) {
                case 3: // States
                {
                    if (billingSelectedCountryDict) {
                        NSDictionary *tempSelectedCountryDict = billingSelectedCountryDict;
                        NSString *countryCode = tempSelectedCountryDict[@"country_id"][@"__text"];
                        NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kRegionList_key(countryCode)];
                        if (!dataDict) {
                            [self performSelector:@selector(fetchStatesForCountry:)
                                       withObject:countryCode
                                       afterDelay:0.5];
//                            [self fetchStatesForCountry:countryCode];
                        }
                        else {
                            [self performSelector:@selector(parseRegionListMethodResponseWithDict:)
                                       withObject:dataDict
                                       afterDelay:0.5];
//                            [self parseRegionListMethodResponseWithDict:dataDict];
                        }
                    }
                    else {
                        [STUtility stopActivityIndicatorFromView:nil];
                        [[[UIAlertView alloc] initWithTitle:@"Message!"
                                                    message:@"Please select valid country."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil] show];
                    }
                    break;
                }
                case 4: // Countries
                {
                    NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kCountyList_key];
                    if (!dataDict) {
                        [self performSelector:@selector(fetchCountryList) withObject:nil afterDelay:0.5];
//                        [self fetchCountryList];
                    }
                    else {
                        [self performSelector:@selector(parseCountriesMethodResponseWithDict:)
                                   withObject:dataDict
                                   afterDelay:0.5];
//                        [self parseCountriesMethodResponseWithDict:dataDict];
                    }
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
    
    _statesPopover = popoverViewController.popoverPresentationController;
    _statesPopover.sourceView = sender;
    _statesPopover.sourceRect = sender.rightView.frame;
    _statesPopover.delegate = self;
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark-
#pragma STPopoverTableViewControllerDelegate

- (void)itemDidSelect:(NSIndexPath *)indexpath selectedItemString:(NSString *)selectedItemStr parentIndexPath:(NSIndexPath *)pIndexPath{
    if (selectedItemStr.length) {
        
        id view =  _statesPopover.sourceView;
        if ([view isEqual:self.countryextField] || [view isEqual:self.billingCountryextField]) {
            if (pIndexPath.section == 0) {
                self.countryextField.text = selectedItemStr;
            }
            else {
                self.billingCountryextField.text = selectedItemStr;
            }
            NSDictionary *datadict = self.listOfCountries[indexpath.row];
            if (pIndexPath.section == 0) {
                selectedCountryDict = datadict;
            }
            else {
                billingSelectedCountryDict = datadict;
            }
        }
        else if ([view isEqual:self.stateTextField] || [view isEqual:self.billingStateTextField]) {
            if (pIndexPath.section == 0) {
                selectedStatesIdxForShipping = indexpath.row;
                self.stateTextField.text = selectedItemStr;
            }
            else {
                selectedStatesIdxForBilling = indexpath.row;
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
- (NSString *)trimmedStateCode:(NSString *)rawStateCode {
    NSString *stateCodestr;
    if (rawStateCode.length) {
        NSArray *stateCodeComponenets = [rawStateCode componentsSeparatedByString:@"-"];
        if (stateCodeComponenets.count > 1) {
            stateCodestr = stateCodeComponenets[1];
        }
    }
    return stateCodestr;
}
- (void)setAddress {
    
    if (self.isShippingISBillingAddress) {
        
        NSString *firstNameStr = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastNameStr = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addressStr = [self.addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cityStr = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stateStr =  self.listOfStatesForSelectedCountryForShipping[selectedStatesIdxForShipping][@"name"][@"__text"];
        NSLog(@"Selected State Code :-  %@",stateStr);
        stateStr = stateStr?stateStr:[self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *postalCodeStr = [self.postalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *countryStr = selectedCountryDict ? selectedCountryDict[@"country_id"][@"__text"] : [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        countryStr = countryStr?countryStr:[self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        address.shipAddress.firstname = firstNameStr;
        address.shipAddress.lastname = lastNameStr;
        address.shipAddress.city = cityStr;
        address.shipAddress.region = stateStr;
        address.shipAddress.postcode = postalCodeStr;
        address.shipAddress.country_id = countryStr;
        address.shipAddress.email = emailStr;
        address.shipAddress.telephone = phoneStr;
        address.shipAddress.street = addressStr;
        address.shipAddress.region_id = self.listOfStatesForSelectedCountryForShipping[selectedStatesIdxForShipping][@"region_id"][@"__text"];
    }
    else {
        NSString *firstNameStr = [self.billingFirstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastNameStr = [self.billingLastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *addressStr = [self.billingAddressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cityStr = [self.billingCityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *stateStr =  self.listOfStatesForSelectedCountryForBilling[selectedStatesIdxForShipping][@"name"][@"__text"];
        NSLog(@"Selected State Code :-  %@",stateStr);
        stateStr = stateStr?stateStr:[self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        stateStr = stateStr?stateStr:[self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *postalCodeStr = [self.billingPostalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *countryStr = selectedCountryDict ? selectedCountryDict[@"country_id"][@"__text"] : [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        countryStr = countryStr?countryStr:[self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailStr = [self.billingEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *phoneStr = [self.billingPhoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //        NSString *couponCodeStr = [self.couponCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
       
        address.shipAddress.firstname = firstNameStr;
        address.billedAddress.lastname = lastNameStr;
        address.billedAddress.city = cityStr;
        address.billedAddress.region = stateStr;
        address.billedAddress.postcode = postalCodeStr;
        address.billedAddress.country_id = countryStr;
        address.billedAddress.email = emailStr;
        address.billedAddress.telephone = phoneStr;
        address.billedAddress.street = addressStr;
        address.billedAddress.region_id = self.listOfStatesForSelectedCountryForBilling[selectedStatesIdxForBilling][@"region_id"][@"__text"];
        //        address.billedAddress.couponCode = couponCodeStr;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (self.isShippingISBillingAddress) {
        
        address.shipAddress.region_id = self.listOfStatesForSelectedCountryForShipping[selectedStatesIdxForShipping][@"region_id"][@"__text"];
        
        if ([textField isEqual:self.firstNameTextField]) {
            NSString *firstNameStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.firstname = firstNameStr;
        }
        else if([textField isEqual:self.lastNameTextField])
        {
            NSString *lastNameStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.lastname = lastNameStr;
        }
        else if([textField isEqual:self.cityTextField])
        {
            NSString *cityStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.city = cityStr;
        }
        else if([textField isEqual:self.stateTextField])
        {
            NSString *stateStr =  self.listOfStatesForSelectedCountryForShipping[selectedStatesIdxForShipping][@"name"][@"__text"];
            stateStr = stateStr?stateStr:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.region = stateStr;
        }
        else if([textField isEqual:self.postalCodeTextField])
        {
         NSString *postalCodeStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.postcode = postalCodeStr;
        }
        else if([textField isEqual:self.countryextField])
        {
            NSString *countryStr = selectedCountryDict ? selectedCountryDict[@"country_id"][@"__text"] : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            countryStr = countryStr?countryStr:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.country_id = countryStr;
        }
        else if([textField isEqual:self.emailTextField])
        {
            NSString *emailStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.email = emailStr;
        }
        else if([textField isEqual:self.phoneTextField])
        {
            NSString *phoneStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.telephone = phoneStr;
        }
//        else if([textField isEqual:self.addressTextView])
//        {
//            
//        }
        
    }
    else {
        address.billedAddress.region_id = self.listOfStatesForSelectedCountryForBilling[selectedStatesIdxForBilling][@"region_id"][@"__text"];
        //        address.billedAddress.couponCode = couponCodeStr;
        if ([textField isEqual:self.firstNameTextField]) {
            NSString *firstNameStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.firstname = firstNameStr;
        }
        else if([textField isEqual:self.lastNameTextField])
        {
            NSString *lastNameStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.lastname = lastNameStr;
        }
        else if([textField isEqual:self.cityTextField])
        {
            NSString *cityStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.city = cityStr;
        }
        else if([textField isEqual:self.stateTextField])
        {
            NSString *stateStr =  self.listOfStatesForSelectedCountryForBilling[selectedStatesIdxForBilling][@"name"][@"__text"];
            stateStr = stateStr?stateStr:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.region = stateStr;
        }
        else if([textField isEqual:self.postalCodeTextField])
        {
            NSString *postalCodeStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.postcode = postalCodeStr;
        }
        else if([textField isEqual:self.countryextField])
        {
            NSString *countryStr = billingSelectedCountryDict ? billingSelectedCountryDict[@"country_id"][@"__text"] : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            countryStr = countryStr?countryStr:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.country_id = countryStr;
        }
        else if([textField isEqual:self.emailTextField])
        {
            NSString *emailStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.email = emailStr;
        }
        else if([textField isEqual:self.phoneTextField])
        {
            NSString *phoneStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.telephone = phoneStr;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.tableView.numberOfSections == 2) {
        if (textField == _phoneTextField || textField == _billingPhoneTextField || textField == _postalCodeTextField || textField == _billingPostalCodeTextField) {
            if(range.length + range.location > textField.text.length)
            {
                return NO;
            }
            
            NSUInteger newLength = [textField.text length] + [string length] - range.length;
            return newLength <= 10;
        }
    }else{
        if (textField == _phoneTextField ||  textField == _postalCodeTextField) {
            if(range.length + range.location > textField.text.length)
            {
                return NO;
            }
            
            NSUInteger newLength = [textField.text length] + [string length] - range.length;
            return newLength <= 10;
        }
    }
    
    
    return YES;
}


#pragma mark -
#pragma UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {

}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.isShippingISBillingAddress) {
        if ([textView isEqual:self.addressTextView]) {
            NSString *addressStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.shipAddress.street = addressStr;
        }
    }
    else {
        if ([textView isEqual:self.billingAddressTextView]) {
            NSString *addressStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            address.billedAddress.street = addressStr;
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark-
#pragma STPlaceOrderDelegate
- (void)orderResultWithId:(NSString *)orderId {
    if (orderId.length) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:orderId forKey:kOderId_Key];
        [self proceedForPayment];
    }
    else {
        dbLog(@"In valid order id. ");
    }
}

- (void)fetchCountryList {
    
    if ([STUtility isNetworkAvailable]) {
        [STUtility startActivityIndicatorOnView:self.view withText:@"Fetching Countries."];
        NSString *requestBody = [STConstants countryListRequestBody];
        //        dbLog(@"Countries list: %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){
                                                           }
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-fetchCountryList:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"Countries list xml: %@",xmlString);
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
            dbLog(@"Countries list %@",xmlDic);
            [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic withKey:kCountyList_key];
            [self parseCountriesMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}
- (void)parseCountriesMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSArray *dataArr = parentDataDict[@"ns1:directoryCountryListResponse"][@"countries"][@"item"];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name.__text" ascending:YES];
            
            self.listOfCountries = [dataArr sortedArrayUsingDescriptors:@[sort]];
            popoverViewController.itemsArray = self.listOfCountries;
            
            [self presentViewController:popoverViewController animated:YES completion:nil];
//            [popoverViewController.tableView reloadData];
        }
        else {
            dbLog(@"Error placing order...");
        }
    }else {
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)fetchStatesForCountry:(NSString *)countryCode {
    
    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants regionListequestBodyForCountry:countryCode];
        dbLog(@"States list: %@ for country %@",requestBody, countryCode);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){
                                                           }
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-fetchCountryList:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"States list xml: %@ for country %@",xmlString,countryCode);
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
            dbLog(@"States list %@ for country %@",xmlDic, countryCode);
            [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic withKey:kRegionList_key(countryCode)];
            [self parseRegionListMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}
- (void)parseRegionListMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSArray *dataArr = parentDataDict[@"ns1:directoryRegionListResponse"][@"countries"][@"item"];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name.__text" ascending:YES];
            if (self.isBillingAddress) {
                self.listOfStatesForSelectedCountryForBilling = [dataArr sortedArrayUsingDescriptors:@[sort]];
                popoverViewController.itemsArray = self.listOfStatesForSelectedCountryForBilling;
            }
            else {
                self.listOfStatesForSelectedCountryForShipping = [dataArr sortedArrayUsingDescriptors:@[sort]];
                popoverViewController.itemsArray = self.listOfStatesForSelectedCountryForShipping;
            }
            if (popoverViewController.itemsArray.count) {
             [self presentViewController:popoverViewController animated:YES completion:nil];
            }
            else {
                [STUtility stopActivityIndicatorFromView:nil];
                [self showAlertWithTitle:@"Message!" msg:@"No states foung for selected country."];
            }
            //            [popoverViewController.tableView reloadData];
        }
        else {
            dbLog(@"Error fetching region list order...");
        }
    }else {
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
@end
