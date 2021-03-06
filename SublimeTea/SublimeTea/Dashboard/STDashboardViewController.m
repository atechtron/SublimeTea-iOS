//
//  STDashboardViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STDashboardViewController.h"
#import "STHttpRequest.h"
#import "STProductCategoriesViewController.h"
#import "STDashboardCollectionViewCell.h"
#import "STGlobalCacheManager.h"
#import "KASlideShow.h"

@interface STDashboardViewController ()<UICollectionViewDelegateFlowLayout,KASlideShowDelegate>
{
    KASlideShow *_slideshow;
}
@property (strong, nonatomic)NSArray *categories;
@end

@implementation STDashboardViewController

- (void)viewDidLoad {
    self.backButtonHidden = YES;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.scrollEnabled = NO;
    
//    STPlaceOrder *order = [[STPlaceOrder alloc] init];
//    [order placeOrder];

}
- (void)viewWillAppear:(BOOL)animated {
    if (!_slideshow.state) {
        [_slideshow start];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [_slideshow stop];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"productCategorySegue"]) {
//        STProductCategoriesViewController *catVC = segue.destinationViewController;
//        catVC.prodCategories = self.categories;
    }
}


#pragma mark-
#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"dashboardCell";
    STDashboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImage *img;
    switch (indexPath.row) {
        case 0:
            img = [UIImage imageNamed:@"tea_rangeImage"];
            break;
        case 1:
        {
            UIView *uiview = [cell.contentView viewWithTag:121333];
            if (!uiview) {
                CGFloat collHeight = self.view.frame.size.height;
                _slideshow = [[KASlideShow alloc] initWithFrame:CGRectMake(0, 0, collectionView.frame.size.width, collHeight/4+60)];
                _slideshow.delegate = self;
                _slideshow.tag = 121333;
                [_slideshow setDelay:3]; // Delay between transitions
                [_slideshow setTransitionDuration:1]; // Transition duration
                [_slideshow setTransitionType:KASlideShowTransitionSlide]; // Choose a transition type (fade or slide)
                [_slideshow setImagesContentMode:UIViewContentModeScaleAspectFit]; // Choose a content mode for images to display
                [_slideshow addImagesFromResources:@[@"customer-testimonial_01",@"customer-testimonial_02",@"customer-testimonial_03"]]; // Add images from resources
                [_slideshow addGesture:KASlideShowGestureTap]; // Gesture to go previous/next directly on the image
                [cell.contentView addSubview:_slideshow];
                [_slideshow start];
            }
            img = [UIImage imageNamed:@"customerTestimonial"];
            
            break;
        }
        case 2:
            img = [UIImage imageNamed:@"read-our-blog"];
            break;
        case 3:
            img = [UIImage imageNamed:@"tea-recipes"];
            break;
        default:
            break;
    }
    cell.OptionImageView.image = img;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    
    CGFloat collHeight = self.view.frame.size.height;
    CGFloat collWidth = self.view.frame.size.width;
    
    switch (indexPath.row) {
        case 0:
        {
            size = CGSizeMake(collWidth, collHeight/2);
        }break;
            
        case 1:
        {
            size = CGSizeMake(collWidth, collHeight/4);
        }break;
            
        default:{
            size = CGSizeMake((collWidth/2)-2, collHeight/4);
        }
            break;
    }
    
    return size;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self loadProductCategories];
    }
    else if (indexPath.row == 1) {
    
    }
    else if (indexPath.row == 2) {
        NSURL *url = [NSURL URLWithString:kBlogURL];
        if ([STUtility isNetworkAvailable] && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else if (indexPath.row == 3) {
        NSURL *url = [NSURL URLWithString:kTeaRecipes];
        if ([STUtility isNetworkAvailable] && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4.0f;
}

#pragma mark -
#pragma UIViewController device rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (IBAction)navBackButtonAction:(id)sender {
}

- (IBAction)menuButton:(UIButton *)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)cartButtonAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"carViewFromDashboardSegue" sender:self];
}

- (void)loadProductCategories {
    [self performSegueWithIdentifier:@"productCategorySegue" sender:self];
}

#pragma mark-
#pragma KASlideshowDelegate
- (void) kaSlideShowDidShowNext:(KASlideShow *) slideShow {
}
- (void) kaSlideShowDidShowPrevious:(KASlideShow *) slideShow {
}
- (void) kaSlideShowWillShowNext:(KASlideShow *) slideShow {
}
- (void) kaSlideShowWillShowPrevious:(KASlideShow *) slideShow {
}

@end
