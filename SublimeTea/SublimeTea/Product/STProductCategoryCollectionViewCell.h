//
//  STProductCategoryCollectionViewCell.h
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STProductCategoryCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitlelabel;
@property (weak, nonatomic) IBOutlet UILabel *categorySubTitleLabel;

@end
