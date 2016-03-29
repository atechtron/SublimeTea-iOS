//
//  STOrderListViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STOrderListViewController.h"
#import "STOderListTableViewCell.h"
#import "STOrderListHeaderView.h"
#import "STDashboardViewController.h"
#import "STUtility.h"
#import "STHttpRequest.h"
#import "STOrderDetailsViewController.h"
#import "STGlobalCacheManager.h"

@interface STOrderListViewController ()<UITabBarDelegate, UITableViewDataSource>
{
    NSDictionary *selectedOrderDict;
}
@property (strong, nonatomic)NSArray *orderListArr;
@end

@implementation STOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
- (void)viewWillAppear:(BOOL)animated {
    NSDictionary *xmlDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kOrderList_Key];
    if (xmlDict) {
        [self parseOrderDetailsResponseWithDict:xmlDict];
    }
    else {
        [self orderList];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"orderDetailSegue"]) {
     STOrderDetailsViewController *orderDetail = segue.destinationViewController;
        orderDetail.selectedOrderDict = selectedOrderDict;
    }
}

#pragma mark-
#pragma UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderListArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"orderListCell";
    STOderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    NSDictionary *orderDetails = self.orderListArr[indexPath.row];
    
    NSString *status = orderDetails[@"status"][@"__text"];
    NSString *qty = orderDetails[@"total_qty_ordered"][@"__text"];
    NSString *totalPaid = orderDetails[@"subtotal_incl_tax"][@"__text"];
    NSString *orderId = orderDetails[@"increment_id"][@"__text"];
    NSString *orderCreatedDate = orderDetails[@"created_at"][@"__text"];
    
    // Format order creation date
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *formattedDate = [dateFormatter dateFromString:orderCreatedDate];
    dateFormatter.dateFormat = @"dd-MMM-yyyy";
    NSString *formatedOrderCreationDtae = [dateFormatter stringFromDate:formattedDate];
    
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Order Id: %@",orderId];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"Creation date: %@",formatedOrderCreationDtae];
    cell.priceLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%f",[totalPaid floatValue]]];
//    cell.prodImageView.image = [UIImage imageNamed:@"teaCup.jpeg"];
    cell.statusLabel.text = [NSString stringWithFormat:@"Status: %@",status];
    
    NSString *itemStr = [qty integerValue] > 1 ? @"ITEMS" :@"ITEM";
    cell.qtyLabel.text = [NSString stringWithFormat:@"QUANTITY: %ld (%@)",(long)[qty integerValue],itemStr];

    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    footerView.titleLabel.text = @"Orders";
    return footerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedOrderDict = self.orderListArr[indexPath.row];
    [self performSegueWithIdentifier:@"orderDetailSegue"
                              sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 62;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IBAction)continueShoppingButtonAction:(UIButton *)sender {
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    if(viewControllerArray.count > 2) {
        [self.navigationController popToViewController:viewControllerArray[2] animated:YES];
    }
    else {
        STDashboardViewController *dashBoard = [self.storyboard instantiateViewControllerWithIdentifier:@"STDashboardViewController"];
        [self.navigationController pushViewController:dashBoard animated:YES];
    }
}
- (void)orderList {
    if ([STUtility isNetworkAvailable]) {
        [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
        NSString *requestBody = [STConstants salesOrderListRequstBody];
        dbLog(@"Order List: %@",requestBody);
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                                                   [[STGlobalCacheManager defaultManager]addItemToCache:xmlDic withKey:kOrderList_Key];
                                                                   dbLog(@"Order Lists %@",xmlDic);
                                                                        [self parseOrderDetailsResponseWithDict:xmlDic];
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
                                          dbLog(@"SublimeTea-STPlaceOrder-orderList:- %@",error);
                                      }];
        
        
        
    [httpRequest start];
        
    }
}
- (void)parseOrderDetailsResponseWithDict:(NSDictionary *)responseDict {
    if(responseDict){
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        //        dbLog(@"Image Data for ID %d %@",prodId, responseDict);
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:salesOrderListResponse"][@"result"];
            NSArray *orders = dataDict[@"item"];
            NSSortDescriptor *sortDisc = [NSSortDescriptor sortDescriptorWithKey:@"created_at.__text" ascending:NO];
            self.orderListArr = [orders sortedArrayUsingDescriptors:@[sortDisc]];
            [self.tableView reloadData];
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            dbLog(@"Error fetching order list...");
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}

@end
