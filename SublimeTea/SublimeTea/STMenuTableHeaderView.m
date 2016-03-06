//
//  TableHeaderView.m
//  ExpandableUITableViewPOC
//
//  Created by Arpit Mishra on 23/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STMenuTableHeaderView.h"

@implementation STMenuTableHeaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    if (_section == 2) {
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tapAction:)];
        [self addGestureRecognizer:singleFingerTap];
//    }
}


- (IBAction)tapAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectHeader:AtSectionIndex:)]) {
        [self.delegate didSelectHeader:self AtSectionIndex:self.section];
    }
}
@end
