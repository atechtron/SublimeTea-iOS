
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
#import "STConstants.h"
#import "UIImage+animatedGIF.h"
#import <objc/runtime.h>

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
        // dbLog(@"%@", @([budgetTxt doubleValue]));
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
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *mLoadingScreen =(MBProgressHUD*)[inView viewWithTag:123123123];
        if(mLoadingScreen == nil)
        {
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
        
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
            mLoadingScreen = [MBProgressHUD showHUDAddedTo:inView animated:YES];
            mLoadingScreen.customView = img;
            mLoadingScreen.mode = MBProgressHUDModeCustomView;
//            mLoadingScreen.label.text = inStr;
            mLoadingScreen.tag = 123123123;
            mLoadingScreen.alpha = 1;
            [inView addSubview:mLoadingScreen];
        }
        else {
            [inView bringSubviewToFront:mLoadingScreen];
//            mLoadingScreen.label.text = inStr;
        }
        
        [UIView animateWithDuration:0.25
                         animations:
         ^{
             mLoadingScreen.alpha = 1.0f;
             
         }];
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
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
    });
}
+ (NSString *)getNodeNameFromStr:(NSString *)name{
//([functionalityName isEqualToString:kProductNodeName])? @"shoppingCartProductEntity" :nil
    NSString *str;
    if ([name isEqualToString:kProductNodeName]) {
        str = @"shoppingCartProductEntity";
    }
    else if ([name isEqualToString:kAddressNodeName]) {
        str = @"shoppingCartCustomerAddressEntity";
    }
    
    return str;
}
+ (NSString *)prepareMethodSoapBody:(NSString *)actionMethodNameKey params:(NSDictionary *)paramDict  {
    NSMutableString *soapBody = [NSMutableString new];
    
    NSString *part1 = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n""<soap:Body>\n";
    
    NSString *part2 = [NSString stringWithFormat:@"<%@ xmlns=\"%@\">",actionMethodNameKey, [STConstants getAPIURLWithParams:nil]];
    NSString *part3 = [NSString stringWithFormat:@"</%@>",actionMethodNameKey];
    
    [soapBody appendString:part1];
    [soapBody appendString:part2];
    
    NSArray *arr = [paramDict allKeys];
    
    //[soapBody appendString:[NSString stringWithFormat:@"<shoppingCartProductAdd>"]];
    
    for(int i=0;i<[arr count];i++)
        
    {
        NSString *keyVal = [arr objectAtIndex:i];
        id nodeValue = [paramDict objectForKey:keyVal];
        NSString *entittyName = [STUtility getNodeNameFromStr:keyVal];
        if
            ([nodeValue isKindOfClass:[NSArray class]] )
            
        {
            
            if([nodeValue count]>0)
                
            {
                [soapBody appendString:[NSString stringWithFormat:@"<%@>",keyVal]];
                
                for(int j=0;j<[nodeValue count];j++)
                    
                {
                    id value = [nodeValue objectAtIndex:j];
                    
                    if([value isKindOfClass:[NSDictionary class]])
                        
                    {
                        NSArray *Keys=[value allKeys];
                        [soapBody appendString:[NSString stringWithFormat:@"<%@>",entittyName]];                          
                        for (int k=0; k<[Keys count]; k++)
                            
                        {
                            [soapBody appendString:[NSString stringWithFormat:@"<%@>",[Keys objectAtIndex:k]]];
                            [soapBody appendString:[NSString stringWithFormat:@"%@",[value objectForKey:[Keys objectAtIndex:k]]]];
                            [soapBody appendString:[NSString stringWithFormat:@"</%@>",[Keys objectAtIndex:k]]];
                            
                        }
                        [soapBody appendString:[NSString stringWithFormat:@"</%@>\n",entittyName]];
                    }
                }
                [soapBody appendString:[NSString stringWithFormat:@"</%@>\n",keyVal]];
            }
        }
        else if([nodeValue isKindOfClass:[NSDictionary class]])
            
        {
            [soapBody appendString:[NSString stringWithFormat:@"<%@>",[arr objectAtIndex:i]]];
            if([[nodeValue objectForKey:@"Id"] isKindOfClass:[NSString class]])
                [soapBody appendString:[NSString stringWithFormat:@"%@",[nodeValue objectForKey:@"Id"]]];
            
            else
                
                [soapBody appendString:[NSString stringWithFormat:@"%@",[[nodeValue objectForKey:@"Id"] objectForKey:@"text"]]];
            
            [soapBody appendString:[NSString stringWithFormat:@"</%@>",[arr objectAtIndex:i]]];
            
        }
        
        else
            
        {
            [soapBody appendString:[NSString stringWithFormat:@"<%@>",[arr objectAtIndex:i]]];
            
            [soapBody appendString:[NSString stringWithFormat:@"%@",[NSString  stringWithFormat:@"%@",[paramDict objectForKey:[arr objectAtIndex:i]] ]]];
            
            [soapBody appendString:[NSString stringWithFormat:@"</%@>",[arr objectAtIndex:i]]];
            
            
            
        }
        
    }
    
    //  [soapBody appendString:[NSString stringWithFormat:@"</shoppingCartProductAdd>\n"]];
    
    //  NSString *finalxml=[soapBody stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    
    
    
    
    //        else
    //
    //
    //
    //        {
    //
    //            for(NSString *strkey in dictionary.allKeys)
    //
    //
    //
    //            {
    //
    //
    //
    //                NSString *part4 = [NSString stringWithFormat:@"<%@>%@</%@>",strkey,[dictionary valueForKey:strkey], strkey];
    //                [soapBody appendString:part4];
    //
    //            }
    //
    //        }
    
    
    
    
    
    [soapBody appendString:part3];
    
    
    
    NSString *part5 = @"</soap:Body>\n" "</soap:Envelope>";
    [soapBody appendString:part5];
    dbLog(@"Request Body.....%@",soapBody);
    return soapBody;
    
    
    return soapBody;
}

+ (UIColor *)getSublimeHeadingBGColor {
    return UIColorFromRGB(106.0, 49.0, 32.0, 1.0);
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
