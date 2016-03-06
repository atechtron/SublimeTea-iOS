//
//  STRootViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STRootViewController.h"
#import "STMacros.h"

@interface STRootViewController ()

@end

@implementation STRootViewController

- (void)awakeFromNib
{
//    STDashboardViewController
    NSString *identifier = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey:kUSerSession_Key];
    if ([defaults objectForKey:kUSerSession_Key]) {
        identifier = @"dashBoardNavController";
    }
    else {
        identifier = @"contentController";
    }
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
