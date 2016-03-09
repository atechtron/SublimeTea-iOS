//
//  STProductDetailViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STProductDetailViewController.h"
#import "STProductInfoTableViewCell.h"
#import "STProductInfo2TableViewCell.h"
#import "STProductDescriptionTableViewCell.h"
#import "STUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "STHttpRequest.h"
#import "STGlobalCacheManager.h"

@interface STProductDetailViewController ()<UITableViewDataSource, UITableViewDelegate, STProductInfo2TableViewCellDelegate>

@end

static NSInteger prodQtyCount = 0;

@implementation STProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.tableView registerNib:[UINib nibWithNibName:@"STProductInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"productInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STProductInfo2TableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"productAddToCartCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STProductDescriptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"productDescriptioncell"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- ( UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSString *prodId = self.selectedProdDict[@"product_id"][@"__text"];
    switch (indexPath.row) {
        case 0:
        {
            static NSString *cellidentifier = @"productInfoCell";
            STProductInfoTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
            
            _cell.titleLabel.text = self.selectedProdDict[@"name"][@"__text"];
            _cell.numLabel.text = @"";
            _cell.statusLabel.text = @"in stock";
            _cell.extraLabel.text = @"";
            NSArray *prodImgArr = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
            if (prodImgArr.count) {
                NSDictionary *imgUrlDict = [prodImgArr lastObject];
                NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
                NSLog(@"Image URL %@",imgUrl);
                NSData *imgData = (NSData *)[[STGlobalCacheManager defaultManager] getItemForKey:imgUrl];
                if (imgData) {
                    UIImage *prodImg = [UIImage imageWithData:imgData];
                    if (prodImg) {
                        [UIView transitionWithView:_cell.prodImageView duration:0.5
                                           options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                               _cell.prodImageView.image = prodImg;
                                               _cell.prodImageView.contentMode = UIViewContentModeScaleAspectFit;
                                           } completion:nil];
                    }
                }
            }
            cell = _cell;
            break;
        }
        case 1:
        {
            static NSString *cellidentifier = @"productAddToCartCell";
            STProductInfo2TableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
            _cell.delegate = self;
            
            
            NSString *desc = self.productInfoDict[@"short_description"][@"__text"];
            NSString *SKU = [NSString stringWithFormat:@"SKU: %@",self.productInfoDict[@"sku"][@"__text"]];
            NSString *categ = [NSString stringWithFormat:@"Categories: %@",self.selectedCategoryDict[@"name"][@"__text"]];//@"Categories: Pure Green Tea, Tea Bags";
            NSString *descriptionStr = [NSString stringWithFormat:@"%@\n%@\n%@",desc,SKU,categ];
            _cell.descriptionLabel.text = descriptionStr;
            _cell.amountLabel.text = [STUtility applyCurrencyFormat:[NSString stringWithFormat:@"%f",[self.productInfoDict[@"special_price"][@"__text"]floatValue]]];
            _cell.qtyLabel.text = @"290";
            _cell.qtyLabel.text = [NSString stringWithFormat:@"Qty\n%ld",(long)prodQtyCount];
            _cell.qtyLabel.backgroundColor = [UIColor orangeColor];
            _cell.qtyLabel.layer.borderWidth = 1;
            _cell.qtyLabel.layer.cornerRadius = _cell.qtyLabel.bounds.size.height/2;
            _cell.qtyLabel.clipsToBounds = YES;
            _cell.qtyLabel.layer.borderColor = [UIColor clearColor].CGColor;
            _cell.addToCartButton.tag = indexPath.row;
            
            cell = _cell;

            break;
        }
        case 2:
        {
            static NSString *cellidentifier = @"productDescriptioncell";
            STProductDescriptionTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
            _cell.topBorderImageView = nil;
            _cell.descriptionLabel.text = self.productInfoDict[@"description"][@"__text"];
            cell = _cell;

            break;
        }
        default:
            cell = [[UITableViewCell alloc] init];
            break;
    }
    return cell;
}
#pragma mark-
#pragma STProductInfo2TableViewCellDelegate

- (void)addToCartClicked:(NSInteger)index {
    [self performSegueWithIdentifier:@"carViewFromProductDetailSegue" sender:self];
}

- (void)qtyDidIncremented:(id)sender {
    ++prodQtyCount;
    STProductInfo2TableViewCell *cell = sender;
    cell.qtyLabel.text = [NSString stringWithFormat:@"Qty\n%ld",(long)prodQtyCount];
}

- (void)qtyDiddecremented:(id)sender {
    if (prodQtyCount > 0) {
        --prodQtyCount;
        STProductInfo2TableViewCell *cell = sender;
        cell.qtyLabel.text = [NSString stringWithFormat:@"Qty\n%ld",(long)prodQtyCount];
    }
}

//- (void)fetchProducts {
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *sessionId = [defaults objectForKey:kUSerSession_Key];
//    
//    NSDictionary *selectedProdCatDict = self.prodCategories[selectedCatId];
//    NSString *selectedCategoryId = selectedProdCatDict[@""];
//    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
//                             "<soapenv:Header/>"
//                             "<soapenv:Body>"
//                             "<urn:catalogProductInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
//                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
//                             "<productId xsi:type=\"xsd:string\">%@</productId>"
//                             "<storeView xsi:type=\"xsd:string\">%@</storeView>"
//                             "<attributes xsi:type=\"urn:catalogProductRequestAttributes\">"
//                             "</urn:catalogProductInfo>"
//                             "</soapenv:Body>"
//                             "</soapenv:Envelope>",sessionId,selectedCategoryId,@"default"];
//    
//    NSString *urlString = [STConstants getAPIURLWithParams:nil];
//    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    
//    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
//                                                         methodType:@"POST"
//                                                               body:requestBody
//                                                responseHeaderBlock:^(NSURLResponse *response)
//                                  {
//                                      
//                                  }successBlock:^(NSData *responseData){
//                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
//                                      NSLog(@"%@",xmlDic);
//                                      
//                                      [STUtility stopActivityIndicatorFromView:nil];
//                                      
//                                      [self performSelector:@selector(loadProductCategories) withObject:nil afterDelay:0.4];
//                                  }failureBlock:^(NSError *error) {
//                                      [STUtility stopActivityIndicatorFromView:nil];
//                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
//                                                                  message:@"Unexpected error has occured, Please try after some time."
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"OK"
//                                                        otherButtonTitles: nil] show];
//                                      NSLog(@"SublimeTea-STSignUpViewController-fetchProductCategories:- %@",error);
//                                  }];
//    
//    [httpRequest start];
//}
- (void)loadProductCategories {
    [self performSegueWithIdentifier:@"productListSegue" sender:self];
}
@end
