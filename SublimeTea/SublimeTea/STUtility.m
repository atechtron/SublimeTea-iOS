
//
//  STUtility.m
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STUtility.h"
#import "STMacros.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface STUtility()
{
    BOOL isShowingNoNetworkAlert;
}
@end

@implementation STUtility

+ (BOOL)isNetworkAvailable
{
    BOOL networkAvailable = YES;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    if([reachability currentReachabilityStatus] == NotReachable)
    {
        [self showAlertForNoInternetConnectionWithMessage:nil];
        networkAvailable = NO;
    }
    return networkAvailable;
}

+ (void)showAlertForNoInternetConnectionWithMessage:(NSString *)message
{
    NSString *msg = NO_INTERNET_MSG;
    if (message.length) {
        msg = message;
    }
    [[[UIAlertView alloc] initWithTitle:@"ERROR"
                               message:msg
                              delegate:nil
                     cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

+ (NSString *)applyCurrencyFormat:(NSString *)priceStr
{
    NSString *formattedCurrencyTxt;
    if (priceStr) {
        
        NSNumberFormatter *formatterCurrency;
        formatterCurrency = [[NSNumberFormatter alloc] init];
        formatterCurrency.numberStyle = NSNumberFormatterCurrencyStyle;
        [formatterCurrency setGroupingSize:3];
        [formatterCurrency setMaximumFractionDigits:2];
        [formatterCurrency setCurrencySymbol:@"₹"];
        [formatterCurrency setGroupingSeparator:@","];
        // NSLog(@"%@", @([budgetTxt doubleValue]));
        formattedCurrencyTxt = [formatterCurrency stringFromNumber: @([priceStr doubleValue])];
    }
    return formattedCurrencyTxt;
}
+ (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@",trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    return result;
}

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL checkStatus = [emailTest evaluateWithObject:checkString];
    return checkStatus;
}

+ (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

/**
 Class method to show activity indicator
 */
+ (void)startActivityIndicatorOnView:(UIView*)inView withText:(NSString*)inStr
{
    if (!inView) {
        inView = [[UIApplication sharedApplication] keyWindow];
    }
    
    MBProgressHUD *mLoadingScreen =(MBProgressHUD*)[inView viewWithTag:123123123];
    if(mLoadingScreen == nil)
    {
        mLoadingScreen = [[MBProgressHUD alloc]initWithView:inView];
        mLoadingScreen.labelText = inStr;
        mLoadingScreen.tag = 123123123;
        mLoadingScreen.alpha = 1;
        [inView addSubview:mLoadingScreen];
    }
    else {
        [inView bringSubviewToFront:mLoadingScreen];
        mLoadingScreen.labelText = inStr;
    }
    
    [UIView animateWithDuration:0.25
                     animations:
     ^{
         mLoadingScreen.alpha = 1.0f;
         
     }];
}

/**
 Class method to stop activity indicator and removes from super view
 */
+ (void)stopActivityIndicatorFromView:(UIView*)inView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (!inView) {
        inView = [[UIApplication sharedApplication] keyWindow];
    }
    
    if([inView viewWithTag:123123123])
    {
        MBProgressHUD *mLoadingScreen = (MBProgressHUD*)[inView viewWithTag:123123123];
        
        [UIView animateWithDuration:0.15
                         animations:
         ^{
             mLoadingScreen.alpha = 0.0f;
         }
                         completion:
         ^(BOOL finished)
         {
             // Commenting code as it's not getting executed as expected
             //             if (loaddingCount == 0) {
             //                 [mLoadingScreen hide:YES];
             //                 [mLoadingScreen removeFromSuperview];
             //             }
         }];
    }
}

//+(UIImage *)getImageWithColor:(UIColor *)color
//{
//    UIImage *img = [UIImage imageNamed:@"gray-border.png"];
//    
//    // Make a rectangle the size of your image
//    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
//    // Create a new bitmap context based on the current image's size and scale, that has opacity
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, img.scale);
//    // Get a reference to the current context (which you just created)
//    CGContextRef c = UIGraphicsGetCurrentContext();
//    // Draw your image into the context we created
//    [img drawInRect:rect];
//    // Set the fill color of the context
//    CGContextSetFillColorWithColor(c, [color CGColor]);
//    // This sets the blend mode, which is not super helpful. Basically it uses the your fill color with the alpha of the image and vice versa. I'll include a link with more info.
//    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
//    // Now you apply the color and blend mode onto your context.
//    CGContextFillRect(c, rect);
//    // You grab the result of all this drawing from the context.
//    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
//    // And you return it.
//    return result;
//}
@end
