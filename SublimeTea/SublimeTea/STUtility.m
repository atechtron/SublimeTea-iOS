
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
