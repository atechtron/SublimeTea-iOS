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

@interface STUserProfileViewController ()<UITableViewDelegate, UITableViewDataSource, STProfileTableViewCellDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    UIView *viewToScroll;
    NSString *passwordString;
    STPopoverTableViewController *popoverViewController;
}
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic)NSMutableDictionary *userInfo;
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
    //    NSString *custId = userInfoDict[@"customer_id"][@"__text"];
    
    
    NSArray *tempArr = @[@"userName",
                         @"email",
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
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"userName"] || [self.dataArr[indexPath.row] isEqualToString:@"email"]|| [self.dataArr[indexPath.row] isEqualToString:@"changePwdTxtField"])
    {
        static NSString *cellIdentifier = @"textFieldCell";
        STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        _cell.profileTextField.delegate = self;
        if ([self.dataArr[indexPath.row] isEqualToString:@"userName"]) {
            _cell.profileTextFieldTitleLabel.text = @"Username";
            _cell.profileTextField.keyboardType = UIKeyboardTypeAlphabet;
        }
        else if([self.dataArr[indexPath.row] isEqualToString:@"email"]) {
            _cell.profileTextFieldTitleLabel.text = @"Email id";
            _cell.profileTextField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        else {
            _cell.profileTextFieldTitleLabel.text = @"Change Password";
            _cell.profileTextField.secureTextEntry = YES;
            _cell.profileTextField.keyboardType = UIKeyboardTypeDefault;
        }
        cell = _cell;
    }
    else if ([self.dataArr[indexPath.row] isEqualToString:@"address"])
    {
        static NSString *cellIdentifier = @"textViewCell";
        STAddressTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//        _cell.profileTextView.delegate = self;
        _cell.addressTextView.keyboardType = UIKeyboardTypeDefault;
        if (indexPath.row == 2) {
            _cell.addressTextViewTitleLabel.text = @"My Addresses";
        }
        else {
            _cell.addressTextViewTitleLabel.text = @"";
        }
        
        cell = _cell;
    }
    else if ([self.dataArr[indexPath.row] isEqualToString:@"addAddress"] || [self.dataArr[indexPath.row] isEqualToString:@"changePwdBtn"])
    {
        static NSString *cellIdentifier = @"buttonCell";
        STPrfileTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        _cell.delegate = self;
        _cell.currentIndexPath = indexPath;
        if ([self.dataArr[indexPath.row] isEqualToString:@"addAddress"]) {
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
    if ([self.dataArr[indexPath.row] isEqualToString:@"userName"] || [self.dataArr[indexPath.row] isEqualToString:@"email"] || [self.dataArr[indexPath.row] isEqualToString:@"changePwdTxtField"])
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

#pragma mark-
#pragma UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    viewToScroll = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    viewToScroll = nil;
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
    
    if ([STUtility isNetworkAvailable] && self.userInfo) {
        NSString *emailStr = self.userInfo[@"email"][@"__text"];
        NSString *pwdStr = passwordString.length ? passwordString: nil;
        NSString *requestBody = [STConstants customerInfoUpdateRequestBodyWithEmail:emailStr
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
                                          dbLog(@"SublimeTea-STPlaceOrder-saveChangesButtonAction:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"User account xml : %@",xmlString);
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
            dbLog(@"User account : %@",xmlDic);
            
            //            [self parseOrderCreationMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
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

//- (BOOL)validateInputs {
//    BOOL status = NO;
//        if()
//    return  status;
//}
//- (void)droDownAction:(UITextField *)sender tapGesture:(UITapGestureRecognizer *)tapGesture indexPath:(NSIndexPath *)indexPath {
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
//}
- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

@end
