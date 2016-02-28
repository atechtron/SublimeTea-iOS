//
//  STNavigationController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STNavigationController.h"
#import "REFrostedViewController.h"
#import "STMacros.h"

@interface STNavigationController ()

@end

@implementation STNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationBar setTranslucent:NO];
    /* Making Toolbar background color to white */
    [self.toolbar setBarTintColor:UIColorFromRGB(137, 90, 45, 1)];
    [self.navigationBar setBarTintColor:UIColorFromRGB(137, 90, 45, 1)];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    /* Making NavigationBar background color to white */
//    [self.navigationBar setBackgroundImage:[self getImageWithColor:UIColorFromRGB(137, 90, 45, 1)] forBarMetrics:UIBarMetricsDefault];

    /* Making NavigationBar Bottom shadow color to App Tint color */
    //    [[UINavigationBar appearance] setShadowImage:[UI_Utility getImageWithColor:[UI_Utility navigationBarShadowColor]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addBarButtons {
    self.navigationController.toolbarHidden = YES;
    UIBarButtonItem *addAcc = [[UIBarButtonItem alloc]
                               initWithTitle:@"Add"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(addNewAcc)];
    
    UIBarButtonItem *delAcc = [[UIBarButtonItem alloc]
                               initWithTitle:@"Del"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(DeleteButtonAction)];
    
    NSArray *arrBtns = [[NSArray alloc]initWithObjects:addAcc,delAcc, nil];
    self.navigationItem.rightBarButtonItems = arrBtns;
}
-(UIImage *)getImageWithColor:(UIColor *)color
{
    UIImage *img = [UIImage imageNamed:@"gray-border.png"];
    
    // Make a rectangle the size of your image
    CGRect rect = CGRectMake(0, 0, 600, 30);
    // Create a new bitmap context based on the current image's size and scale, that has opacity
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, img.scale);
    // Get a reference to the current context (which you just created)
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Draw your image into the context we created
    [img drawInRect:rect];
    // Set the fill color of the context
    CGContextSetFillColorWithColor(c, [color CGColor]);
    // This sets the blend mode, which is not super helpful. Basically it uses the your fill color with the alpha of the image and vice versa. I'll include a link with more info.
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    // Now you apply the color and blend mode onto your context.
    CGContextFillRect(c, rect);
    // You grab the result of all this drawing from the context.
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    // And you return it.
    return result;
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController panGestureRecognized:sender];
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
