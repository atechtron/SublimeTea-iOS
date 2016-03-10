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

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "MRMSiOS.h"
#import "PaymentModeViewController.h"


@interface STShippingDetailsViewController ()<UITableViewDataSource, UITableViewDelegate, STDropDownTableViewCellDeleagte, STPopoverTableViewControllerDelegate, UIPopoverPresentationControllerDelegate>
{
    NSArray *listOfStates;
    NSMutableDictionary *jsondict;
}

@property(nonatomic,retain)UIPopoverPresentationController *statesPopover;

@property(weak,nonatomic) UITextField *nameTextField;
@property(weak,nonatomic) UITextView *addressTextView;
@property(weak,nonatomic) UITextField *cityTextField;
@property(weak,nonatomic) UITextField *stateTextField;
@property(weak,nonatomic) UITextField *postalCodeTextField;
@property(weak,nonatomic) UITextField *countryextField;
@property(weak,nonatomic) UITextField *emailTextField;
@property(weak,nonatomic) UITextField *phoneTextField;
@property(nonatomic) BOOL isShippingISBillingAddress;

@end

@implementation STShippingDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}
- (void)viewWillAppear:(BOOL)animated {
    
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
    
    paymentView.strBillingName = self.nameTextField.text;
    paymentView.strBillingAddress = self.addressTextView.text;
    paymentView.strBillingCity = self.cityTextField.text;
    paymentView.strBillingState = self.stateTextField.text;
    paymentView.strBillingPostal = self.postalCodeTextField.text;
    paymentView.strBillingCountry = self.countryextField.text;
    paymentView.strBillingEmail = self.emailTextField.text;
    paymentView.strBillingTelephone = self.phoneTextField.text;
    
    paymentView.strDeliveryName = self.nameTextField.text;
    paymentView.strDeliveryAddress = self.addressTextView.text;
    paymentView.strDeliveryCity = self.cityTextField.text;
    paymentView.strDeliveryState = self.stateTextField.text;
    paymentView.strDeliveryPostal = self.postalCodeTextField.text;
    paymentView.strDeliveryCountry = self.countryextField.text;
    paymentView.strDeliveryTelephone = self.phoneTextField.text;
    
    
    //If you want to add any extra parameters dynamically you have to add the Key and value as we //mentioned below
    //        [dynamicKeyValueDictionary setValue:@"savings" forKey:@"account_detail"];
    //        [dynamicKeyValueDictionary setValue:@"gold" forKey:@"merchant_type"];
    //      paymentView.dynamicKeyValueDictionary = dynamicKeyValueDictionary;
    
    [self.navigationController pushViewController:paymentView animated:NO];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
        {
            NSString *cellIdentifier = @"textFieldCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextFieldTitleLabel.text = @"Name";
            self.nameTextField = _cell.profileTextField;;
            cell = _cell;
            break;
        }
        case 1:
        {
            NSString *cellIdentifier = @"textViewCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextViewTitleLabel.text = @"Shipping Address";
            self.addressTextView = _cell.profileTextView;
            cell = _cell;
            break;
        }
        case 2:
        {
            NSString *cellIdentifier = @"dropDownCell";
            STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.delegate = self;
            _cell.dropDownTitleLabel.text = @"Shipping State";
            _cell.textFieldTitleLabel.text = @"Shipping City";
            self.cityTextField = _cell.textField;
            self.stateTextField = _cell.dropDownTextField;
            cell = _cell;
            break;
        }
        case 3:
        {
            NSString *cellIdentifier = @"dropDownCell";
            STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.delegate = self;
            _cell.dropDownTitleLabel.text = @"Shipping Country";
            _cell.textFieldTitleLabel.text = @"Shipping Postal Code";
            self.postalCodeTextField = _cell.textField;
            self.countryextField = _cell.dropDownTextField;
            cell = _cell;
            break;
        }
        case 4:
        {
            NSString *cellIdentifier = @"textFieldCell";
            STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.profileTextFieldTitleLabel.text = @"Shipping Email";
            self.emailTextField = _cell.profileTextField;
            cell = _cell;
            break;
        }
        case 5:
        {
            NSString *cellIdentifier = @"phoneNumberCell";
            STPhoneNumberTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.titleLabel.text = @"Shipping Phone";
            _cell.phoneCountryCodeLabel.text = @"+91";
            self.phoneTextField = _cell.phoneTextField;
            cell = _cell;
            break;
        }
        case 6:
        {
            NSString *cellIdentifier = @"checkBoxButtonCell";
            STDropDownTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            _cell.delegate = self;
            _cell.firstradioButtonTitlrLabel.text = @"Use my shipping address as my billing address";
            _cell.secondRadioButtonTtitleLabel.text = @"Ship to different address";
            [_cell.firstRadioButton setImage:[UIImage imageNamed:@"checkboxSelected"] forState:UIControlStateNormal];
            cell = _cell;
            break;
        }
            
        default:
            break;
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    footerView.titleLabel.text = @"Shipping Details";
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
    
    UIImage *unselectedCheckBox = [UIImage imageNamed:@"chekboxUnselected"];
    UIImage *selectedCheckBox = [UIImage imageNamed:@"checkboxSelected"];
    STDropDownTableViewCell *checkBoxCell = (STDropDownTableViewCell *)cell;
    if ([checkBox isEqual:checkBoxCell.firstRadioButton] || [checkBox isEqual:checkBoxCell.firstradioButtonTitlrLabel]) {
        [checkBoxCell.secondRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
        [checkBoxCell.firstRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
        self.isShippingISBillingAddress = YES;
    }
    else {
        [checkBoxCell.firstRadioButton setImage:unselectedCheckBox forState:UIControlStateNormal];
        [checkBoxCell.secondRadioButton setImage:selectedCheckBox forState:UIControlStateNormal];
        self.isShippingISBillingAddress = NO;
    }
}
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture {
    
    STPopoverTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STPopoverTableViewController"];
    viewController.modalPresentationStyle = UIModalPresentationPopover;
    _statesPopover = viewController.popoverPresentationController;
    _statesPopover.delegate = self;
    _statesPopover.sourceView = sender;
    _statesPopover.sourceRect = sender.rightView.frame;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark-
#pragma STPopoverTableViewControllerDelegate

- (void)itemDidSelect:(NSIndexPath *)indexpath {
    
}
@end
