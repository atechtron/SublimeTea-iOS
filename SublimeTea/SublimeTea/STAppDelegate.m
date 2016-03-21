//
//  AppDelegate.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STAppDelegate.h"
#import "ResponseViewController.h"
#import "STGlobalCacheManager.h"
#import "STMacros.h"
#import "STConstants.h"
#import "STHttpRequest.h"
#import "XMLDictionary.h"
#import "STRootViewController.h"
#import "STPlaceOrder.h"

@interface STAppDelegate ()<UITextFieldDelegate>

@end

@implementation STAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // remove user session info
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kUSerSession_Key];
    [defaults synchronize];
    [self startSession];
    STPlaceOrder *order = [[STPlaceOrder alloc] init];
//    [order placeOrder];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[STGlobalCacheManager defaultManager] clearGlobalCache];
    [self endUserSession];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url)
    {
        return NO;
    }
    
    NSArray *parameterArray = [[url absoluteString] componentsSeparatedByString:@"?"];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    ResponseViewController *controller = (ResponseViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ResponseViewController"];
    
    controller.transaction_id=[parameterArray objectAtIndex:1];
    
    STRootViewController *rootViewController = (STRootViewController *)self.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController*)rootViewController.contentViewController;
    NSLog(@"%@",navigationController);
    [navigationController pushViewController:controller animated:YES];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url)
    {
        return NO;
    }
    
    NSArray *parameterArray = [[url absoluteString] componentsSeparatedByString:@"?"];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    ResponseViewController *controller = (ResponseViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ResponseViewController"];
    
    controller.transaction_id = [parameterArray objectAtIndex:1];
    STRootViewController *rootViewController = (STRootViewController *)self.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController*)rootViewController.contentViewController;
    NSLog(@"%@",navigationController);
    [navigationController pushViewController:controller animated:YES];
    
    return YES;
}
- (void)didStartNetworking
{
    if (self.networkActivityCounter >= 0) {
        self.networkActivityCounter += 1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)didStopNetworking
{
    if (self.networkActivityCounter > 0) {
        self.networkActivityCounter -= 1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkActivityCounter != 0);
    }
}
- (void)startSession {
    
//    [STUtility startActivityIndicatorOnView:nil withText:@"Initializing..."];
    
    NSString *requestBody = [STConstants startSessionRequestBody];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      
                                  }failureBlock:^(NSError *error) {
                                      
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      NSLog(@"SublimeTea-STSignUpViewController-startSession:- %@",error);
                                  }];
    
    NSData *responseData = [httpRequest synchronousStart];
    NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
    NSLog(@"%@",xmlDic);
    NSDictionary *resutDict = xmlDic[@"SOAP-ENV:Body"][@"ns1:loginResponse"][@"loginReturn"];
    NSString *sessionKey = resutDict[@"__text"];
    if (sessionKey.length) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:sessionKey forKey:kUSerSession_Key];
        [defaults synchronize];
    }
    //                                      [STUtility stopActivityIndicatorFromView:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APPVALIDATION" object:nil];
    [STUtility stopActivityIndicatorFromView:nil];
    //                                      [self performSelector:@selector(loadDashboard) withObject:nil afterDelay:0.4];
}
- (void)endUserSession {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userSessionId = [defaults objectForKey:kUSerSession_Key];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *requestBody = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:endSession soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                             "</urn:endSession>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",userSessionId];
    
    
    STHttpRequest *featureNSpecHttpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                     methodType:@"POST"
                                                                           body:requestBody
                                                            responseHeaderBlock:^(NSURLResponse *response)
                                              {
                                                  
                                              }successBlock:^(NSData *responseData){
                                                  NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                                  NSLog(@"%@",xmlDic);
                                                  NSDictionary *resultDict = xmlDic[@"SOAP-ENV:Body"][@"ns1:endSessionResponse"][@"endSessionReturn"];
                                                  if ([resultDict[@"__text"] boolValue]) {
                                                      [defaults removeObjectForKey:kUSerSession_Key];
                                                      [defaults synchronize];
                                                  }
                                                  [STUtility stopActivityIndicatorFromView:nil];
                                              }failureBlock:^(NSError *error) {
                                                  NSLog(@"SublimeTea-STAppDelegate-endUserSession:- %@",error);
                                                  [STUtility stopActivityIndicatorFromView:nil];
                                              }];
    
    [featureNSpecHttpRequest start];
}
@end
