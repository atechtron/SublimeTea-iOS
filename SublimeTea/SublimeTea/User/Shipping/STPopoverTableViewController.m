//
//  STPopoverTableViewController.m
//  SublimeTea
//
//  Created by Arpit on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STPopoverTableViewController.h"
#import "STPopoverTableViewCell.h"
#import "STMacros.h"
#import "STGlobalCacheManager.h"

@interface STPopoverTableViewController ()
{
    NSArray *sortedItems;
}
@end

@implementation STPopoverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sortedItems = [self prepareData];
}
- (void)viewWillLayoutSubviews {
    self.preferredContentSize = CGSizeMake(150, 300);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray *)prepareData {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSMutableArray *tempDataArr = [NSMutableArray new];
    for (NSDictionary *itemDict in self.itemsArray) {
        [tempDataArr addObject:itemDict[@"name"]];
    }
    return [tempDataArr sortedArrayUsingDescriptors:@[sort]];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STPopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popoverCell" forIndexPath:indexPath];
    id itemObj = self.itemsArray[indexPath.row];
    if ([itemObj isKindOfClass:[NSNumber class]]) {
        cell.titleTextLabel.text = [NSString stringWithFormat:@"%@",itemObj];
    }
    else {
        cell.titleTextLabel.text = sortedItems[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id itemObj = self.itemsArray[indexPath.row];
    NSString *itemStr;
    if ([itemObj isKindOfClass:[NSNumber class]]) {
        itemStr = [NSString stringWithFormat:@"%@",itemObj];
    }
    else {
        itemStr = sortedItems[indexPath.row];
    }
    if ([self.delegate respondsToSelector:@selector(itemDidSelect:selectedItemString:)]) {
        [self.delegate itemDidSelect:indexPath selectedItemString:itemStr];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
