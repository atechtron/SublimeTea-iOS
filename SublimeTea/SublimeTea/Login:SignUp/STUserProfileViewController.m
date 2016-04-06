//
//  STUserProfileViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STUserProfileViewController.h"
#import "STPrfileTableViewCell.h"
#import "STOrderListHeaderView.h"
#import "STUtility.h"
#import "STConstants.h"
#import "STHttpRequest.h"
#import "STAddressTableViewCell.h"
#import "STPopoverTableViewController.h"
#import <objc/runtime.h>
#import "STGlobalCacheManager.h"
#import "STPhoneNumberTableViewCell.h"

#define kcityTag 10201
#define kstateTag 20129
#define kpostalCodeTag 319372
#define kcountryTag 422431
#define kstreetAddTag 521421
#define ktelephoneCountryCodeTag 51656
#define ktelephoneTag 521421324

@implementation Address
- (NSInteger)is_default_billing {
    return 0;
}
- (NSInteger)is_default_shipping {
    return 0;
}
- (NSString *)region_id {
    return _region;
}
//- (NSString *)telephone {
//    return @"2332534534";
//}
- (NSDictionary *)dictionary {
    NSMutableArray *propertyKeys = [NSMutableArray array];
    Class currentClass = self.class;
    
    while ([currentClass superclass]) { // avoid printing NSObject's attributes
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if (propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                [propertyKeys addObject:propertyName];
            }
        }
        free(properties);
        currentClass = [currentClass superclass];
    }
    
    return [self dictionaryWithValuesForKeys:propertyKeys];
}
@end

@interface STUserProfileViewController ()<UITableViewDelegate, UITableViewDataSource, STProfileTableViewCellDelegate, UITextFieldDelegate, UITextViewDelegate, STAddressTableViewCellDelegate,STPopoverTableViewControllerDelegate, UIPopoverPresentationControllerDelegate>
{
    NSDictionary *selectedCountryDict;
    UIView *viewToScroll;
    NSString *passwordString;
    STPopoverTableViewController *popoverViewController;
}
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSMutableArray *customerAddressList;
@property (strong, nonatomic)NSMutableDictionary *userInfo;
@property(nonatomic,retain)UIPopoverPresentationController *statesPopover;
@property(strong, nonatomic)NSArray *listOfCountries;
@property(strong, nonatomic)NSArray *listOfStatesForSelectedCountry;

@property (weak, nonatomic)UITextField *firstNameTextField;
@property (weak, nonatomic)UITextField *lastNameTextField;
@property (weak, nonatomic)UITextField *emailTextField;
@property (weak, nonatomic)UITextField *passwordTextField;
@end

@implementation STUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customerAddressList = [NSMutableArray new];
    
    [self prepareData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
    
    popoverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STPopoverTableViewController"];
    popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
    popoverViewController.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated {
    //    [self fetchCustomerAddressList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

- (void)prepareData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userInfo = [defaults objectForKey:kUserInfo_Key];
    if(self.userInfo) {
        NSString *userEmail = self.userInfo[@"email"][@"__text"];
        NSString *userFirstName = self.userInfo[@"firstname"][@"__text"] ? self.userInfo[@"firstname"][@"__text"] :@"";
        NSString *userLastName = self.userInfo[@"lastname"][@"__text"] ? self.userInfo[@"lastname"][@"__text"] :@"";
        
//        NSString *userFullName = [NSString stringWithFormat:@"%@ %@",userFirstName,userLastName];
        
        //    NSString *custId = userInfoDict[@"customer_id"][@"__text"];
        NSDictionary *userFirstNameDict = @{@"firstName": userFirstName};
        NSDictionary *userLastNameDict = @{@"lastName": userLastName};
        NSDictionary *emailDIct = @{@"email": userEmail};
        
        NSArray *tempArr = @[userFirstNameDict,
                             userLastNameDict,
                             emailDIct,
                             @"addAddress",
                             @"changePwdBtn"
                             ];
        self.dataArr = [NSMutableArray arrayWithArray:tempArr];
    }
}

- (void)viewDidTapped:(id)sender {
    //    self.tableView.contentOffset = CGPointMake(0, self.errorLabel.frame.origin.y);
    [self.view endEditing:YES];
}

#pragma mark-
#pragma UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    id obj = self.dataArr[indexPath.row];
    NSString *keyName;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)obj;
        keyName = [dict allKeys][0];
    }
    else if([obj isKindOfClass:[NSString class]]){
        keyName = (NSString *)obj;
    }
    if ([keyName isEqualToString:@"firstName"] || [keyName isEqualToString:@"lastName"] || [keyName isEqualToString:@"email"] || [keyName isEqualToString:@"changePwdTxtField"])
    {
        static NSString *cellIdentifier = @"textFieldCell";
        STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        _cell.profileTextField.delegate = self;
        if ([keyName isEqualToString:@"firstName"]) {
            _cell.profileTextFieldTitleLabel.text = @"First Name";
            _cell.profileTextField.text = obj[keyName];
            _cell.profileTextField.keyboardType = UIKeyboardTypeAlphabet;
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.tag = indexPath.row;
            self.firstNameTextField = _cell.profileTextField;
        }
        else if ([keyName isEqualToString:@"lastName"]) {
            _cell.profileTextFieldTitleLabel.text = @"Last Name";
            _cell.profileTextField.text = obj[keyName];
            _cell.profileTextField.keyboardType = UIKeyboardTypeAlphabet;
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.tag = indexPath.row;
            self.lastNameTextField = _cell.profileTextField;
        }
        else if([keyName isEqualToString:@"email"]) {
            _cell.profileTextFieldTitleLabel.text = @"Email id";
            _cell.profileTextField.text = obj[keyName];
            _cell.profileTextField.keyboardType = UIKeyboardTypeEmailAddress;
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.tag = indexPath.row;
            self.emailTextField = _cell.profileTextField;
        }
        else {
            _cell.profileTextFieldTitleLabel.text = @"Change Password";
            _cell.profileTextField.secureTextEntry = YES;
            _cell.profileTextField.keyboardType = UIKeyboardTypeDefault;
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.tag = indexPath.row;
            self.passwordTextField = _cell.profileTextField;
        }
        cell = _cell;
    }
    else if ([keyName isEqualToString:@"address"])
    {
        static NSString *cellIdentifier = @"textViewCell";
        STAddressTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        _cell.addressTextView.delegate = self;
        _cell.indexPath = indexPath;
        _cell.delegate = self;
        _cell.addressTextView.keyboardType = UIKeyboardTypeDefault;
        
        _cell.cityTextField.tag = kcityTag;
        _cell.cityTextField.delegate = self;
        _cell.stateTextField.tag = kstateTag;
        _cell.stateTextField.delegate = self;
        _cell.postalCodeTextField.tag = kpostalCodeTag;
        _cell.postalCodeTextField.delegate = self;
        _cell.countryTextField.tag = kcountryTag;
        _cell.countryTextField.delegate = self;
        _cell.addressTextView.tag = kstreetAddTag;
        _cell.addressTextView.delegate = self;
        _cell.titleLabel.text = @"Phone Number";
        _cell.phoneCountryCodeTextBox.tag = ktelephoneCountryCodeTag;
        _cell.phoneCountryCodeTextBox.delegate = self;
        _cell.phoneTextField.tag = ktelephoneTag;
        _cell.phoneTextField.delegate = self;
        
        //        _cell.countryTextField.text = @"IT";
        //        _cell.postalCodeTextField.text = @"31056";
        //        _cell.stateTextField.text = @"TV";
        //        _cell.cityTextField.text = @"Treviso";
        
        if (indexPath.row == 2) {
            _cell.addressTextViewTitleLabel.text = @"My Addresses";
        }
        else {
            _cell.addressTextViewTitleLabel.text = @"";
        }
        
        cell = _cell;
    }
    else if ([keyName isEqualToString:@"addAddress"] || [keyName isEqualToString:@"changePwdBtn"])
    {
        static NSString *cellIdentifier = @"buttonCell";
        STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        _cell.delegate = self;
        _cell.currentIndexPath = indexPath;
        if ([keyName isEqualToString:@"addAddress"]) {
            [_cell.profileButton setTitle:@"Add Addresses" forState:UIControlStateNormal];
            [_cell.profileButton setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
            _cell.tag = kAddAddressBtnCellTag;
        }
        else {
            [_cell.profileButton setTitle:@"Change Password" forState:UIControlStateNormal];
            [_cell.profileButton setImage:[UIImage imageNamed:@"edit_icon"] forState:UIControlStateNormal];
            _cell.tag = kChangePwdBtnCellTag;
        }
        
        cell = _cell;
        
    }
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 44;
    id obj = self.dataArr[indexPath.row];
    NSString *keyName;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)obj;
        keyName = [dict allKeys][0];
    }
    else if([obj isKindOfClass:[NSString class]]){
        keyName = (NSString *)obj;
    }
    if ([keyName isEqualToString:@"firstName"] || [keyName isEqualToString:@"lastName"] || [keyName isEqualToString:@"email"] || [keyName isEqualToString:@"phone"] || [keyName isEqualToString:@"changePwdTxtField"])
    {
        rowHeight = 89;
    }
    else if ([self.dataArr[indexPath.row] isEqualToString:@"address"])
    {
        rowHeight = 308;
    }
    else if ([self.dataArr[indexPath.row] isEqualToString:@"addAddress"] || [self.dataArr[indexPath.row] isEqualToString:@"changePwdBtn"])
    {
        rowHeight = 57;
    }
    return rowHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    footerView.titleLabel.text = @"Profile";
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 62;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
#pragma mark-
#pragma STProfileTableViewCellDelegate

- (void)addNewAddressesAtIndexPath:(NSIndexPath *)indexPath {
    if(self.dataArr.count == 5)
    {
        [self.dataArr insertObject:@"address" atIndex:indexPath.row];
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                     inSection:indexPath.section];
        [self.tableView insertRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSIndexPath *addressBtnIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1
                                                              inSection:indexPath.section];
        NSIndexPath *editPwdBtnIndexPath = [NSIndexPath indexPathForRow:indexPath.row+2
                                                              inSection:indexPath.section];
        [self.tableView reloadRowsAtIndexPaths:@[addressBtnIndexPath,editPwdBtnIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:indexPath.row+1
                                                  inSection:indexPath.section];
        [self.tableView scrollToRowAtIndexPath:idxPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}
- (void)editPasswordAtIndexPath:(NSIndexPath *)indexPath {
    [self.dataArr replaceObjectAtIndex:indexPath.row withObject:@"changePwdTxtField"];
    //    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //    [self.dataArr addObject:@"changePwdTxtField"];
    
    NSIndexPath *addressBtnIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1
                                                          inSection:indexPath.section];
    [self.tableView reloadRowsAtIndexPaths:@[addressBtnIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}
- (BOOL)validateAdress:(Address *)add {
    //customerAddressList
    BOOL status = NO;
    NSString *streetAdd = add.street.count? add.street[0]:nil;
    if (add.firstname.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"First Name is required!"];
    }
    else if (add.lastname.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Last Name is required!"];
    }
    else if (add.telephone.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Phone Number is required!"];
    }
    else if (add.city.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"City is required!"];
    }
    else if (add.country_id.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Country is required!"];
    }
    else if (add.postcode.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Postal Code is required!"];
    }
    else if (add.region.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"State is required!"];
    }
    else if (streetAdd.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Street is required!"];
    }
    else
    {
        status = YES;
    }
    return status;
}
#pragma mark-
#pragma UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UIView *superView = textField.superview.superview.superview;
    if ([superView isKindOfClass:[STAddressTableViewCell class]]) {
        STAddressTableViewCell *cell = (STAddressTableViewCell *)superView;
        if (textField == cell.phoneTextField) {
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
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    viewToScroll = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    viewToScroll = nil;
    UIView *superView = textField.superview.superview;
    superView = [superView isKindOfClass:[STAddressTableViewCell class]]?superView:textField.superview.superview.superview;
    dbLog(@"%@",superView);
    if ([superView isKindOfClass:[STAddressTableViewCell class]]) {
        STAddressTableViewCell *cell = (STAddressTableViewCell *)superView;
        NSUInteger idx = cell.indexPath.row;
        if (idx != NSNotFound) {
            NSInteger idxToStore = idx-3;
            if (idxToStore >= 0)
            {
                NSString *textStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSString *firstNameStr = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *lastNameStr = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *telephoneStr = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                
                Address *address = (self.customerAddressList.count == 0)? [[Address alloc] init] : self.customerAddressList[idxToStore];
                address.firstname = firstNameStr;
                address.lastname = lastNameStr;
//                address.telephone = telephoneStr;
                
                switch (textField.tag) {
                    case kcityTag:
                    {
                        address.city = textStr;
                    }
                        break;
                    case kstateTag:
                    {
                        address.region = textStr;
                    }
                        break;
                    case kpostalCodeTag:
                    {
                        address.postcode = textStr;
                    }
                        break;
                    case kcountryTag:
                    {
                        address.country_id = textStr;
                    }
                    case ktelephoneTag:
                        address.telephone = textStr;
                        break;
                        
                    default:
                        break;
                }
                if (self.customerAddressList.count > idxToStore ) {
                    [self.customerAddressList replaceObjectAtIndex:idxToStore withObject:address];
                }
                else {
                    [self.customerAddressList addObject:address];
                }
            }
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

#pragma mark-
#pragma UITextView Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIView *superView = textField.superview.superview;
    dbLog(@"%@",superView);
    if (textField.tag == kstateTag) {
        if ([superView isKindOfClass:[STAddressTableViewCell class]]) {
            STAddressTableViewCell *cell = (STAddressTableViewCell *)superView;
            
            [self droDownAction:textField tapGesture:nil indexPath:cell.indexPath];
        }
        
        return NO;
    }
    else if (textField.tag == kcountryTag) {
        if ([superView isKindOfClass:[STAddressTableViewCell class]]) {
            STAddressTableViewCell *cell = (STAddressTableViewCell *)superView;
            [self droDownAction:textField tapGesture:nil indexPath:cell.indexPath];
        }
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    viewToScroll = textView;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    viewToScroll = nil;
    UIView *superView = textView.superview.superview;
    dbLog(@"%@",superView);
    if ([superView isKindOfClass:[STAddressTableViewCell class]]) {
        STAddressTableViewCell *cell = (STAddressTableViewCell *)superView;
        NSUInteger idx = cell.indexPath.row;
        if (idx != NSNotFound) {
            NSInteger idxToStore = idx-3;
            if (idxToStore >= 0)
            {
                NSString *firstNameStr = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *lastNameStr = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *telephoneStr = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSString *textStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                Address *address = (self.customerAddressList.count == 0)? [[Address alloc] init] : self.customerAddressList[idxToStore];
                address.firstname = firstNameStr;
                address.lastname = lastNameStr;
//                address.telephone = telephoneStr;
                
                switch (textView.tag) {
                    case kstreetAddTag:
                    {
                        address.street = @[textStr];
                    }
                        break;
                        
                    default:
                        break;
                }
                if (self.customerAddressList.count > idxToStore ) {
                    dbLog(@"%@",self.customerAddressList);
                    [self.customerAddressList replaceObjectAtIndex:idxToStore withObject:address];
                }
                else {
                    [self.customerAddressList addObject:address];
                }
            }
        }
    }
}

#pragma mark-
#pragma UIKeyboard Notification Selector

-(void) keyboardWillShow:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
    
    // Start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height -= keyboardBounds.size.height;
    else
        frame.size.height -= keyboardBounds.size.width;
    
    // Apply new size of table view
    self.tableView.frame = frame;
    
    // Scroll the table view to see the TextField just above the keyboard
    if (viewToScroll)
    {
        CGRect textFieldRect = [self.tableView convertRect:viewToScroll.bounds fromView:viewToScroll];
        [self.tableView scrollRectToVisible:textFieldRect animated:NO];
    }
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Increase size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height += keyboardBounds.size.height;
    else
        frame.size.height += keyboardBounds.size.width;
    
    // Apply new size of table view
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}
- (IBAction)ordersButtonAction:(UIButton *)sender {
}

- (IBAction)saveChangesButtonAction:(UIButton *)sender {
    [self.tableView endEditing:YES];
    
    if ([STUtility isNetworkAvailable] && self.userInfo && [self validateName:self.firstNameTextField.text lastName:self.lastNameTextField.text  emailID:self.emailTextField.text]) {
        NSString *custId = self.userInfo[@"customer_id"][@"__text"];
        NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//self.userInfo[@"email"][@"__text"];
        
        NSString *pwdStr = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *firstNameStr = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastNameStr = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
//        NSString *telephoneStr = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet 3whitespaceAndNewlineCharacterSet]];
        
        NSString *requestBody = [STConstants userInfoRequstBodyWithCustomerId:[custId integerValue]
                                                                customerEmail:emailStr
                                                                    firstName:firstNameStr
                                                                     lastName:lastNameStr
                                                                     password:pwdStr];
        dbLog(@"User account : %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STUserProfileViewController-saveChangesButtonAction:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"User account xml : %@",xmlString);
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
            dbLog(@"User account : %@",xmlDic);
            [self parseUserInfoUpdateMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)parseUserInfoUpdateMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *responseDict = parentDataDict[@"ns1:customerCustomerUpdateResponse"][@"result"];
            BOOL requestStatus = [responseDict[@"__text"] boolValue];
            if (requestStatus) {// UserInfo updated sucessfully
                [self customerAddressUpdate];;
            }
        }
        else {
            dbLog(@"Error updating user info...");
        }
    }else {
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)fetchCustomerAddressList {
    
    if ([STUtility isNetworkAvailable] && self.userInfo) {
        [STUtility startActivityIndicatorOnView:nil withText:@""];
        
        NSString *requestBody = [STConstants customerAddressListRequestBody];
        
        dbLog(@"Customer Address List : %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-fetchCustomerAddressList:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"Customer Address List xml : %@",xmlString);
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
            dbLog(@"Customer Address List : %@",xmlDic);
            
            [self parseCustomerAddressListMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    [STUtility stopActivityIndicatorFromView:nil];
}

- (void)parseCustomerAddressListMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartShippingMethodResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            
            dbLog(@"Error setting shipping method cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}
-(void)getUserList {
    
    NSString *requestBody = [STConstants customerListReuestBody];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                      dbLog(@"%@",xmlDic);
                                      [self parseUserListResponseWithDict:xmlDic];
                                      
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      dbLog(@"SublimeTea-STSignUpViewController-userLogIn:- %@",error);
                                  }];
    
    [httpRequest start];
}
- (void)parseUserListResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSArray *userList = responseDict[@"SOAP-ENV:Body"][@"ns1:customerCustomerListResponse"][@"storeView"][@"item"];
        if (userList.count) {
            NSString *userNameStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"email.__text LIKE %@",userNameStr];
            NSArray *filteredUsersArr = [userList filteredArrayUsingPredicate:filterPredicate];
            if (filteredUsersArr.count) {
                NSDictionary *userInfoDict = filteredUsersArr[0];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:userInfoDict forKey:kUserInfo_Key];
                dbLog(@"User Details: %@",[defaults objectForKey:kUserInfo_Key]);
                [STUtility stopActivityIndicatorFromView:nil];
            }
            else { // Login Failed
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:@"SignUp Failed, Please try after some time."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
            }
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)customerAddressUpdate {
    [self.view endEditing:YES];
    dbLog(@"Adress List: %@",self.customerAddressList);
    if(self.customerAddressList.count == 0) {
        [self getUserList];
        [self showAlertWithTitle:@"Message" msg:@"Changes saved."];
        return;
    }
    BOOL isValid = NO;
    for (Address *add in self.customerAddressList) {
        dbLog(@"Adress: %@",add.firstname);
        dbLog(@"Adress: %@",add.city);
        dbLog(@"Adress: %@",add.street);
        dbLog(@"Adress: %@",add.country_id);
        dbLog(@"Adress: %@",add.postcode);
        dbLog(@"Adress: %@",add.region);
        dbLog(@"Phone: %@",add.telephone);
        
        if ([self validateAdress:add]) {
            isValid = YES;
        }
        else {
            isValid = NO;
            break;
        }
    }
    
    if (isValid) {
        [STUtility startActivityIndicatorOnView:nil withText:@""];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
        NSString *custId = self.userInfo[@"customer_id"][@"__text"];
        NSDictionary *paramDict = @{@"sessionId": sessionId,
                                    @"customerId": custId};
        NSMutableDictionary *soapBodyDict = [NSMutableDictionary new];
        [soapBodyDict addEntriesFromDictionary:paramDict];
        
        NSMutableArray *addArr = [NSMutableArray new];
        for (Address *obj in self.customerAddressList) {
            [addArr addObject:[obj dictionary]];
        }
        
        [soapBodyDict setObject:addArr forKey:kCustomerAddressNodeName];
        
        
        if (soapBodyDict) {
            NSString *requestBody = [STUtility prepareMethodSoapBody:@"customerAddressCreate"
                                                              params:soapBodyDict];
            dbLog(@"User account address: %@",requestBody);
            NSString *urlString = [STConstants getAPIURLWithParams:nil];
            NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                 methodType:@"POST"
                                                                       body:requestBody
                                                        responseHeaderBlock:^(NSURLResponse *response){}
                                                               successBlock:^(NSData *responseData){
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
                                                                       dbLog(@"Customer Address xml: %@",xmlString);
                                                                       NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
                                                                       dbLog(@"Customer Address create result : %@",xmlDic);
                                                                       
                                                                       //        [self parseCustomerAddressListMethodResponseWithDict:xmlDic];
                                                                   });
                                                               }
                                                               failureBlock:^(NSError *error)
                                          {
                                              [STUtility stopActivityIndicatorFromView:nil];
                                              [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                          message:@"Unexpected error has occured, Please try after some time."
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles: nil] show];
                                              dbLog(@"SublimeTea-STPlaceOrder-fetchCustomerAddressList:- %@",error);
                                          }];
            
            
            
            [httpRequest start];
            
            
        }
    }
    
}
- (void)parseCustomerAddressCreateResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:customerAddressCreateResponse"][@"result"];
            if (dataDict) {
                [self showAlertWithTitle:@"Message" msg:@"Changes saved."];
                [self getUserList];
            }
        }
        else {
            dbLog(@"Error saving account details...");
        }
    }else {
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
//- (BOOL)validateInputs {
//    BOOL status = NO;
//        if()
//    return  status;
//}
- (void)dropDownItemDidSelect:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell {
    
}
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    switch (sender.tag) {
        case kstateTag: // States
        {
            if (selectedCountryDict) {
                NSDictionary *tempSelectedCountryDict = selectedCountryDict;
                NSString *countryCode = tempSelectedCountryDict[@"country_id"][@"__text"];
                NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kRegionList_key(countryCode)];
                if (!dataDict) {
                    [self fetchStatesForCountry:countryCode];
                }
                else {
                    [self parseRegionListMethodResponseWithDict:dataDict];
                }
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Message!"
                                            message:@"Please select valid country."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
            }
            break;
        }
        case kcountryTag: // Country
        {
            NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kCountyList_key];
            dbLog(@"%@",dataDict);
            if (!dataDict) {
                [self fetchCountryList];
            }
            else {
                [self parseCountriesMethodResponseWithDict:dataDict];
            }
            break;
        }
        default:
            break;
    }
    //    popoverViewController.itemsArray = nil;
    popoverViewController.parentIndexPath = indexPath;
    _statesPopover = popoverViewController.popoverPresentationController;
    _statesPopover.delegate = self;
    _statesPopover.sourceView = sender;
    _statesPopover.sourceRect = sender.rightView.frame;
}
- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}
- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
- (BOOL)validateName:(NSString *)firstyNameStr
            lastName:(NSString *)lastName
             emailID:(NSString *)emailStr {
    
    BOOL status = NO;
    if (firstyNameStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Name is required!"];
    }
    else if (lastName.length == 0){
        [self showAlertWithTitle:@"Message" msg:@"Last Name is required!"];
    }
    //    else if (addressStr.length == 0)
    //    {
    //        [self showAlertWithTitle:@"Message" msg:@"Address is required!"];
    //    }
    //    else if (cityStr.length == 0){
    //        [self showAlertWithTitle:@"Message" msg:@"City is required!"];
    //    }
    //    else if (stateStr.length == 0){
    //        [self showAlertWithTitle:@"Message" msg:@"State is required!"];
    //    }
    //    else if (postalCodeStr.length == 0) {
    //        [self showAlertWithTitle:@"Message" msg:@"Postalcode is required!"];
    //    }
    //    else if (countryStr.length == 0) {
    //        [self showAlertWithTitle:@"Message" msg:@"Country is required!"];
    //    }
    //    else if (emailStr.length == 0) {
    //        [self showAlertWithTitle:@"Message" msg:@"Email is required!"];
    //    }
    //    else if (phoneStr.length == 0) {
    //        [self showAlertWithTitle:@"Message" msg:@"Phone is required!"];
    //    }
    //    else if (phoneStr.length < 10){
    //        [self showAlertWithTitle:@"Message" msg:@"Valid Phone number required!"];
    //    }
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

- (void)fetchCountryList {
    
    if ([STUtility isNetworkAvailable]) {
        [STUtility startActivityIndicatorOnView:self.view withText:@"Fetching Countries."];
        NSString *requestBody = [STConstants countryListRequestBody];
        dbLog(@"Countries list: %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
                                                                   dbLog(@"Countries list xml: %@",xmlString);
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
                                                                   dbLog(@"Countries list %@",xmlDic);
                                                                   [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic withKey:kCountyList_key];
                                                                   [self parseCountriesMethodResponseWithDict:xmlDic];
                                                               });
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
        
        
        
        [httpRequest start];
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
            dbLog(@"%@",popoverViewController.itemsArray);
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
        [STUtility startActivityIndicatorOnView:self.view withText:@"Fetching states."];
        NSString *requestBody = [STConstants regionListequestBodyForCountry:countryCode];
        dbLog(@"States list: %@ for country %@",requestBody, countryCode);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
                                                                   dbLog(@"States list xml: %@ for country %@",xmlString,countryCode);
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
                                                                   dbLog(@"States list %@ for country %@",xmlDic, countryCode);
                                                                   [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic withKey:kRegionList_key(countryCode)];
                                                                   [self parseRegionListMethodResponseWithDict:xmlDic];
                                                               });
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
        
        
        
        [httpRequest start];
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
            
            self.listOfStatesForSelectedCountry = [dataArr sortedArrayUsingDescriptors:@[sort]];
            popoverViewController.itemsArray = self.listOfStatesForSelectedCountry;
            [self presentViewController:popoverViewController animated:YES completion:nil];
//            [popoverViewController.tableView reloadData];
        }
        else {
            dbLog(@"Error fetching region list order...");
        }
    }else {
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (NSString *)trimmedStateCode:(NSString *)rawStateCode {
    NSString *stateCodestr;
    dbLog(@"%@",rawStateCode);
    if (rawStateCode.length) {
        NSArray *stateCodeComponenets = [rawStateCode componentsSeparatedByString:@"-"];
        if (stateCodeComponenets.count > 1) {
            stateCodestr = stateCodeComponenets[1];
        }
    }
    return stateCodestr;
}
#pragma mark-
#pragma STPopoverTableViewControllerDelegate

- (void)itemDidSelect:(NSIndexPath *)indexpath selectedItemString:(NSString *)selectedItemStr parentIndexPath:(NSIndexPath *)pIndexPath{
    if (selectedItemStr.length) {
        
        STAddressTableViewCell *cell = [self.tableView cellForRowAtIndexPath:pIndexPath];
        if (cell) {
            UITextField *textField =  (UITextField *)_statesPopover.sourceView;
            switch (textField.tag) {
                case kstateTag:
                {
                    cell.stateTextField.text = selectedItemStr;
                    NSUInteger idx = cell.indexPath.row;
                    if (idx != NSNotFound) {
                        NSInteger idxToStore = idx-3;
                        if (idxToStore >= 0)
                        {
                            Address *address = (self.customerAddressList.count == 0)? [[Address alloc] init] : self.customerAddressList[idxToStore];
                            //                            NSString *countryStr = selectedCountryDict[@"country_id"][@"__text"];
                            //                            NSArray *states = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:kRegionList_key(countryStr)];
                            //                            dbLog(@"%@",states);
                            NSDictionary *dataDict = self.listOfStatesForSelectedCountry[indexpath.row];
                            NSString *stateStr =  dataDict[@"name"][@"__text"];//[self trimmedStateCode:dataDict[@"code"][@"__text"]];
                            
                            address.region = stateStr;
                            if (self.customerAddressList.count > idxToStore ) {
                                [self.customerAddressList replaceObjectAtIndex:idxToStore withObject:address];
                            }
                            else {
                                [self.customerAddressList addObject:address];
                            }
                        }
                    }
                    break;
                }
                case kcountryTag:
                {
                    cell.countryTextField.text = selectedItemStr;
                    NSUInteger idx = cell.indexPath.row;
                    NSDictionary *datadict = self.listOfCountries[indexpath.row];
                    selectedCountryDict = datadict;
                    if (idx != NSNotFound) {
                        NSInteger idxToStore = idx-3;
                        if (idxToStore >= 0)
                        {
                            Address *address = (self.customerAddressList.count == 0)? [[Address alloc] init] : self.customerAddressList[idxToStore];
                            NSString *countryStr = selectedCountryDict[@"country_id"][@"__text"];
                            
                            address.country_id = countryStr;
                            
                            if (self.customerAddressList.count > idxToStore ) {
                                [self.customerAddressList replaceObjectAtIndex:idxToStore withObject:address];
                            }
                            else {
                                [self.customerAddressList addObject:address];
                            }
                        }
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
    [popoverViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
