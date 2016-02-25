//
//  STProductViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STProductViewController.h"
#import "STProductCategoryHeaderCollectionReusableView.h"
#import "STProductListCollectionViewCell.h"

@interface STProductViewController ()

@end

@implementation STProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
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
#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"productListCell";
    STProductListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.productTitleLabel.text = [NSString stringWithFormat:@"%@\n%@",@"GREEN",@"LONG DING"];
    cell.productImageView.image = [UIImage imageNamed:@"teaCup.jpeg"];
    cell.productImageView.contentMode = UIViewContentModeScaleToFill;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    STProductCategoryHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"productCategoryHeader" forIndexPath:indexPath];
    headerView.titleLabel.text = @"Explore our Range of Teas";
    return headerView;
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
    
    [self performSegueWithIdentifier:@"productDetailViewSegue" sender:self];
    
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
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
@end
