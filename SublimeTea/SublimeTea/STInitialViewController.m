//
//  STInitialViewController.m
//  SublimeTea
//
//  Created by Apple on 21/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STInitialViewController.h"

@interface STInitialViewController ()

@end

@implementation STInitialViewController

- (void)viewDidLoad {
//    self.backButtonHidden = YES;
    [super viewDidLoad];
//    [self.navigationController setNavigationBarHidden:YES];
    self.backgroundImageView.image = [UIImage imageNamed:@"launchImage"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}
-(BOOL)prefersStatusBarHidden {
    return YES;
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
