//
//  STCartFooterView.h
//  SublimeTea
//
//  Created by Arpit Mishra on 27/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCartFooterView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UIView *topBorderView;

@end
