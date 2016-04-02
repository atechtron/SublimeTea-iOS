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
    
#define kAPIdomainName @"shot.beta.webenza.in" //dev.sublime-house-of-tea.com
#define kUrlString @"/api/v2_soap" //  /index.php/api/v2_soap/index/

#define kBlogURL @"http://sublimehouseoftea.com/blog"
#define kTeaRecipes @"http://sublimehouseoftea.com/tea-tecipies"


@interface STConstants : NSObject

+ (NSString *)getAPIURLWithParams:(NSString *)param;
+ (NSString *)storeId;

+ (NSString *)endSessionRequestBody;
+ (NSString *)customerListReuestBody;
+ (NSString *)signUpRequestBodyWIthEmail:(NSString *)emailStr andPassword:(NSString *)passwordStr;
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
+ (NSString *)countryListRequestBody;
+ (NSString *)regionListequestBodyForCountry:(NSString *)countryCode;
+ (NSString *)cartInfoRequestBody;
+ (NSString *)cartLicenseRequestBody;
+ (NSString *)salesOrderListRequstBody;
+ (NSString *)customerInfoUpdateRequestBodyWithEmail:(NSString *)email password:(NSString *)password;
+ (NSString *)customerAddressListRequestBody;
+ (NSString *)salesOrderInfoRequstBodyWithOrderIncrementId:(NSString *)orderIncrementId;
+ (NSString *)userInfoRequstBodyWithCustomerId:(NSInteger)custId
                                 customerEmail:(NSString *)email
                                     firstName:(NSString *)firstName
                                      lastName:(NSString *)lastName
                                      password:(NSString *)password;
@end
