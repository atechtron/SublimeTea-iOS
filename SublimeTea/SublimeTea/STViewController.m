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
#import "STUtility.h"

#define kSearchBarTag 979742

@interface STViewController ()<UISearchBarDelegate>
{
    CGRect navBarLeftContainerRect;
    CGRect navBarRightContainerRect;
    UISearchBar  *sBar;
    UIButton *searchButton;
    NSMutableArray *rightBarItems;
    NSMutableArray *leftBarItems;
    UIBarButtonItem *searchItem;
    UIBarButtonItem *searchBarItem;
}

@property (strong,nonatomic)NSString *searchString;
@end

@implementation STViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.hidesBackButton = YES;
    navBarLeftContainerRect = CGRectMake(-5, 0, 110, 40);
    rightBarItems = [NSMutableArray new];
    leftBarItems = [NSMutableArray new];
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
    
    UIImage *image =[UIImage imageNamed:@"cancel_image"];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setImage:image];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitle:@""];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[STUtility getSublimeHeadingBGColor]];
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
    [self hideSearchBar];
}
- (void)viewDidDisappear:(BOOL)animated {
    [self hideSearchBar];
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
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *menuBtnImg = [UIImage imageNamed:@"menu"];
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(backButton.frame.origin.x + 35, backButton.frame.origin.y, menuBtnImg.size.width, menuBtnImg.size.height)];
    [menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(slideMenuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *leftContainerView = [[UIView alloc] initWithFrame:navBarLeftContainerRect];
    leftContainerView.backgroundColor = [UIColor clearColor];
    [leftContainerView addSubview:backButton];
    [leftContainerView addSubview:menuButton];
    UIBarButtonItem *leftBarButton;
    
    
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    if (self.menuButtonHidden) {
        leftBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
    }
    else if (self.backButtonHidden) {
        leftBarButton =[[UIBarButtonItem alloc]initWithCustomView:menuButton];
    }
    else {
        [leftBarItems addObjectsFromArray:@[backBtnItem,menuBtnItem]];
    }
    
    if (leftBarButton) {
        self.navigationItem.leftBarButtonItem = leftBarButton;
    }
    else if (leftBarItems.count > 0) {
        self.navigationItem.leftBarButtonItems = leftBarItems;
    }
}

- (void)addRightBarItemsWithFrame:(CGRect)btnFrame {
    
    double totalWidth = self.view.bounds.size.width;
    UIImage *cartBtnImg = [UIImage imageNamed:@"cart"];
    CGRect cartRect = CGRectMake(totalWidth-140, btnFrame.origin.y, cartBtnImg.size.width+5, cartBtnImg.size.height);
//    CGRect accountRect = CGRectMake(accountBtnOrigin_X, btnFrame.origin.y-5 , btnFrame.size.width + 10, btnFrame.size.height);
    
    
    // Add cart button
    UIButton *cartButton = [[UIButton alloc] initWithFrame:cartRect];
    cartButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [cartButton setImage:cartBtnImg forState:UIControlStateNormal];
    [cartButton addTarget:self action:@selector(cartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cartBadgeView = [[JSBadgeView alloc] initWithParentView:cartButton alignment:JSBadgeViewAlignmentTopRight];
    cartBadgeView.badgeAlignment = JSBadgeViewAlignmentTopCenter;
    NSString *cartCount = [NSString stringWithFormat:@"%ld",(long)[[STCart defaultCart] numberOfProductsInCart]];
    cartBadgeView.badgeText = [cartCount integerValue]>0?cartCount:@"";
    cartBadgeView.badgeTextFont = [UIFont fontWithName:@"Helvetica" size:10];
    cartBadgeView.badgeBackgroundColor = [UIColor clearColor];
    
    
    // Add account button
    NSInteger accountBtnOrigin_X = totalWidth - cartButton.frame.size.width - 180;
    UIButton *accountButton = [[UIButton alloc] initWithFrame:CGRectMake(accountBtnOrigin_X, btnFrame.origin.y-5 , btnFrame.size.width + 10, btnFrame.size.height)];
    accountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [accountButton setImage:[UIImage imageNamed:@"user_icon"] forState:UIControlStateNormal];
    [accountButton addTarget:self action:@selector(accountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Add search icon
    NSInteger searchBtnOrigin_X = totalWidth - (cartButton.frame.size.width + accountButton.frame.size.width + 152);
    UIImage *searchBtnImg = [UIImage imageNamed:@"search_btn"];
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(searchBtnOrigin_X, btnFrame.origin.y, searchBtnImg.size.width, searchBtnImg.size.height)];
    searchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [searchButton setImage:searchBtnImg forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger viewWidth = searchBtnImg.size.width + cartBtnImg.size.width + accountButton.frame.size.width +20;
    navBarRightContainerRect = CGRectMake(0, 0, viewWidth, self.navigationController.navigationBar.bounds.size.height/2);
    
    
    double extraPadding =   0;
    double freeSpaceWidth = totalWidth - (navBarLeftContainerRect.size.width + navBarRightContainerRect.size.width) - extraPadding;
    freeSpaceWidth += searchButton.frame.size.width;
    sBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,5,freeSpaceWidth,self.navigationController.navigationBar.bounds.size.height/2)];
    sBar.tag = kSearchBarTag;
    sBar.delegate = self;
    [sBar becomeFirstResponder];

    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
    UIBarButtonItem *accountItem = [[UIBarButtonItem alloc] initWithCustomView:accountButton];
    searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:sBar];
    
    [rightBarItems addObjectsFromArray:@[cartItem,accountItem,searchItem]];
    self.navigationItem.rightBarButtonItems = rightBarItems;
}

#pragma mark-
#pragma RightBarButtonItems Action

- (void)searchButtonAction:(UIButton *)sender {
    NSUInteger idx = [rightBarItems indexOfObject:searchItem];
    if (idx != NSNotFound) {
        [rightBarItems removeObjectIdenticalTo:searchItem];
        [rightBarItems addObject:searchBarItem];
        self.navigationItem.rightBarButtonItems = rightBarItems;
        [sBar becomeFirstResponder];
    }
}
- (void)hideSearchBar {
    NSUInteger idx = [rightBarItems indexOfObject:searchBarItem];
    if (idx != NSNotFound) {
        [sBar resignFirstResponder];
        [rightBarItems removeObjectIdenticalTo:searchBarItem];
        [rightBarItems addObject:searchItem];
        self.navigationItem.rightBarButtonItems = rightBarItems;
    }
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
    [self hideSearchBar];
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

#pragma mark-
#pragma UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.tintColor = [UIColor grayColor];
    searchBar.showsCancelButton = YES;
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    // The user clicked the [X] button or otherwise cleared the text.
    if([searchText length] == 0) {
        [self performSelector: @selector(hideSearchBar)
                        withObject: nil
                        afterDelay: 0.1];
    }
}

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
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchBar];
}
@end
