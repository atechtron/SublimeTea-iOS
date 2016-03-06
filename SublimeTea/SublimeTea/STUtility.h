//
//  STUtility.h
//  SublimeTea
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STUtility : NSObject

+ (BOOL) isNetworkAvailable;

+ (void) showAlertForNoInternetConnectionWithMessage:(NSString *)message;

+ (NSString *) applyCurrencyFormat:(NSString *)priceStr;
+ (NSURL *) smartURLForString:(NSString *)str;
+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;
+ (BOOL) validatePhone:(NSString *)phoneNumber;

+ (void)startActivityIndicatorOnView:(UIView*)inView withText:(NSString*)inStr;
+ (void)stopActivityIndicatorFromView:(UIView*)inView;
@end
