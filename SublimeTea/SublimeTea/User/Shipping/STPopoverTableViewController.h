//
//  STPopoverTableViewController.h
//  SublimeTea
//
//  Created by Arpit on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STPopoverTableViewControllerDelegate<NSObject>
- (void)itemDidSelect:(NSIndexPath *)indexpath selectedItemString:(NSString *)selectedItemStr;
@end

@interface STPopoverTableViewController : UITableViewController

@property (strong, nonatomic)NSArray *itemsArray;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)id <STPopoverTableViewControllerDelegate> delegate;
@end
