//
//  STProductDetailViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STViewController.h"

@interface STProductDetailViewController : STViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSDictionary *productInfoDict;
@property (strong, nonatomic)NSDictionary *selectedProdDict;
@property (strong, nonatomic)NSDictionary *selectedCategoryDict;
@end
