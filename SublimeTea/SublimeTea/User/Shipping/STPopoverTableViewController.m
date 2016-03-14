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

@end

@implementation STPopoverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillLayoutSubviews {
    self.preferredContentSize = CGSizeMake(150, 300);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSDictionary *countriesDict = (NSDictionary *)[[STGlobalCacheManager defaultManager] getItemForKey:kCountries_key];
        NSDictionary *datadict = countriesDict[[self.itemsArray objectAtIndex:indexPath.row]];
        NSLog(@"%@",datadict);
        cell.titleTextLabel.text = datadict[@"name"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(itemDidSelect:)]) {
        [self.delegate itemDidSelect:indexPath];
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
