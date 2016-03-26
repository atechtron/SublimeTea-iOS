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

@interface STOrderListViewController ()<UITabBarDelegate, UITableViewDataSource>

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
    [self orderList];
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
//    NSString *titleStr = orderDetails[];
    NSString *status = orderDetails[@"status"][@"__text"];
    NSString *qty = orderDetails[@"total_qty_ordered"][@"__text"];
    double totalPaid = [orderDetails[@"total_paid"][@"__text"]doubleValue];
    
    
    cell.titleLabel.text = @"GREEN LONG DING";
    cell.descriptionLabel.text = @"This is a pure Green Tea. Fresh tender tea leaves are carefully processed to minimize oxidation and rolled using a very special process.";
    cell.priceLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%.2f",totalPaid]];
    cell.prodImageView.image = [UIImage imageNamed:@"teaCup.jpeg"];
    cell.statusLabel.text = [NSString stringWithFormat:@"Status: %@",status];
    
    NSString *itemStr = [qty integerValue] > 0 ? @"ITEMS" :@"ITEM";
    cell.qtyLabel.text = [NSString stringWithFormat:@"QUANTITY: %@ (%@)",qty,itemStr];

    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    footerView.titleLabel.text = @"Orders";
    
    return footerView;
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
                                                                   dbLog(@"Order Lists %@",xmlDic);
                                                                        [self parseOrderListResponseWithDict:xmlDic];
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
- (void)parseOrderListResponseWithDict:(NSDictionary *)responseDict {
    if(responseDict){
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        //        dbLog(@"Image Data for ID %d %@",prodId, responseDict);
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:salesOrderListResponse"][@"result"];
            NSArray *orders = dataDict[@"item"];
            NSSortDescriptor *sortDisc = [NSSortDescriptor sortDescriptorWithKey:@"created_at.__text" ascending:YES];
            self.orderListArr = [orders sortedArrayUsingDescriptors:@[sortDisc]];
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            dbLog(@"Error fetching order list...");
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}

@end
