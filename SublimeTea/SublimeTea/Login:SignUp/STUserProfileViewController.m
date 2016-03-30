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

@implementation Address
- (NSInteger)is_default_billing {
    return 0;
}
- (NSInteger)is_default_shipping {
    return 0;
}
@end

@interface STUserProfileViewController ()<UITableViewDelegate, UITableViewDataSource, STProfileTableViewCellDelegate, UITextFieldDelegate, UITextViewDelegate, STAddressTableViewCellDelegate>
{
    UIView *viewToScroll;
    NSString *passwordString;
    STPopoverTableViewController *popoverViewController;
}
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) NSMutableArray *customerAddressList;
@property (strong, nonatomic)NSMutableDictionary *userInfo;

@property (weak, nonatomic)UITextField *nameTextField;
@property (weak, nonatomic)UITextField *emailTextField;
@property (weak, nonatomic)UITextField *passwordTextField;
@end

@implementation STUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    NSString *userEmail = self.userInfo[@"email"][@"__text"];
    NSString *userFirstName = self.userInfo[@"firstname"][@"__text"] ? self.userInfo[@"firstname"][@"__text"] :@"";
    NSString *userLastName = self.userInfo[@"lastname"][@"__text"] ? self.userInfo[@"lastname"][@"__text"] :@"";
    NSString *userFullName = [NSString stringWithFormat:@"%@ %@",userFirstName,userLastName];

    //    NSString *custId = userInfoDict[@"customer_id"][@"__text"];
    NSDictionary *userNameDict = @{@"userName": userFullName};
    NSDictionary *emailDIct = @{@"email": userEmail};
    
    NSArray *tempArr = @[userNameDict,
                         emailDIct,
                         @"addAddress",
                         @"changePwdBtn"
                         ];
    self.dataArr = [NSMutableArray arrayWithArray:tempArr];
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
    if ([keyName isEqualToString:@"userName"] || [keyName isEqualToString:@"email"]|| [keyName isEqualToString:@"changePwdTxtField"])
    {
        static NSString *cellIdentifier = @"textFieldCell";
        STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        _cell.profileTextField.delegate = self;
        if ([keyName isEqualToString:@"userName"]) {
            _cell.profileTextFieldTitleLabel.text = @"Name";
            _cell.profileTextField.text = obj[keyName];
            _cell.profileTextField.keyboardType = UIKeyboardTypeAlphabet;
            _cell.profileTextField.delegate = self;
            _cell.profileTextField.tag = indexPath.row;
            self.nameTextField = _cell.profileTextField;
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
    if ([keyName isEqualToString:@"userName"] || [keyName isEqualToString:@"email"] || [keyName isEqualToString:@"changePwdTxtField"])
    {
        rowHeight = 89;
    }
    else if ([self.dataArr[indexPath.row] isEqualToString:@"address"])
    {
        rowHeight = 253;
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
    if(self.dataArr.count > 2)
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
    dbLog(@"IndexPath: %ld",indexPath.row);
    [self.dataArr replaceObjectAtIndex:indexPath.row withObject:@"changePwdTxtField"];
    //    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //    [self.dataArr addObject:@"changePwdTxtField"];
    
    NSIndexPath *addressBtnIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1
                                                          inSection:indexPath.section];
    dbLog(@"IndexPath: %ld",addressBtnIndexPath.row);
    [self.tableView reloadRowsAtIndexPaths:@[addressBtnIndexPath,indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}
- (BOOL)validateAdress:(Address *)add {
//customerAddressList
    BOOL status = NO;
    
    if (add.firstname.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"First Name is required!"];
    }
    else if (add.lastname.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Last Name is required!"];
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
    else if (add.street.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Street is required!"];
    }
    
    return status;
}
#pragma mark-
#pragma UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    viewToScroll = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    viewToScroll = nil;
    UIView *superView = textField.superview;
//    if ([superView isKindOfClass:[STAddressTableViewCell class]]) {
//        STAddressTableViewCell *cell = (STAddressTableViewCell *)superView;
//        NSUInteger idx = cell.indexPath.row;
//        if (idx != NSNotFound) {
//            NSInteger idxToStore = idx-2;
//            if (idxToStore > 1) {
//                
//                NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *addressStr = [self.addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *cityStr = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *stateStr =  [self trimmedStateCode:self.listOfStatesForSelectedCountryForShipping[selectedStatesIdxForShipping][@"code"][@"__text"]];//self.listOfStatesForSelectedCountryForShipping[selectedStatesIdxForShipping][@"code"][@"__text"];
//                NSLog(@"Selected State Code :-  %@",stateStr);
//                stateStr = stateStr?stateStr:[self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *postalCodeStr = [self.postalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *countryStr = selectedCountryDict ? selectedCountryDict[@"country_id"][@"__text"] : [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                countryStr = countryStr?countryStr:[self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                
//                NSArray *nameComponents = [nameStr componentsSeparatedByString: @" "];
//                
//                address.shipAddress.firstname = nameComponents.count ? nameComponents[0] :@"";
//                NSMutableString *lastNameStr = [NSMutableString new];
//                if(nameComponents.count > 1){
//                    for (NSInteger idx = 1; idx < nameComponents.count; idx ++) {
//                        [lastNameStr appendString:nameComponents[idx]];
//                    }
//                }
//                Address *add = [[Address alloc] init];
//                address.shipAddress.lastname = lastNameStr;
//                address.shipAddress.city = cityStr;
//                address.shipAddress.state = stateStr;
//                address.shipAddress.postcode = postalCodeStr;
//                address.shipAddress.country_id = countryStr;
//                address.shipAddress.email = emailStr;
//                address.shipAddress.telephone = phoneStr;
//                address.shipAddress.street = addressStr;
//            }
//        }
//    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

#pragma mark-
#pragma UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    viewToScroll = textView;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    viewToScroll = nil;
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
    [self.view endEditing:YES];
    if ([STUtility isNetworkAvailable] && self.userInfo && [self validateName:self.nameTextField.text emailID:self.emailTextField.text]) {
        NSString *custId = self.userInfo[@"customer_id"][@"__text"];
        NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//self.userInfo[@"email"][@"__text"];
//        NSString *pwdStr = passwordString.length ? passwordString: nil;
        NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *nameComponents = [nameStr componentsSeparatedByString: @" "];
        
        NSString *firstName = nameComponents.count ? nameComponents[0] :@"";
        NSMutableString *lastNameStr = [NSMutableString new];
        if(nameComponents.count > 1){
            for (NSInteger idx = 1; idx < nameComponents.count; idx ++) {
                [lastNameStr appendString:nameComponents[idx]];
            }
        }
        NSString *lastName = lastNameStr;
        
        NSString *requestBody = [STConstants userInfoRequstBodyWithCustomerId:[custId integerValue]
                                                                customerEmail:emailStr
                                                                    firstName:firstName
                                                                     lastName:lastName];
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
                [self customerAddressUpdate];
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
- (void)customerAddressUpdate {
    [STUtility startActivityIndicatorOnView:nil withText:@""];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSString *custId = self.userInfo[@"customer_id"][@"__text"];
    NSDictionary *paramDict = @{@"sessionId": sessionId,
                                @"customerId": custId};
    NSMutableDictionary *soapBodyDict = [NSMutableDictionary new];
    [soapBodyDict addEntriesFromDictionary:paramDict];
    
    [soapBodyDict setObject:@[] forKey:kAddressNodeName];
    [soapBodyDict setValue:[STConstants storeId] forKey:@"storeId"];
    
    
    if (soapBodyDict) {
        NSString *requestBody = [STUtility prepareMethodSoapBody:@"customerAddressCreate"
                                                          params:soapBodyDict];
        dbLog(@"add product to Cart Request Body: %@",requestBody);
    
    }
    
    
    
    NSString *requestBody = [STConstants customerAddressListRequestBody];
    
    dbLog(@"Customer Address update : %@",requestBody);
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
        dbLog(@"Customer Address xml: %@",xmlString);
        NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
        dbLog(@"Customer Address update result : %@",xmlDic);
        
//        [self parseCustomerAddressListMethodResponseWithDict:xmlDic];
    });
}
//- (BOOL)validateInputs {
//    BOOL status = NO;
//        if()
//    return  status;
//}
- (void)dropDownItemDidSelect:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell {

}
- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath {
//
//    popoverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STPopoverTableViewController"];
//    popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
//    popoverViewController.delegate = self;
//    popoverViewController.parentIndexPath = indexPath;
//    
//    switch (indexPath.section) {
//        case 0: // Shipping
//        {
//            switch (sender.tag) {
//                case 2: // States
//                {
//                    if (selectedCountryDict) {
//                        NSDictionary *tempSelectedCountryDict = selectedCountryDict;
//                        NSString *countryCode = tempSelectedCountryDict[@"country_id"][@"__text"];
//                        NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kRegionList_key(countryCode)];
//                        if (!dataDict) {
//                            [self fetchStatesForCountry:countryCode];
//                        }
//                        else {
//                            [self parseRegionListMethodResponseWithDict:dataDict];
//                        }
//                    }
//                    else {
//                        [[[UIAlertView alloc] initWithTitle:@"Message!"
//                                                    message:@"Please select valid country."
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles: nil] show];
//                    }
//                    break;
//                }
//                case 3: // Country
//                {
//                    NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kCountyList_key];
//                    if (!dataDict) {
//                        [self fetchCountryList];
//                    }
//                    else {
//                        [self parseCountriesMethodResponseWithDict:dataDict];
//                    }
//                    break;
//                }
//                default:
//                    break;
//            }
//            break;
//        }
//        case 1: // Billing
//        {
//            switch (sender.tag) {
//                case 2: // States
//                {
//                    if (billingSelectedCountryDict) {
//                        NSDictionary *tempSelectedCountryDict = billingSelectedCountryDict;
//                        NSString *countryCode = tempSelectedCountryDict[@"country_id"][@"__text"];
//                        NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kRegionList_key(countryCode)];
//                        if (!dataDict) {
//                            [self fetchStatesForCountry:countryCode];
//                        }
//                        else {
//                            [self parseRegionListMethodResponseWithDict:dataDict];
//                        }
//                    }
//                    break;
//                }
//                case 3: // Countries
//                {
//                    NSDictionary *dataDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:kCountyList_key];
//                    if (!dataDict) {
//                        [self fetchCountryList];
//                    }
//                    else {
//                        [self parseCountriesMethodResponseWithDict:dataDict];
//                    }
//                    break;
//                }
//                default:
//                    break;
//            }
//            break;
//        }
//        default:
//            break;
//    }
//    
//    _statesPopover = popoverViewController.popoverPresentationController;
//    _statesPopover.delegate = self;
//    _statesPopover.sourceView = sender;
//    _statesPopover.sourceRect = sender.rightView.frame;
//    [self presentViewController:popoverViewController animated:YES completion:nil];
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
- (BOOL)validateName:(NSString *)nameStr
             emailID:(NSString *)emailStr {
    
    BOOL status = NO;
    NSArray *nameCompnents = [nameStr componentsSeparatedByString:@" "];
    if (nameStr.length == 0) {
        [self showAlertWithTitle:@"Message" msg:@"Name is required!"];
    }
    else if (nameCompnents.count < 1){
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
//- (BOOL)validateInputs {
//    BOOL status = NO;
//    NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *addressStr = [self.addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *cityStr = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *stateStr = [self.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *postalCodeStr = [self.postalCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *countryStr = [self.countryextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *emailStr = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *phoneStr = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    status = [self validateName:nameStr
//                        address:addressStr
//                           city:cityStr
//                          state:stateStr
//                     postalCode:postalCodeStr
//                        country:countryStr
//                        emailID:emailStr
//                          phone:phoneStr];
//    return status;
//}


//- (void)updateUserInfo {
//    
//    if ([STUtility isNetworkAvailable]) {
//        [STUtility startActivityIndicatorOnView:self.view withText:@"Fetching states."];
//        
//        NSDictionary *emailDIct = self.dataArr[1];
//        NSDictionary *name = self.dataArr[1];
//        NSString *custId = self.userInfo[@""];
//        NSString *email =
//        NSString *requestBody = [STConstants userInfoRequstBodyWithCustomerId:[custId integerValue]
//                                                                customerEmail:<#(NSString *)#>
//                                                                    firstName:<#(NSString *)#>
//                                                                     lastName:<#(NSString *)#>];
//        dbLog(@"States list: %@ for country %@",requestBody, countryCode);
//        NSString *urlString = [STConstants getAPIURLWithParams:nil];
//        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        
//        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
//                                                             methodType:@"POST"
//                                                                   body:requestBody
//                                                    responseHeaderBlock:^(NSURLResponse *response){}
//                                                           successBlock:^(NSData *responseData){
//                                                               dispatch_async(dispatch_get_main_queue(), ^{
//                                                                   NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
//                                                                   dbLog(@"States list xml: %@ for country %@",xmlString,countryCode);
//                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
//                                                                   dbLog(@"States list %@ for country %@",xmlDic, countryCode);
//                                                                   [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic withKey:kRegionList_key(countryCode)];
//                                                                   [self parseRegionListMethodResponseWithDict:xmlDic];
//                                                               });
//                                                           }
//                                                           failureBlock:^(NSError *error)
//                                      {
//                                          [STUtility stopActivityIndicatorFromView:nil];
//                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
//                                                                      message:@"Unexpected error has occured, Please try after some time."
//                                                                     delegate:nil
//                                                            cancelButtonTitle:@"OK"
//                                                            otherButtonTitles: nil] show];
//                                          dbLog(@"SublimeTea-STPlaceOrder-fetchCountryList:- %@",error);
//                                      }];
//        
//        
//        
//        [httpRequest start];
//    }
//    else {
//        [STUtility stopActivityIndicatorFromView:nil];
//    }
//}
@end
