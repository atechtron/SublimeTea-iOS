//
//  STMenuTableViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STMenuTableViewController.h"
#import "STNavigationController.h"

#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "STMenuTableHeaderView.h"
#import "STMenuTableViewCell.h"
#import "STMenuUserInfoTableHeaderView.h"

#import "STOrderListViewController.h"
#import "STDashboardViewController.h"
#import "STProductCategoriesViewController.h"
#import "STUserProfileViewController.h"

#import "STHttpRequest.h"
#import "STConstants.h"

@interface STMenuTableViewController ()<STMenuTableHeaderViewDelegate>
@property (strong, nonatomic)NSMutableArray *dataArr;
@property (strong, nonatomic)NSArray *sectionTitleDataArr;
@end

@implementation STMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMenuTableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STMenuTableHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMenuUserInfoTableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STMenuUserInfoTableHeaderView"];
    
    self.dataArr = [NSMutableArray new];
    self.sectionTitleDataArr = @[@"HOME",@"OUR RANGE",@"OUR RECENTLY VIEWED ITEMS",@"YOUR ORDERS",@"YOUR ACCOUNT",@"CUSTOMER SUPPORT",@"FAQ",@"LOGOUT"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitleDataArr.count +1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 2)
        count = self.dataArr.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView;
    if (section == 0) {
        STMenuUserInfoTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STMenuUserInfoTableHeaderView"];
        headerView.contentView.backgroundColor = [UIColor brownColor];
        headerView.tintColor = [UIColor clearColor];
        sectionHeaderView = headerView;
        headerView.TitleLabel.text = @"NEHA JAIN";
        headerView.subTitleLabel.text = @"neha@webenza.com";
    }
    else {
        STMenuTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STMenuTableHeaderView"];
        sectionHeaderView = headerView;
        headerView.section = section;
        headerView.delegate = self;
        
        headerView.titleLabel.text = self.sectionTitleDataArr[section-1];
        if (section == 2) {
            //        CALayer* layer = [headerView.titleLabel layer];
            
            //        CAGradientLayer *gradient = [CAGradientLayer layer];
            //        gradient.frame = headerView.titleLabel.bounds;
            //        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
            //        [headerView.titleLabel.layer insertSublayer:gradient atIndex:0];
            
            
            
            
            //        CALayer *bottomBorder = [CALayer layer];
            //        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            //        bottomBorder.borderWidth = 1;
            //        bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1, layer.frame.size.width, 1);
            //        [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
            //        [layer addSublayer:bottomBorder];
            
            headerView.accesoryBtn.hidden = NO;
        }
        else {
            headerView.accesoryBtn.hidden = YES;
        }
    }
    return sectionHeaderView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerViewHeight = 44;
    if (section == 0) {
        headerViewHeight = 120;
    }
    return headerViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (void)didSelectHeaderAtSectionIndex:(NSInteger )section {
    NSLog(@"SectionClicked %ld",section);
    if (section == 2 && self.dataArr.count == 0) {
        [self.dataArr addObjectsFromArray:@[@"flavoured green tea",@"pure green tea",@"limited edition tea",@"tisane",@"flavoured white tea",@"flavoured black tea"]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        if(section == 2){
            [self.dataArr removeAllObjects];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    STNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:navigationController.viewControllers];
    switch (section) {
        case 1: // Home
        {
            STDashboardViewController *dashBoard = [self.storyboard instantiateViewControllerWithIdentifier:@"STDashboardViewController"];
            [viewControllers addObject:dashBoard];
            navigationController.viewControllers = viewControllers;
            break;
        }
        case 2: // Our Range
        {
//            STProductCategoriesViewController *productCategories = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductCategoriesViewController"];
//            [viewControllers addObject:productCategories];
//            navigationController.viewControllers = viewControllers;
            break;
        }
        case 3: // Our Recent Items
            
            break;
        case 4: // Your Orders
        {
            STOrderListViewController *orderList = [self.storyboard instantiateViewControllerWithIdentifier:@"STOrderListViewController"];
            [viewControllers addObject:orderList];
            navigationController.viewControllers = viewControllers;
            break;
        }
        case 5: // Your Account
        {
            STUserProfileViewController *userProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"STUserProfileViewController"];
            [viewControllers addObject:userProfile];
            navigationController.viewControllers = viewControllers;
            break;
        }
        case 6: // Customer Suppourt
            
            break;
        case 7: // FAQ
            
            break;
        case 8: // LogOut
            [STUtility startActivityIndicatorOnView:nil withText:@"Loggin Out Please wait.."];
            [self endUserSession];
            [navigationController popToRootViewControllerAnimated:YES];
            break;
        default:
            break;
    }
    if (section != 2) {
        self.frostedViewController.contentViewController = navigationController;
        [self.frostedViewController hideMenuViewController];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    STNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    //    if (indexPath.section == 0 && indexPath.row == 0) {
//        DEMOHomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeController"];
//        navigationController.viewControllers = @[homeViewController];
//    } else {
//        DEMOSecondViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"secondController"];
//        navigationController.viewControllers = @[secondViewController];
//    }
//    
//    self.frostedViewController.contentViewController = navigationController;
//    [self.frostedViewController hideMenuViewController];
}

- (void)endUserSession {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userSessionId = [defaults objectForKey:kUSerSession_Key];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:endSession soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                             "</urn:endSession>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",userSessionId];
    
    
    STHttpRequest *featureNSpecHttpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                     methodType:@"POST"
                                                                           body:requestBody
                                                            responseHeaderBlock:^(NSURLResponse *response)
                                              {
                                                  
                                              }successBlock:^(NSData *responseData){
                                                  NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                                  NSLog(@"%@",xmlDic);
                                                  NSDictionary *resultDict = xmlDic[@"SOAP-ENV:Body"][@"ns1:endSessionResponse"][@"endSessionReturn"];
                                                  if ([resultDict[@"__text"] boolValue]) {
                                                      [defaults removeObjectForKey:kUSerSession_Key];
                                                      [defaults synchronize];
                                                      
                                                  }
                                                  [STUtility stopActivityIndicatorFromView:nil];
                                              }failureBlock:^(NSError *error) {
                                                  NSLog(@"SublimeTea-STSignUpViewController-endUserSession:- %@",error);
                                                  [STUtility stopActivityIndicatorFromView:nil];
                                              }];
    
    [featureNSpecHttpRequest start];
}
@end
