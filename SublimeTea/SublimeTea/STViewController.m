//
//  ViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"
#import "STCartViewController.h"
#import "STUserProfileViewController.h"
#import "STCart.h"
#import "STLoginViewController.h"
#import "STSignUpViewController.h"
#import "STProductViewController.h"

@interface STViewController ()<UISearchBarDelegate>

@property (strong,nonatomic)NSString *searchString;
@end

@implementation STViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.hidesBackButton = YES;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
//    [self.view addGestureRecognizer:tap];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
     [self addNavBarButtons];
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    NSString *cartCount = [NSString stringWithFormat:@"%ld",(long)[[STCart defaultCart] numberOfProductsInCart]];
    cartBadgeView.badgeText = [cartCount integerValue]>0?cartCount:@"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}
- (void)addNavBarButtons {
    CGRect btnFrame = CGRectMake(0, 5, 50, 30);
    
//    NSInteger count = self.navigationController.viewControllers.count;
//    if (count > 0) {
//        id topViewController = [self.navigationController viewControllers][count-1];
//        if ([topViewController isKindOfClass:[STLoginViewController class]] || [topViewController isKindOfClass:[STSignUpViewController class]]) {
//            self.backButtonHidden = YES;
//        }
//    }
    
    
    if (!self.hideLeftBarItems) {
        // Add left bar buttons
        [self addLeftBarItemsWithFrame:btnFrame];
    }

    if (!self.hideRightBarItems) {
        // Add right bar buttons
        [self addRightBarItemsWithFrame:btnFrame];
    }
}

- (void)addLeftBarItemsWithFrame:(CGRect)btnFrame {
    
    UIImage *backBtnImg = [UIImage imageNamed:@"back_Btn"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x, btnFrame.origin.y, backBtnImg.size.width, backBtnImg.size.height)];
    [backButton setImage:backBtnImg forState:UIControlStateNormal];
//    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *menuBtnImg = [UIImage imageNamed:@"menu"];
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(backButton.frame.origin.x + 35, backButton.frame.origin.y, menuBtnImg.size.width, menuBtnImg.size.height)];
//    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(slideMenuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, 110, 40)];
    leftContainerView.backgroundColor = [UIColor clearColor];
    [leftContainerView addSubview:backButton];
    [leftContainerView addSubview:menuButton];
    UIBarButtonItem *leftBarButton;
    
    if (self.menuButtonHidden) {
        leftBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
    }
    else if (self.backButtonHidden) {
        leftBarButton =[[UIBarButtonItem alloc]initWithCustomView:menuButton];
    }
    else {
        leftBarButton =[[UIBarButtonItem alloc]initWithCustomView:leftContainerView];
    }
    
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (void)addRightBarItemsWithFrame:(CGRect)btnFrame {
    
    UIImage *searchBtnImg = [UIImage imageNamed:@"search_btn"];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x, btnFrame.origin.y, searchBtnImg.size.width, searchBtnImg.size.height)];
    searchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [searchButton setImage:searchBtnImg forState:UIControlStateNormal];
//    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *accountButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x + 35, btnFrame.origin.y-10 , btnFrame.size.width + 10, btnFrame.size.height)];
    accountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [accountButton setTitle:@"My Account" forState:UIControlStateNormal];
    [accountButton addTarget:self action:@selector(accountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *cartBtnImg = [UIImage imageNamed:@"cart"];
     UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x + 105, btnFrame.origin.y, cartBtnImg.size.width+5, cartBtnImg.size.height)];
    cartButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [cartButton setImage:cartBtnImg forState:UIControlStateNormal];
//    [cartButton setTitle:@"Cart" forState:UIControlStateNormal];
    [cartButton addTarget:self action:@selector(cartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cartBadgeView = [[JSBadgeView alloc] initWithParentView:cartButton alignment:JSBadgeViewAlignmentTopRight];
    cartBadgeView.badgeAlignment = JSBadgeViewAlignmentTopCenter;
    NSString *cartCount = [NSString stringWithFormat:@"%ld",(long)[[STCart defaultCart] numberOfProductsInCart]];
    cartBadgeView.badgeText = [cartCount integerValue]>0?cartCount:@"";
    cartBadgeView.badgeTextFont = [UIFont fontWithName:@"Helvetica" size:10];
    cartBadgeView.badgeBackgroundColor = [UIColor clearColor];
    
    NSInteger viewWidth = searchBtnImg.size.width + cartBtnImg.size.width + accountButton.frame.size.width +20;
    UIView *rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 30)];
    rightContainerView.backgroundColor = [UIColor clearColor];
    [rightContainerView addSubview:searchButton];
    [rightContainerView addSubview:accountButton];
    [rightContainerView addSubview:cartButton];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightContainerView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

#pragma mark-
#pragma RightBarButtonItems Action

- (void)searchButtonAction:(UIButton *)sender {
    UIView *containerView = sender.superview;
    UISearchBar  *sBar = [[UISearchBar alloc]initWithFrame:CGRectMake(containerView.frame.origin.x-150,10,175,self.navigationController.navigationBar.bounds.size.height/2)];
    [sBar becomeFirstResponder];
    sBar.delegate = self;
    [self.navigationController.navigationBar addSubview:sBar];
}
- (void)accountButtonAction:(id)sender {
    UIViewController *currentViewCtrl = self.navigationController.topViewController;
    if (![currentViewCtrl isKindOfClass:[STUserProfileViewController class]]) {
        STUserProfileViewController *accountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STUserProfileViewController"];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}
- (void)cartButtonAction:(id)sender {
    UIViewController *currentViewCtrl = self.navigationController.topViewController;
    if (![currentViewCtrl isKindOfClass:[STCartViewController class]]) {
        STCartViewController *cartViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STCartViewController"];
        [self.navigationController pushViewController:cartViewController animated:YES];
    }
}

#pragma mark-
#pragma LeftBarButtonItems Action

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)slideMenuButtonAction:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

#pragma mark-
#pragma UISearchBarDelegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSString *searchBarStr = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.searchString = searchBarStr;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    
    NSString *searchBarStr = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.searchString = searchBarStr;
    [searchBar resignFirstResponder];
//    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
//    [viewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:[STProductViewController class]]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                STProductViewController *productList = (STProductViewController *)obj;
//                productList.stringToSearch = self.searchString;
//                [self.navigationController popToViewController:productList animated:YES];
//            });
//            *stop = YES;
//        }
//        if(*stop == YES) {
            STProductViewController *prod = [self.storyboard instantiateViewControllerWithIdentifier:@"STProductViewController"];
            prod.stringToSearch = self.searchString;
            [self.navigationController pushViewController:prod animated:YES];
//        }
//    }];
}

@end
