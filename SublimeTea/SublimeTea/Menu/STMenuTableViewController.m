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
#import "STAppDelegate.h"
#import "STGlobalCacheManager.h"
#import "STProductViewController.h"
#import "STRootViewController.h"

@interface STMenuTableViewController ()<STMenuTableHeaderViewDelegate>
{
    NSInteger selectedCatId;
}
@property (weak, nonatomic)STNavigationController *navController;
@property (strong, nonatomic)NSArray *dataArr;
@property (strong, nonatomic)NSArray *sectionTitleDataArr;
@end

@implementation STMenuTableViewController

-(STNavigationController *)navController {
    if (!_navController) {
        STRootViewController *rootViewController = (STRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        _navController = (STNavigationController *)rootViewController.contentViewController;
    }
    return _navController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMenuTableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STMenuTableHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMenuUserInfoTableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STMenuUserInfoTableHeaderView"];
    
    self.dataArr = [NSMutableArray new];
    self.sectionTitleDataArr = @[@"HOME",@"OUR RANGE",@"YOUR ORDERS",@"YOUR ACCOUNT",@"CUSTOMER SUPPORT",@"FAQ",@"LOGOUT"];
    self.view.backgroundColor = UIColorFromRGB(231, 230, 230, 1);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logOut)
                                                 name:@"LOGOUT"
                                               object:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    NSDictionary *prodDict = self.dataArr[indexPath.row];
    NSString *name = prodDict[@"name"][@"__text"];
    cell.titleLabel.text = name;
    cell.titleLabel.textColor = UIColorFromRGB(90, 37, 26, 1);
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView;
    if (section == 0) {
        STMenuUserInfoTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STMenuUserInfoTableHeaderView"];
        headerView.contentView.backgroundColor = UIColorFromRGB(90, 37, 26, 1);
        headerView.tintColor = [UIColor clearColor];
        sectionHeaderView = headerView;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
        NSLog(@"User Details: %@",userInfoDict);
        
        NSString *userEmail = userInfoDict[@"email"][@"__text"];
        NSString *userFirstName = userInfoDict[@"firstname"][@"__text"] ? userInfoDict[@"firstname"][@"__text"] :@"";
        NSString *userLastName = userInfoDict[@"lastname"][@"__text"] ? userInfoDict[@"lastname"][@"__text"] :@"";
        NSString *userFullName = [NSString stringWithFormat:@"%@ %@",userFirstName,userLastName];
        
        headerView.TitleLabel.text = [userFullName uppercaseString];
        headerView.subTitleLabel.text = userEmail;
    }
    else {
        STMenuTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STMenuTableHeaderView"];
        sectionHeaderView = headerView;
        headerView.section = section;
        headerView.titleLabel.textColor = UIColorFromRGB(90, 37, 26, 1);
        headerView.delegate = self;
        headerView.titleLabel.text = self.sectionTitleDataArr[section-1];
        if (section == 4 || section == 2)
        {
            headerView.bottomImageview.hidden = NO;
        }
        else
        {
            headerView.bottomImageview.hidden = YES;
        }
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
- (void)didSelectHeader:(STMenuTableHeaderView *)header AtSectionIndex:(NSInteger )section {
    NSLog(@"SectionClicked %ld",section);
    if (section == 2 && self.dataArr.count == 0) {
        header.bottomImageview.hidden = YES;
        NSDictionary *resultXMLDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kProductCategory_Key];
        NSLog(@"%@",resultXMLDict);
        [self parseResponseWithDict:resultXMLDict];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        if(section == 2){
            header.bottomImageview.hidden = NO;
            self.dataArr = nil;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (section == 4)
        {
            header.bottomImageview.hidden = NO;
        }
        else
        {
            header.bottomImageview.hidden = YES;
        }
    }

    switch (section) {
        case 1: // Home
        {
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navController.viewControllers];
            [viewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[STDashboardViewController class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        STDashboardViewController *dashBoard = (STDashboardViewController *)obj;
                        [self.navController popToViewController:dashBoard animated:YES];
                    });
                    *stop = YES;
                }
            }];
//            STDashboardViewController *dashBoard = [self.storyboard instantiateViewControllerWithIdentifier:@"STDashboardViewController"];
//            [viewControllers addObject:dashBoard];
            
//            [self.  pushViewController:dashBoard animated:YES];
//            self..viewControllers = viewControllers;
            break;
        }
        case 2: // Our Range
        {
//            STProductCategoriesViewController *productCategories = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductCategoriesViewController"];
//            [viewControllers addObject:productCategories];
//            navigationController.viewControllers = viewControllers;
            break;
        }
        case 3: // Your Orders
        {
            STOrderListViewController *orderList = [self.storyboard instantiateViewControllerWithIdentifier:@"STOrderListViewController"];
//            [viewControllers addObject:orderList];
            [self.navController  pushViewController:orderList animated:YES];
//            self..viewControllers = viewControllers;
            break;
        }
        case 4: // Your Account
        {
            STUserProfileViewController *userProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"STUserProfileViewController"];
//            [viewControllers addObject:userProfile];
            [self.navController  pushViewController:userProfile animated:YES];
//            self..viewControllers = viewControllers;
            break;
        }
        case 5: // Customer Suppourt
            
            break;
        case 6: // FAQ
            
            break;
        case 7: // LogOut
            [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
            [self logOut];
            break;
        default:
            break;
    }
    if (section != 2) {
//        self.frostedViewController.contentViewController = self.;
        [self.frostedViewController hideMenuViewController];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedCatId = indexPath.row;
//    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self..viewControllers];
    
    STProductViewController *vC = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductViewController"];
    vC.selectedCategoryDict = self.dataArr[selectedCatId];
    [self.navController pushViewController:vC animated:YES];
//    self.navController.viewControllers = viewControllers;
//
//    self.frostedViewController.contentViewController = self.navController;
    [self.frostedViewController hideMenuViewController];
}

- (void)logOut {
    [AppDelegate endUserSession];
    UIViewController *root = [self.navController.viewControllers lastObject];
    if(![root isKindOfClass:[STDashboardViewController class]])
        [self.navController popToRootViewControllerAnimated:YES];
    else {
        self.frostedViewController.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    }
//    self.frostedViewController.contentViewController = self.navController;
    [self.frostedViewController hideMenuViewController];
}
- (void)parseResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSArray *productCategoriesArr = responseDict[@"SOAP-ENV:Body"][@"ns1:catalogCategoryTreeResponse"][@"tree"][@"children"][@"item"][@"children"][@"item"][@"children"][@"item"];
            NSLog(@"%@",productCategoriesArr);
            if (productCategoriesArr.count) {
                self.dataArr = [NSArray arrayWithArray:productCategoriesArr];
            }
            else{
                // No categories found.
            }
        }
        else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        //No categories found.
    }
//    [STUtility stopActivityIndicatorFromView:nil];
}
@end
