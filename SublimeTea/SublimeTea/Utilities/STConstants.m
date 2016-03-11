//
//  STConstants.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STConstants.h"

#define kAPI_ENDPOINT @"http://dev.sublime-house-of-tea.com/index.php/api/v2_soap/index/"

#define kUSERNAME @"superuser"
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
    return str;
}
+ (NSString *)storeId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
    NSString *storeIDStr = userInfoDict ? userInfoDict[@"store_id"][@"__text"] : @1;
    return storeIDStr;
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

@end
