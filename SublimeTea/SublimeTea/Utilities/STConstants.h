//
//  STConstants.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMacros.h"

#define kStoreID 1
#define kMaxQTY 10

@interface STConstants : NSObject

+ (NSString *)getAPIURLWithParams:(NSString *)param;
+ (NSString *)storeId;

+ (NSString *)startSessionRequestBody;
+ (NSString *)categoryListRequestBody;
+ (NSString *)productListRequestBody;
+ (NSString *)productImageListRequestBodyWithId:(NSString *)prodId;
+ (NSString *)prodInfoRequestBodyWithID:(NSString *)prodId;
+ (NSString *)createCartRequestBody;
+ (NSString *)addProductToCartRequestBodyWithProduct:(NSArray *)productArr;
+ (NSString *)getCartCustomerRequestBodyWithCustomerId:(NSString *)cust_Id mode:(NSString *)mode;
+ (NSString *)getShippingMathodListBodyResponse;
+ (NSString *)shippingMethodRequestBodyForMethodCode:(NSString *)shippingMethodCode;
+ (NSString *)cartTotalRequestBody;
+ (NSString *)paymentMethodListRequestBody;
+ (NSString *)paymentMethodReuestBody:(NSString *)method;
+ (NSString *)orderRequestBody;
+ (NSString *)orderListRequestBody;
+ (NSString *)countryListRequestBody;
+ (NSString *)regionListequestBodyForCountry:(NSString *)countryCode;

@end
