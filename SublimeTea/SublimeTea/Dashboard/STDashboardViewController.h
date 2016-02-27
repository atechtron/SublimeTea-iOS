//
//  STDashboardViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STDashboardViewController : STViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *navigationBackButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)navBackButtonAction:(id)sender;
- (IBAction)menuButton:(UIButton *)sender;

- (IBAction)cartButtonAction:(UIBarButtonItem *)sender;
@end
