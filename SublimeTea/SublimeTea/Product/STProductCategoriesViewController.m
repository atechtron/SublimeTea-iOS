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
#import "STGlobalCacheManager.h"

@interface STProductCategoriesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate>
{
    NSInteger selectedCatId;
}
@end

@implementation STProductCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone-category-line seperator"]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.titleLabel.text = @"Explore our Range of Teas";
//    self.pageControl.currentPage = 0;
//    self.pageControl.numberOfPages = [self numberOfPages];
//    [self.view bringSubviewToFront:self.pageControl];
    self.pageControl.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    if ([STUtility isNetworkAvailable]) {
        [STUtility startActivityIndicatorOnView:nil withText:@"Brewing"];
        NSDictionary *xmlDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kProductCategory_Key];
        if (xmlDict) {
            [self parseResponseWithDict:xmlDict];
        }
        else {
            [self fetchProductCategories];
        }
    }
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
        vC.selectedCategoryDict = self.prodCategories[selectedCatId];
    }
}

#pragma mark-
#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.prodCategories.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ProductCategoryCell";
    STProductCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *prodDict = self.prodCategories[indexPath.row];
    NSString *name = prodDict[@"name"][@"__text"];
    switch (indexPath.row) {
        case 0:
            cell.categoryImageView.image = [UIImage imageNamed:@"category_tea1"];
            break;
        case 1:
            cell.categoryImageView.image = [UIImage imageNamed:@"category_tea2"];
            break;
            
        case 2:
            cell.categoryImageView.image = [UIImage imageNamed:@"category_tea3"];
            break;
        case 3:
            cell.categoryImageView.image = [UIImage imageNamed:@"category_tea4"];
            break;
        case 4:
            cell.categoryImageView.image = [UIImage imageNamed:@"category_tea5"];
            break;
            
        default:
            break;
    }
    cell.categoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.categoryTitlelabel.text = [name uppercaseString];
    cell.categorySubTitleLabel.text = @"RANGE PER 100GM";
    return cell;
}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    STProductCategoryHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"productCategoryHeader" forIndexPath:indexPath];
//    headerView.titleLabel.text = @"Explore our Range of Teas";
//    return headerView;
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([STUtility isNetworkAvailable]) {
        selectedCatId = indexPath.row;
        [self performSegueWithIdentifier:@"productListSegue" sender:self];
    }
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
    dbLog(@"%f",self.collectionView.contentOffset.x);
    [self.view bringSubviewToFront:self.pageControl];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (void)fetchProductCategories {
    
    NSString *requestBody = [STConstants categoryListRequestBody];
    
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
                                                                                        withKey:kProductCategory_Key];
                                          dbLog(@"%@",xmlDic);
                                          
                                          [self parseResponseWithDict:xmlDic];
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
- (void)parseResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSArray *productCategoriesArr = responseDict[@"SOAP-ENV:Body"][@"ns1:catalogCategoryTreeResponse"][@"tree"][@"children"][@"item"][@"children"][@"item"][@"children"][@"item"];
            dbLog(@"%@",productCategoriesArr);
            if (productCategoriesArr.count) {
                self.prodCategories = [NSArray arrayWithArray:productCategoriesArr];
                [self.collectionView reloadData];
            }
            else{
                // No categories found.
            }
        }
        else {
            [AppDelegate startSession];
            [self fetchProductCategories];
        }
    }else {
        //No categories found.
    }
    [STUtility stopActivityIndicatorFromView:nil];
}


@end
