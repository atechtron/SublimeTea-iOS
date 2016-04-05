//
//  STOrderDetailsViewController.m
//  SublimeTea
//
//  Created by Apple on 28/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STOrderDetailsViewController.h"
#import "STHttpRequest.h"
#import "STOderListTableViewCell.h"
#import "STOrderListHeaderView.h"
#import "STProductCategoriesViewController.h"
#import "STUtility.h"
#import "STGlobalCacheManager.h"
#import "FileDownloader.h"

@interface STOrderDetailsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary *rawItemDict;
    NSArray *orderItemArr;
    NSURLSession *downloadSession;
    NSURLSessionConfiguration *downloadConfig;
}
@end

@implementation STOrderDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STOrderListHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STOrderListHeaderView"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    downloadConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    downloadSession = [NSURLSession sessionWithConfiguration:downloadConfig];
}
- (void)viewDidAppear:(BOOL)animated {
    NSString *orderId = self.selectedOrderDict[@"increment_id"][@"__text"];
    NSDictionary *xmlDict = (NSDictionary *)[[STGlobalCacheManager defaultManager]getItemForKey:orderId];
    if (xmlDict) {
        [self parseOrderDetailResponseWithDict:xmlDict];
    }
    else {
        [self fetchOrderDetails];
    }
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
    return orderItemArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"orderListCell";
    STOderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    NSDictionary *orderDetails = orderItemArr[indexPath.row];
    
    NSString *prodId = orderDetails[@"product_id"][@"__text"];
    NSString *titleStr = orderDetails[@"name"][@"__text"];
    NSString *status = self.selectedOrderDict[@"status"][@"__text"];
    NSString *qty = orderDetails[@"qty_ordered"][@"__text"];
    double totalPaid = [orderDetails[@"price"][@"__text"]doubleValue];
    NSString *sku = orderDetails[@"sku"][@"__text"];
    NSString *weight = orderDetails[@"weight"][@"__text"];
    NSString *orderId = rawItemDict[@"order_id"][@"__text"];
    NSString *totalWeight = [NSString stringWithFormat:@"%.2f (%ldx%.2f)",[orderDetails[@"row_weight"][@"__text"]floatValue],(long)[qty integerValue],[weight floatValue]];
    
    cell.titleLabel.text = [titleStr uppercaseString];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"OrderId: %@\nSKU: %@\nWeight: %@",orderId,sku, totalWeight];
    cell.priceLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%.2f",totalPaid]];
    cell.statusLabel.attributedText = [self attributedStringForStataus:[status capitalizedString]];
    
    NSString *itemStr = [qty integerValue] > 0 ? @"ITEMS" :@"ITEM";
    cell.qtyLabel.text = [NSString stringWithFormat:@"QUANTITY: %ld (%@)",(long)[qty integerValue],itemStr];
    
    
    NSArray *prodImgArr = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];

    if (prodImgArr.count) {
        id imgObj = prodImgArr;
        if ([imgObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *imgUrlDict = (NSDictionary *)imgObj;
            NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
            dbLog(@"Image URL %@",imgUrl);
            [self loadProdImageinView:cell.prodImageView fromURL:imgUrl];
        }
        else if ([imgObj isKindOfClass:[NSArray class]]) {
            NSDictionary *imgUrlDict = [prodImgArr lastObject];
            NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
            dbLog(@"Image URL %@",imgUrl);
            [self loadProdImageinView:cell.prodImageView fromURL:imgUrl];
        }
        
    }
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STOrderListHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STOrderListHeaderView"];
    footerView.titleLabel.text = @"Order Details";
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 62;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IBAction)continueShoppingButtonAction:(UIButton *)sender {
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSUInteger idx = [viewControllers indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[STProductCategoriesViewController class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STProductCategoriesViewController *categoryView = (STProductCategoriesViewController *)obj;
                [self.navigationController popToViewController:categoryView animated:YES];
            });
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (idx == NSNotFound) {
         STProductCategoriesViewController *productCategoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductCategoriesViewController"];
        [self.navigationController pushViewController:productCategoriesViewController animated:YES];
    }
}
- (void)fetchOrderDetails {
    
    if ([STUtility isNetworkAvailable]) {
        [STUtility startActivityIndicatorOnView:nil withText:@"The page is brewing"];
        NSString *orderId = self.selectedOrderDict[@"increment_id"][@"__text"];
        NSString *requestBody = [STConstants salesOrderInfoRequstBodyWithOrderIncrementId:orderId];
        dbLog(@"Order Details: %@",requestBody);
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                                                   
                                                                   [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic
                                                                                                                 withKey:orderId];
                                                                   dbLog(@"Order Details %@",xmlDic);
                                                                   [self parseOrderDetailResponseWithDict:xmlDic];
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
                                          dbLog(@"SublimeTea-STOrderDetailsViewController-fetchOrderDetails:- %@",error);
                                      }];
        
        
        
        [httpRequest start];
        
    }
}
- (void)parseOrderDetailResponseWithDict:(NSDictionary *)responseDict {
    if(responseDict){
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        //        dbLog(@"Image Data for ID %d %@",prodId, responseDict);
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:salesOrderInfoResponse"][@"result"];
            id orderItems = dataDict[@"items"][@"item"];
            rawItemDict = orderItems;
            if ([orderItems isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tempOrderDict = (NSDictionary *)orderItems;
                orderItemArr = @[tempOrderDict];
                [self getImageForItem:tempOrderDict];
            }
            else if ([orderItems isKindOfClass:[NSArray class]])
            {
                NSArray *tempOrderArr = (NSArray *)orderItems;
                orderItemArr = tempOrderArr;
                for (NSDictionary *prodDict in tempOrderArr) {
                    [self getImageForItem:prodDict];
                }
            }
            [self.tableView reloadData];
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            dbLog(@"Error fetching order list...");
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)getImageForItem:(NSDictionary *)prodDict {
    NSString *prodId = prodDict[@"product_id"][@"__text"];
    NSDictionary *imgXMLDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
    
    if (!imgXMLDict) {
        [self fetchProductImages:prodId];
    }
}
- (void)fetchProductImages:(NSString *)prodId {
    
    NSString *requestBody = [STConstants productImageListRequestBodyWithId:prodId];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:nil successBlock:nil failureBlock:nil];
    
    NSData *responseData = [httpRequest synchronousStart];
    NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
    dbLog(@"Image Data for ID %ld %@",(long)prodId, xmlDic);
    [self parseImgData:xmlDic andProdId:prodId];
}
- (void)parseImgData :(NSDictionary *)responseDict andProdId:(NSString *)prodId {
    if(responseDict){
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        dbLog(@"Image Data for ID %ld %@",(long)prodId, responseDict);
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *imgDataDict = parentDataDict[@"ns1:catalogProductAttributeMediaListResponse"][@"result"];
            NSArray *imageURLList = imgDataDict[@"item"];
            if (imageURLList) {
                [[STGlobalCacheManager defaultManager] addItemToCache:imageURLList withKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT"
                                                                object:nil];
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}

- (void)loadProdImageinView:(UIImageView *)imgView
                    fromURL:(NSString *)imgURL {
    
    if (imgView && imgURL.length) {
        
        NSData *imgData = (NSData *)[[STGlobalCacheManager defaultManager] getItemForKey:imgURL];
        if (imgData) {
            UIImage *prodImg = [UIImage imageWithData:imgData];
            if (prodImg) {
                [UIView transitionWithView:imgView duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                       imgView.image = prodImg;
                                   } completion:nil];
            }
            
        }
        else {
            // Download Image
            __block UIImageView *prodImgView = imgView;
            NSURL *url  = [[NSURL alloc] initWithString:[imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLSessionDataTask *imageDownloadTask;
            FileDownloader *downloader = [[FileDownloader alloc] init];
            [downloader asynchronousFiledownload:imageDownloadTask
                          serviceUrlMethodString:url
                                      urlSession:downloadSession
                                       imageView:imgView
                         displayLoadingIndicator:YES
                                   completeBlock:^(NSData *data, NSURL *imgURL, UIView *imgView) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[STGlobalCacheManager defaultManager] addItemToCache:data
                                                                                         withKey:imgURL.absoluteString];
                                           UIImage *_img = [UIImage imageWithData:data];
                                           [UIView transitionWithView:imgView duration:0.5
                                                              options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                                                  prodImgView.image = _img;
                                                              } completion:nil];
                                       });
                                       
                                   } errorBlock:^(NSError *error) {
                                       dbLog(@"SublimeTea-STOrderDetailsViewController-loadProdImageinView:- %@",error);
                                   }];
        }
    }
}

- (NSAttributedString *)attributedStringForStataus:(NSString *)statusStr {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    if (statusStr.length) {
        NSAttributedString *statusAttrStr = [[NSAttributedString alloc] initWithString:@"Status: " attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        NSAttributedString *statusTextAttrStr = [[NSAttributedString alloc] initWithString:statusStr attributes:@{NSForegroundColorAttributeName: [STUtility colorForOrderStatus:statusStr]}];
        [attrStr appendAttributedString:statusAttrStr];
        [attrStr appendAttributedString:statusTextAttrStr];
    }
    return attrStr;
}

@end
