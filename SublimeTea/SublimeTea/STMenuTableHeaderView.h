//
//  TableHeaderView.h
//  ExpandableUITableViewPOC
//
//  Created by Arpit Mishra on 23/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//


#import <UIKit/UIKit.h>

@class STMenuTableHeaderView;

@protocol STMenuTableHeaderViewDelegate <NSObject>
- (void)didSelectHeader:(STMenuTableHeaderView *)header AtSectionIndex:(NSInteger )section;
@end

@interface STMenuTableHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *accesoryBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSInteger section;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageview;
@property (weak,nonatomic) id<STMenuTableHeaderViewDelegate> delegate;

- (IBAction)tapAction:(UIButton *)sender;
@end
