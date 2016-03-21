//
//  STTextField.m
//  SublimeTea
//
//  Created by Apple on 21/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STTextField.h"

IB_DESIGNABLE

@implementation STTextField

@synthesize padding;

-(CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, padding, padding);
}

-(CGRect)editingRectForBounds:(CGRect)bounds{
    return [self textRectForBounds:bounds];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
