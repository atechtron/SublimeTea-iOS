//
//  ViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"
#import "JSBadgeView.h"
#import "STCartViewController.h"

@interface STViewController ()

@end

@implementation STViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.hidesBackButton = YES;
     [self addNavBarButtons];
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)addNavBarButtons {
    CGRect btnFrame = CGRectMake(0, 5, 50, 30);
    
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
    UIButton *backButton = [[UIButton alloc] initWithFrame:btnFrame];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x + 55, btnFrame.origin.y, btnFrame.size.width, btnFrame.size.height)];
    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(slideMenuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 40)];
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
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x, btnFrame.origin.y, btnFrame.size.width, btnFrame.size.height)];
    searchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *accountButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x + 55, btnFrame.origin.y , btnFrame.size.width + 10, btnFrame.size.height)];
    accountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [accountButton setTitle:@"My Account" forState:UIControlStateNormal];
    [accountButton addTarget:self action:@selector(accountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(btnFrame.origin.x + 115, btnFrame.origin.y + 1, btnFrame.size.width - 15.5, btnFrame.size.height)];
    cartButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [cartButton setTitle:@"Cart" forState:UIControlStateNormal];
    [cartButton addTarget:self action:@selector(cartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cartButton alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgeAlignment = JSBadgeViewAlignmentTopCenter;
    badgeView.badgeText = @"3";
    
    
    UIView *rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    rightContainerView.backgroundColor = [UIColor clearColor];
    [rightContainerView addSubview:searchButton];
    [rightContainerView addSubview:accountButton];
    [rightContainerView addSubview:cartButton];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightContainerView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

#pragma mark-
#pragma RightBarButtonItems Action

- (void)searchButtonAction:(id)sender {
    
}
- (void)accountButtonAction:(id)sender {
    
}
- (void)cartButtonAction:(id)sender {
    STCartViewController *cartViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STCartViewController"];
    [self.navigationController pushViewController:cartViewController animated:YES];
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
@end
