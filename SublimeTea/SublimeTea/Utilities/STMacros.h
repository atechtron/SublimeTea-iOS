//
//  STMacros.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGB(rValue,gValue,bValue,alphaValue) [UIColor colorWithRed:((float)rValue)/255.0 green:((float)gValue)/255.0 blue:((float)bValue)/255.0 alpha:((float)alphaValue)]

#define NO_INTERNET_MSG @"Please make sure you have an active Internet connection and try again."
#define MDSDEBUG /*Uncomment this line to enable all debug logs*/

#ifdef MDSDEBUG
#   define DB_LOG
#   define DB_FLOW_LOG
#endif

//#undef DB_LOG /*uncomment to disable only custom NSLogs*/

#ifdef DB_LOG
#   define dbLine() NSLog(@"-------------------------------------------------------------");
#   define dbLog NSLog
#else
#   define dbLine()
#   define NSLog(x,...)
#endif

//#undef DB_FLOW_LOG /*uncomment to disable only flow logs*/

#ifdef DB_FLOW_LOG
#   define dbMETHOD_ENTER() NSLog(@"%s: Enter",__FUNCTION__)
#   define dbMETHOD_EXIT()  NSLog(@"%s: Exit",__FUNCTION__)
#else
#   define dbMETHOD_ENTER()
#   define dbMETHOD_EXIT()
#endif

#define AppDelegate        ((STAppDelegate*)[[UIApplication sharedApplication] delegate])




#define kUSerSession_Key @"USER_SESSIONID"
#define kUserInfo_Key @"USER_INFO"
#define kUserCart_Key @"USER_CART"
#define kProductCategory_Key @"PRODUCT_CATEGORY_DATA"
#define kProductList_Key @"ALL_PRODUCTS_LIST_DATA"
#define kProductInfo_Key(prodId) [NSString stringWithFormat:@"PROD_%@",prodId]
#define kCountries_key @"COUNTRY_STATE_CITY"
#define kCountyList_key @"LIST_OF_COUNTRIES"
#define kRegionList_key(countryCode) [NSString stringWithFormat:@"REGION_COUNTRY_CODE-%@",countryCode]



#define kProductNodeName @"products"
#define kAddressNodeName @"customer"