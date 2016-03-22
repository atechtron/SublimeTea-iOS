//
//  STProductViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STProductViewController : STViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *productsInSelectedCat;
@property (strong, nonatomic)NSDictionary *selectedCategoryDict;
@property (strong, nonatomic)NSString *stringToSearch;

@end
