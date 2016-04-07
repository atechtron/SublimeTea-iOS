//
//  STConstants.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STConstants.h"

#define kAPI_ENDPOINT [NSString stringWithFormat:@"http://%@%@",kAPIdomainName,kUrlString]//@"http://shot.beta.webenza.in/api/v2_soap"//@"http://dev.sublime-house-of-tea.com/index.php/api/v2_soap/index/"


#define kUSERNAME @"shot_admin"
#define kPWD @"123456"

#define kParentId @"1"

//Start App Session

@implementation STConstants

+ (NSString *)getAPIURLWithParams:(NSString *)param {
    NSString *str;
    if (!param || !param.length) {
        str = kAPI_ENDPOINT;
    }
    else
    {
        str = [NSString stringWithFormat:@"%@%@",kAPI_ENDPOINT,param];
    }
    dbLog(@"%@",str);
    return str;
}
+ (NSString *)storeId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSString *storeIDStr = userInfoDict ? userInfoDict[@"store_id"][@"__text"] : @1;
    return storeIDStr;
}

+ (NSString *)signUpRequestBodyWIthEmail:(NSString *)emailStr andPassword:(NSString *)passwordStr {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:customerCustomerCreate soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<customerData xsi:type=\"urn:customerCustomerEntityToCreate\">"
                         "<email xsi:type=\"xsd:string\">%@</email>"
                         "<password xsi:type=\"xsd:string\">%@</password>"
                         "</customerData>"
                         "</urn:customerCustomerCreate>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,emailStr,passwordStr];
    return tempStr;
}

+ (NSString *)customerListReuestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:customerCustomerList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "</urn:customerCustomerList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId];
    return tempStr;
}

+ (NSString *)endSessionRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:endSession soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "</urn:endSession>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId];
    return tempStr;
}

+ (NSString *)startSessionRequestBody {
    NSString *temp;
    
    temp =  [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
             "<soapenv:Header/>"
             "<soapenv:Body>"
             "<urn:login soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
             "<username xsi:type=\"xsd:string\">%@</username>"
             "<apiKey xsi:type=\"xsd:string\">%@</apiKey>"
             "</urn:login>"
             "</soapenv:Body>"
             "</soapenv:Envelope>",kUSERNAME,kPWD];
    return temp;
}

+ (NSString *)customerInfoUpdateRequestBodyWithEmail:(NSString *)email
                                            password:(NSString *)password {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSString *custId = userInfoDict[@"customer_id"][@"__text"];
    
    NSMutableString *bodyStr = [[NSMutableString alloc] initWithString:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                                "<soapenv:Header/>"
                                "<soapenv:Body>"
                                "<urn:customerCustomerUpdate soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                                "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                                "<customerId xsi:type=\"xsd:int\">%ld</customerId>"
                                "<customerData xsi:type=\"urn:customerCustomerEntityToCreate\">"
                                "<customer_id xsi:type=\"xsd:int\">%ld</customer_id>"
                                "<email xsi:type=\"xsd:string\">%@</email>"];
    if (password.length) {
        [bodyStr appendString:@"<password xsi:type=\"xsd:string\">%@</password>"];
    }
    [bodyStr appendString:@"<store_id xsi:type=\"xsd:int\">%ld</store_id>"
     "</customerData>"
     "</urn:customerCustomerUpdate>"
     "</soapenv:Body>"
     "</soapenv:Envelope>"];
    
    
    NSString *tempStr = password.length ?[NSString stringWithFormat:bodyStr,sessionId,(long)custId,(long)custId,email,password,(long)[STConstants storeId]]:[NSString stringWithFormat:bodyStr,sessionId,(long)custId,(long)custId,email,(long)[STConstants storeId]];
    return tempStr;
}

+ (NSString *)customerAddressListRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSString *custId = userInfoDict[@"customer_id"][@"__text"];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                        "<soapenv:Header/>"
                        "<soapenv:Body>"
                        "<urn:customerAddressList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                        "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                        "<customerId xsi:type=\"xsd:int\">%ld</customerId>"
                        "</urn:customerAddressList>"
                        "</soapenv:Body>"
                        "</soapenv:Envelope>",sessionId,(long)[custId integerValue]];
    return tempStr;
}

+ (NSString *)categoryListRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:catalogCategoryTree soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<parentId xsi:type=\"xsd:string\">%@</parentId>"
                         "<storeView xsi:type=\"xsd:string\">%@</storeView>"
                         "</urn:catalogCategoryTree>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,kParentId,[STConstants storeId]];
    
    return tempStr;
}

+ (NSString *)productListRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:catalogProductList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<storeView xsi:type=\"xsd:string]\">%@</storeView>"
                         "</urn:catalogProductList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)productImageListRequestBodyWithId:(NSString *)prodId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:catalogProductAttributeMediaList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<product xsi:type=\"xsd:string\">%@</product>"
                         "<storeView xsi:type=\"xsd:string\">%@</storeView>"
                         "<identifierType xsi:type=\"xsd:string\"/>"
                         "</urn:catalogProductAttributeMediaList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId, prodId,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)prodInfoRequestBodyWithID:(NSString *)prodId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:catalogProductInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<productId xsi:type=\"xsd:string\">%@</productId>"
                         "<storeView xsi:type=\"xsd:string\">%@</storeView>"
                         "</urn:catalogProductInfo>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,prodId,[STConstants storeId]];
    
    return tempStr;
}
+ (NSString *)createCartRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartCreate soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartCreate>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,[STConstants storeId]];
    
    return tempStr;
}

+ (NSString *)addProductToCartRequestBodyWithProduct:(NSArray *)productArr {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartProductAdd soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<products xsi:type=\"urn:shoppingCartProductEntityArray\" soapenc:arrayType=\"urn:shoppingCartProductEntity[]\">%@</products>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartProductAdd>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,(long)cartId,productArr,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)getCartCustomerRequestBodyWithCustomerId:(NSString *)cust_Id mode:(NSString *)mode {
    NSString *tempStr;

    /*
     guest
     customer
     */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
               "<soapenv:Header/>"
               "<soapenv:Body>"
               "<urn:shoppingCartCustomerSet soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
               "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
               "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
               "<customer xsi:type=\"urn:shoppingCartCustomerEntity\">"
               "<mode xsi:type=\"xsd:string\">%@</mode>"
               "<customer_id xsi:type=\"xsd:int\">%ld</customer_id>"
               "<store_id xsi:type=\"xsd:int\">%@</store_id>"
               "</customer>"
               "<storeId xsi:type=\"xsd:string\">%@</storeId>"
               "</urn:shoppingCartCustomerSet>"
               "</soapenv:Body>"
               "</soapenv:Envelope>",sessionId, (long)cartId,mode,(long)[cust_Id integerValue],[STConstants storeId],[STConstants storeId]];
    
    return tempStr;
}
+ (NSString *)getShippingMathodListBodyResponse {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartShippingList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartShippingList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,(long)cartId,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)shippingMethodRequestBodyForMethodCode:(NSString *)shippingMethodCode {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartShippingMethod soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<method xsi:type=\"xsd:string\">%@</method>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartShippingMethod>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,(long)cartId,shippingMethodCode,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)cartTotalRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartTotals soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartTotals>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,(long)cartId,[STConstants storeId]];
                         return tempStr;
}


+ (NSString *)paymentMethodListRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartPaymentList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<store xsi:type=\"xsd:string\">%@</store>"
                         "</urn:shoppingCartPaymentList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId, (long)cartId,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)paymentMethodReuestBody:(NSString *)method {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartPaymentMethod soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<method xsi:type=\"urn:shoppingCartPaymentMethodEntity\">"
                         "<method xsi:type=\"xsd:string\">%@</method>"
                         "</method>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartPaymentMethod>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId, (long)cartId,method,[STConstants storeId]];
    return tempStr;
}

+ (NSString *)orderRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartOrder soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "<licenses xsi:type=\"urn:ArrayOfString\" soapenc:arrayType=\"xsd:string[]\"/>"
                         "</urn:shoppingCartOrder>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,(long)cartId, [STConstants storeId]];
    return tempStr;
}
+ (NSString *)countryListRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:directoryCountryList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "</urn:directoryCountryList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId];
    return tempStr;
}

+ (NSString *)regionListequestBodyForCountry:(NSString *)countryCode {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:directoryRegionList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<country xsi:type=\"xsd:string\">%@</country>"
                         "</urn:directoryRegionList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId, countryCode];
    return tempStr;
}

+ (NSString *)cartInfoRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartInfo>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId, (long)cartId, [STConstants storeId]];
    return tempStr;
}

+ (NSString *)cartLicenseRequestBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSInteger cartId = [userInfoDict[kUserCart_Key] integerValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:shoppingCartLicense soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<quoteId xsi:type=\"xsd:int\">%ld</quoteId>"
                         "<storeId xsi:type=\"xsd:string\">%@</storeId>"
                         "</urn:shoppingCartLicense>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId, (long)cartId, [STConstants storeId]];
    return tempStr;
}

+ (NSString *)salesOrderListRequstBody {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:salesOrderList soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "</urn:salesOrderList>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId];
    return tempStr;
}

+ (NSString *)salesOrderInfoRequstBodyWithOrderIncrementId:(NSString *)orderIncrementId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    
    NSString *tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                         "<soapenv:Header/>"
                         "<soapenv:Body>"
                         "<urn:salesOrderInfo soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                         "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                         "<orderIncrementId xsi:type=\"xsd:string\">%@</orderIncrementId>"
                         "</urn:salesOrderInfo>"
                         "</soapenv:Body>"
                         "</soapenv:Envelope>",sessionId,orderIncrementId];
    return tempStr;
}

+ (NSString *)userInfoRequstBodyWithCustomerId:(NSInteger)custId
                                 customerEmail:(NSString *)email
                                     firstName:(NSString *)firstName
                                      lastName:(NSString *)lastName
                                      password:(NSString *)password {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
    NSString *tempStr;
    if (password.length) {
         tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                             "<soapenv:Header/>"
                             "<soapenv:Body>"
                             "<urn:customerCustomerUpdate soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                             "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                             "<customerId xsi:type=\"xsd:int\">%ld</customerId>"
                             "<customerData xsi:type=\"urn:customerCustomerEntityToCreate\">"
                             "<email xsi:type=\"xsd:string\">%@</email>"
                             "<firstname xsi:type=\"xsd:string\">%@</firstname>"
                             "<lastname xsi:type=\"xsd:string\">%@</lastname>"
                             "<password xsi:type=\"xsd:string\">%@</password>"
                             "<store_id xsi:type=\"xsd:int\">%ld</store_id>"
                             "</customerData>"
                             "</urn:customerCustomerUpdate>"
                             "</soapenv:Body>"
                             "</soapenv:Envelope>",sessionId,(long)custId, email, firstName, lastName,password, (long)[[STConstants storeId] integerValue]];
    }
    else {
        tempStr = [NSString stringWithFormat:@"<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:Magento\">"
                   "<soapenv:Header/>"
                   "<soapenv:Body>"
                   "<urn:customerCustomerUpdate soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
                   "<sessionId xsi:type=\"xsd:string\">%@</sessionId>"
                   "<customerId xsi:type=\"xsd:int\">%ld</customerId>"
                   "<customerData xsi:type=\"urn:customerCustomerEntityToCreate\">"
                   "<email xsi:type=\"xsd:string\">%@</email>"
                   "<firstname xsi:type=\"xsd:string\">%@</firstname>"
                   "<lastname xsi:type=\"xsd:string\">%@</lastname>"
                   "<store_id xsi:type=\"xsd:int\">%ld</store_id>"
                   "</customerData>"
                   "</urn:customerCustomerUpdate>"
                   "</soapenv:Body>"
                   "</soapenv:Envelope>",sessionId,(long)custId, email, firstName, lastName, (long)[[STConstants storeId] integerValue]];
    }
    
    return tempStr;
}


@end
