//
//  STProductCategoriesViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STProductCategoriesViewController.h"
#import "STProductCategoryCollectionViewCell.h"
#import "STHttpRequest.h"
#import "STProductViewController.h"

@interface STProductCategoriesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate>
{
    NSInteger selectedCatId;
}
@end

@implementation STProductCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.titleLabel.text = @"Explore our Range of Teas";
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [self numberOfPages];
    [self.view bringSubviewToFront:self.pageControl];
}
- (NSInteger)numberOfPages {
    NSInteger singlePageElementHeightCount = 0;
    NSInteger singlePageElementWidthCount = 0;
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        // landscape
        singlePageElementWidthCount = 3;
        singlePageElementHeightCount = floor(self.collectionView.frame.size.width/150);
    }else {
        //potrait
        singlePageElementWidthCount = 2;
        singlePageElementHeightCount = floor(self.collectionView.frame.size.width/150);
    }
    
    NSInteger totalPages = ceil(20 /(singlePageElementHeightCount*singlePageElementWidthCount));
    return totalPages+1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    [self.pageControl setCurrentPage:page];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"productListSegue"]) {
        STProductViewController *vC = segue.destinationViewController;
        vC.productsInSelectedCat = self.prodCategories[selectedCatId];
    }
}

#pragma mark-
#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;//self.prodCategories.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ProductCategoryCell";
    STProductCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.categoryImageView.image = [UIImage imageNamed:@"teaCup.jpeg"];
    cell.categoryTitlelabel.text = [NSString stringWithFormat:@"%@\n%@",@"FLAVOURED",@"GREEN TEA"];
    cell.categorySubTitleLabel.text = @"RANGE PER 100GM";
    return cell;
}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    STProductCategoryHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"productCategoryHeader" forIndexPath:indexPath];
//    headerView.titleLabel.text = @"Explore our Range of Teas";
//    return headerView;
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [STUtility startActivityIndicatorOnView:nil withText:@"Loading Teas, Please wait.."];
    selectedCatId = indexPath.row;
    [self fetchProducts];
//    [self performSegueWithIdentifier:@"productListSegue" sender:self];
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(10,0,10,0);  // top, left, bottom, right
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        // landscape
       size = CGSizeMake(collectionView.frame.size.width/3-.5, 150);
    }else {
        //potrait
     size = CGSizeMake(collectionView.frame.size.width/2-.5, 150);
    }
    
    return size;
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
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
    
    self.pageControl.numberOfPages = [self numberOfPages];
    NSLog(@"%f",self.collectionView.contentOffset.x);
    [self.view bringSubviewToFront:self.pageControl];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)fetchProducts {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId = [defaults objectForKey:kUSerSession_Key];
    
    NSDictionary *selectedProdCatDict = self.prodCategories[selectedCatId];
    NSString *selectedCategoryId = selectedProdCatDict[@""];
    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:catalogProductInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                             "<productId xsi:type=\"xsd:string\">%@</productId>"
                             "<storeView xsi:type=\"xsd:string\">%@</storeView>"
                             "<attributes xsi:type=\"urn:catalogProductRequestAttributes\">"
                             "</urn:catalogProductInfo>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",sessionId,selectedCategoryId,@"default"];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                      NSLog(@"%@",xmlDic);
                                      
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      
                                      [self performSelector:@selector(loadProductCategories) withObject:nil afterDelay:0.4];
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      NSLog(@"SublimeTea-STSignUpViewController-fetchProductCategories:- %@",error);
                                  }];
    
    [httpRequest start];
}
- (void)loadProductCategories {
    [self performSegueWithIdentifier:@"productListSegue" sender:self];
}

@end
