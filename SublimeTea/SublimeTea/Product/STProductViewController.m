//
//  STProductViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STProductViewController.h"
#import "STProductListCollectionViewCell.h"
#import "STHttpRequest.h"
#import "FileDownloader.h"
#import "STGlobalCacheManager.h"
#import "STProductDetailViewController.h"

@interface STProductViewController ()<UIScrollViewDelegate>
{
    NSURLSession *downloadSession;
    NSURLSessionConfiguration *downloadConfig;
    NSDictionary *prodDetailDict;
    NSInteger selectedProductIndex;
}
@end

@implementation STProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString *name = self.selectedCategoryDict[@"name"][@"__text"];
    self.titleLabel.text = name.length ?name :self.stringToSearch.length ? @"Search Results":@"";
    downloadConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    downloadSession = [NSURLSession sessionWithConfiguration:downloadConfig];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [STUtility startActivityIndicatorOnView:nil withText:@"Brewing"];
}
- (void)viewDidAppear:(BOOL)animated {
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [self numberOfPages];
    [self.view bringSubviewToFront:self.pageControl];
    self.pageControl.hidden = YES;
    
    NSDictionary *xmlDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kProductList_Key];
    if (self.stringToSearch.length) {
        dbLog(@"%@",self.stringToSearch);
        
        if (xmlDict) {
            self.productsInSelectedCat = [self searchProducts:xmlDict];
            [self.collectionView reloadData];
            [STUtility stopActivityIndicatorFromView:nil];
        }
        else {
            [self fetchProducts];
        }
    }
    else {
        if (xmlDict) {
            [self parseProductResponseWithDict:xmlDict];
        }
        else {
            [self fetchProducts];
        }
    }
}
- (NSArray *)searchProducts:(NSDictionary *)productDict {
    NSArray *filteredProducts;
    if (!productDict) {
        productDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kProductList_Key];
    }
    NSDictionary *parentDataDict = productDict[@"SOAP-ENV:Body"];
    NSArray *allProductsArr = parentDataDict[@"ns1:catalogProductListResponse"][@"storeView"][@"item"];
        //                prodDict[@"name"][@"__text"];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"name.__text CONTAINS[c] %@",self.stringToSearch];
    filteredProducts = [allProductsArr filteredArrayUsingPredicate:filterPredicate];
    dbLog(@"%@",filteredProducts);
    
    return filteredProducts;
}
- (NSInteger)numberOfPages {
    NSInteger singlePageElementHeightCount = 0;
    NSInteger singlePageElementWidthCount = 0;
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        // landscape
        singlePageElementWidthCount = 6;
        singlePageElementHeightCount = floor(self.collectionView.frame.size.width/117);
    }else {
        //potrait
        singlePageElementWidthCount = 3;
        singlePageElementHeightCount = floor(self.collectionView.frame.size.height/117);
    }
    
    NSInteger totalPages = ceil(21 /(singlePageElementHeightCount*singlePageElementWidthCount));
    return totalPages+1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"productDetailViewSegue"]) {
        STProductDetailViewController *viewController = segue.destinationViewController;
        viewController.productInfoDict = prodDetailDict;
        viewController.selectedProdDict = self.productsInSelectedCat[selectedProductIndex];
        viewController.selectedCategoryDict = self.selectedCategoryDict;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    [self.pageControl setCurrentPage:page];
}

#pragma mark-
#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productsInSelectedCat.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"productListCell";
    STProductListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *prodDict = self.productsInSelectedCat[indexPath.row];
    NSString *prodId = prodDict[@"product_id"][@"__text"];
    NSString *name = prodDict[@"name"][@"__text"];
    NSArray *prodImgArr = (NSArray *)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
    if (prodImgArr.count) {
        id imgObj = prodImgArr;
        if ([imgObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *imgUrlDict = (NSDictionary *)imgObj;
            NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
            dbLog(@"Image URL %@",imgUrl);
            [self loadProdImageinView:cell.productImageView fromURL:imgUrl];
        }
        else if ([imgObj isKindOfClass:[NSArray class]]) {
            NSDictionary *imgUrlDict = [prodImgArr lastObject];
            NSString *imgUrl = imgUrlDict[@"url"][@"__text"];
            dbLog(@"Image URL %@",imgUrl);
            [self loadProdImageinView:cell.productImageView fromURL:imgUrl];
        }
        
    }
    cell.productTitleLabel.text = [name uppercaseString];
    
    //    cell.productImageView.contentMode = UIViewContentModeScaleToFill;
    
    return cell;
}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    STProductCategoryHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"productCategoryHeader" forIndexPath:indexPath];
//    headerView.titleLabel.text = @"Explore our Range of Teas";
//    return headerView;
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGSize size = CGSizeZero;
//    if (self.view.bounds.size.width > self.view.bounds.size.height) {
//        // landscape
//        size = CGSizeMake(collectionView.frame.size.width/4-.5, 117);
//    }else {
//        //potrait
//        size = CGSizeMake(collectionView.frame.size.width/3-.5, 117);
//    }
//
//    return size;
//}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGSize size = CGSizeZero;
//
//    CGFloat collHeight = self.view.frame.size.height;
//    CGFloat collWidth = self.view.frame.size.width;
//
//    switch (indexPath.row) {
//        case 0:
//        {
//            size = CGSizeMake(collWidth, collHeight/2);
//        }break;
//
//        case 1:
//        {
//            size = CGSizeMake(collWidth, collHeight/5);
//        }break;
//
//        default:{
//            size = CGSizeMake((collWidth/2)-3, collHeight/5);
//        }
//            break;
//    }
//
//    return size;
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([STUtility isNetworkAvailable]) {
        selectedProductIndex = indexPath.row;
        NSDictionary *prodDict = self.productsInSelectedCat[selectedProductIndex];
        NSString *prodId = prodDict[@"product_id"][@"__text"];
        NSDictionary*xmlDic = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kProductInfo_Key(prodId)];
        if (xmlDic) {
            [self parseResponseWithDict:xmlDic];
        }
        else{
            [self fetchProductDetails];
        }
    }
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 5.01f;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 5.01f;
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeZero;
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeZero;
//}


#pragma mark -
#pragma UIViewController device rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = [self numberOfPages];
    [self.view bringSubviewToFront:self.pageControl];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (void)fetchProductDetails {
    
    [STUtility startActivityIndicatorOnView:nil withText:@"Brewing"];
    
    NSDictionary *prodDict = self.productsInSelectedCat[selectedProductIndex];
    NSString *prodId = prodDict[@"product_id"][@"__text"];
    NSString *requestBody = [STConstants prodInfoRequestBodyWithID:prodId];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      dispatch_async(dispatch_get_main_queue(), ^{

                                          NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                          [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic
                                                                                        withKey:kProductInfo_Key(prodId)];
                                          
                                          dbLog(@"%@",xmlDic);
                                          [self parseResponseWithDict:xmlDic];
                                      });
                                      
                                      
                                  }
                                                       failureBlock:^(NSError *error) {
                                                           [STUtility stopActivityIndicatorFromView:nil];
                                                           [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                                       message:@"Unexpected error has occured, Please try after some time."
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles: nil] show];
                                                           dbLog(@"SublimeTea-STProductViewController-fetchProductDetails:- %@",error);
                                                       }];
    
    [httpRequest start];
}
- (void)parseResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:catalogProductInfoResponse"][@"info"];
            if(dataDict) {
                prodDetailDict = dataDict;
                [self performSegueWithIdentifier:@"productDetailViewSegue" sender:self];
            }
        }
        else {
            [AppDelegate startSession];
            [self fetchProductDetails];
        }
        
    }else {
        //No products found.
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
                                       dbLog(@"SublimeTea-STProductViewController-loadProdImageinView:- %@",error);
                                   }];
        }
    }
}



- (void)fetchProducts {
    NSString *requestBody = [STConstants productListRequestBody];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                          [[STGlobalCacheManager defaultManager] addItemToCache:xmlDic
                                                                                        withKey:kProductList_Key];
                                          dbLog(@"Product list for category :%@ ---- %@",self.selectedCategoryDict,xmlDic);
                                          
                                          [self parseProductResponseWithDict:xmlDic];
                                      });
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      dbLog(@"SublimeTea-STSignUpViewController-fetchProductCategories:- %@",error);
                                  }];
    
    [httpRequest start];
}

- (void)parseProductResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSArray *allProductsArr = parentDataDict[@"ns1:catalogProductListResponse"][@"storeView"][@"item"];
            if (self.stringToSearch.length) {
                
                self.productsInSelectedCat = [self searchProducts:nil];
                dbLog(@"%@",self.productsInSelectedCat);
            }
            else {
                NSDictionary *selectedProdCatDict = self.selectedCategoryDict;
                NSString *selectedCategoryId = selectedProdCatDict[@"category_id"][@"__text"];
                
                NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"category_ids.item.__text LIKE %@",selectedCategoryId];
                NSArray *productsInSelectedCat = [allProductsArr filteredArrayUsingPredicate:filterPredicate];
                self.productsInSelectedCat = [NSArray arrayWithArray:productsInSelectedCat];
            }
            
            for (NSDictionary *prodDict in self.productsInSelectedCat) {
                NSString *prodId = prodDict[@"product_id"][@"__text"];
                NSDictionary *imgXMLDict = (NSDictionary*)[[STGlobalCacheManager defaultManager] getItemForKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
                
                if (!imgXMLDict) {
                    //                    [self performSelector:@selector(fetchProductImages:) withObject:prodId afterDelay:0.5];
                    [self fetchProductImages:prodId];
                }
            }
            [self.collectionView reloadData];
        }
        else {
            [AppDelegate startSession];
            [self fetchProducts];
        }
    }else {
        //No products found.
    }
    [STUtility stopActivityIndicatorFromView:nil];
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
    //    dbLog(@"Image Data for ID %d %@",prodId, xmlDic);
    [self parseImgData:xmlDic andProdId:prodId];
}
- (void)parseImgData:(NSDictionary *)responseDict andProdId:(NSString *)prodId {
    if(responseDict){
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        //        dbLog(@"Image Data for ID %d %@",prodId, responseDict);
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *imgDataDict = parentDataDict[@"ns1:catalogProductAttributeMediaListResponse"][@"result"];
            NSArray *imageURLList = imgDataDict[@"item"];
            if (imageURLList) {
                [[STGlobalCacheManager defaultManager] addItemToCache:imageURLList withKey:[NSString stringWithFormat:@"PRODIMG_%@",prodId]];
            }
        }
        else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT"
//                                                                object:nil];
        }
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
@end
