//
//  STMenuTableViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STMenuTableViewController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "STMenuTableHeaderView.h"
#import "STMenuTableViewCell.h"
#import "STMenuUserInfoTableHeaderView.h"

@interface STMenuTableViewController ()<STMenuTableHeaderViewDelegate>
@property (strong, nonatomic)NSMutableArray *dataArr;
@property (strong, nonatomic)NSArray *sectionTitleDataArr;
@end

@implementation STMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMenuTableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STMenuTableHeaderView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMenuUserInfoTableHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"STMenuUserInfoTableHeaderView"];
    
    self.dataArr = [NSMutableArray new];
    self.sectionTitleDataArr = @[@"HOME",@"OUR RANGE",@"OUR RECENTLY VIEWED ITEMS",@"YOUR ORDERS",@"YOUR ACCOUNT",@"CUSTOMER SUPPORT",@"FAQ",@"LOGOUT"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitleDataArr.count +1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 2)
        count = self.dataArr.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView;
    if (section == 0) {
        STMenuUserInfoTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STMenuUserInfoTableHeaderView"];
        headerView.contentView.backgroundColor = [UIColor brownColor];
        headerView.tintColor = [UIColor clearColor];
        sectionHeaderView = headerView;
        headerView.TitleLabel.text = @"NEHA JAIN";
        headerView.subTitleLabel.text = @"neha@webenza.com";
    }
    else {
        STMenuTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"STMenuTableHeaderView"];
        sectionHeaderView = headerView;
        headerView.section = section;
        headerView.delegate = self;
        
        headerView.titleLabel.text = self.sectionTitleDataArr[section-1];
        if (section == 2) {
            //        CALayer* layer = [headerView.titleLabel layer];
            
            //        CAGradientLayer *gradient = [CAGradientLayer layer];
            //        gradient.frame = headerView.titleLabel.bounds;
            //        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
            //        [headerView.titleLabel.layer insertSublayer:gradient atIndex:0];
            
            
            
            
            //        CALayer *bottomBorder = [CALayer layer];
            //        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            //        bottomBorder.borderWidth = 1;
            //        bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1, layer.frame.size.width, 1);
            //        [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
            //        [layer addSublayer:bottomBorder];
            
            headerView.accesoryBtn.hidden = NO;
        }
        else {
            headerView.accesoryBtn.hidden = YES;
        }
    }
    return sectionHeaderView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerViewHeight = 44;
    if (section == 0) {
        headerViewHeight = 120;
    }
    return headerViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (void)didSelectHeaderAtSectionIndex:(NSInteger )section {
    NSLog(@"SectionClicked %ld",section);
    if (section == 2 && self.dataArr.count == 0) {
        [self.dataArr addObjectsFromArray:@[@"flavoured green tea",@"pure green tea",@"limited edition tea",@"tisane",@"flavoured white tea",@"flavoured black tea"]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        if(section == 2){
            [self.dataArr removeAllObjects];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
