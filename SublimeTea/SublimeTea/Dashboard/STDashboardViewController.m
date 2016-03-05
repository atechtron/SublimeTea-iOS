//
//  STDashboardViewController.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STDashboardViewController.h"
#import "STHttpRequest.h"
#import "STProductCategoriesViewController.h"
#import "STDashboardCollectionViewCell.h"

@interface STDashboardViewController ()<UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic)NSArray *categories;
@end

@implementation STDashboardViewController

- (void)viewDidLoad {
    self.backButtonHidden = YES;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.scrollEnabled = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"productCategorySegue"]) {
        STProductCategoriesViewController *catVC = segue.destinationViewController;
        catVC.prodCategories = self.categories;
    }
}


#pragma mark-
#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"dashboardCell";
    STDashboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImage *img;
    switch (indexPath.row) {
        case 0:
            img = [UIImage imageNamed:@"tea_rangeImage"];
            break;
        case 1:
            img = [UIImage imageNamed:@"customerTestimonial"];
            break;
        case 2:
            img = [UIImage imageNamed:@"read-our-blog"];
            break;
        case 3:
            img = [UIImage imageNamed:@"tea-recipes"];
            break;
        default:
            break;
    }
    cell.OptionImageView.image = img;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    
    CGFloat collHeight = self.view.frame.size.height;
    CGFloat collWidth = self.view.frame.size.width;
    
    switch (indexPath.row) {
        case 0:
        {
            size = CGSizeMake(collWidth, collHeight/2);
        }break;
            
        case 1:
        {
            size = CGSizeMake(collWidth, collHeight/4);
        }break;
            
        default:{
            size = CGSizeMake((collWidth/2)-2, collHeight/4);
        }
            break;
    }
    
    return size;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [STUtility startActivityIndicatorOnView:nil withText:@"Loading Range of Teas, Please wait.."];
        [self fetchProductCategories];
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4.0f;
}

#pragma mark -
#pragma UIViewController device rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (IBAction)navBackButtonAction:(id)sender {
}

- (IBAction)menuButton:(UIButton *)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)cartButtonAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"carViewFromDashboardSegue" sender:self];
}
- (void)fetchProductCategories {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId = [defaults objectForKey:kUSerSession_Key];
    
    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:catalogCategoryTree soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                             "<parentId xsi:type=\"xsd:string\">%@</parentId>"
                             "<storeView xsi:type=\"xsd:string\">%@</storeView>"
                             "</urn:catalogCategoryTree>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",sessionId,@"2",@"default"];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                      NSLog(@"%@",xmlDic);
                                      
                                      [STUtility stopActivityIndicatorFromView:nil];
//                                      self.categories
                                      [self performSelector:@selector(loadProductCategories) withObject:nil afterDelay:0.4];
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      NSLog(@"SublimeTea-STSignUpViewController-fetchProductCategories:- %@",error);
                                  }];
    
    [httpRequest start];
}
- (void)loadProductCategories {
    [self performSegueWithIdentifier:@"productCategorySegue" sender:self];
}
@end
