//
//  STPlaceOrder.m
//  SublimeTea
//
//  Created by Apple on 17/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STPlaceOrder.h"
#import "STMacros.h"
#import "STUtility.h"
#import "STConstants.h"
#import "STHttpRequest.h"
#import "XMLDictionary.h"
#import "STCart.h"

@implementation STPlaceOrder

- (void)placeOrder
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       [self createCart];
    });
}

/* Step1:- 
Create a cart */
- (void)createCart {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:kUserInfo_Key];
    if (!userInfo[kUserCart_Key] && [STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants createCartRequestBody];
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
        {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-createCart:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Cart %@",xmlDic);
            [self parseCartResponseWithDict:xmlDic];
        });
    }
    else {
        [self setCartUser];
    }
}
- (void)parseCartResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartCreateResponse"][@"quoteId"];
            [[STCart defaultCart] setCartId:dataDict[@"__text"]];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *userInfoDict = [[defaults objectForKey:kUserInfo_Key] mutableCopy];
            [userInfoDict setObject:dataDict[@"__text"] forKey:kUserCart_Key];
            [defaults setValue:userInfoDict forKey:kUserInfo_Key];
            [defaults synchronize];
            
            [self setCartUser];
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error while adding product to cart.");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        //No categories found.
        [STUtility stopActivityIndicatorFromView:nil];
    }
//    [STUtility stopActivityIndicatorFromView:nil];
}


/* Step2:-
 Add products to cart */
- (void)addProductToCart {

    if ([STUtility isNetworkAvailable]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
        NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
        NSInteger usr_cartId = [userInfoDict[kUserCart_Key] integerValue];
        
        NSDictionary *paramDict = @{@"sessionId": sessionId,
                                    @"quoteId":[NSNumber numberWithInteger:usr_cartId]};
        NSMutableDictionary *soapBodyDict = [NSMutableDictionary new];
        [soapBodyDict addEntriesFromDictionary:paramDict];
        
        [soapBodyDict setObject:[STCart defaultCart].tempCartProducts forKey:kProductNodeName];
        [soapBodyDict setValue:[STConstants storeId] forKey:@"storeId"];
        

        if (soapBodyDict) {
            NSString *requestBody = [STUtility prepareMethodSoapBody:@"shoppingCartProductAdd"
                                                              params:soapBodyDict];
            dbLog(@"add product to Cart Request Body: %@",requestBody);
            
            NSString *urlString = [STConstants getAPIURLWithParams:nil];
            NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                 methodType:@"POST"
                                                                       body:requestBody
                                                        responseHeaderBlock:^(NSURLResponse *response)
                                          {}
                                                               successBlock:^(NSData *responseData){}
                                                               failureBlock:^(NSError *error) {
                                              [STUtility stopActivityIndicatorFromView:nil];
                                              [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                          message:@"Unexpected error has occured, Please try after some time."
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles: nil] show];
                                              dbLog(@"SublimeTea-STPlaceOrder-addProductToCart:- %@",error);
                                          }];
            
          NSData *responseData = [httpRequest synchronousStart];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                dbLog(@"Product Add-- %@",xmlDic);
                [self parseProductResponseWithDict:xmlDic];
            });
        }
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}
- (void)parseProductResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartProductAddResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                [self ShipmentAddress];
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            dbLog(@"Error adding product to cart...");
            [self showAlert];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
//    [STUtility stopActivityIndicatorFromView:nil];
}


/* Step3:-
 Add customer information into a shopping cart */
- (void)setCartUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:kUserInfo_Key];
    NSString *customerId = userInfo[@"customer_id"][@"__text"];
    if (customerId.length && [STUtility isNetworkAvailable]) {
        
            NSString *requestBody = [STConstants getCartCustomerRequestBodyWithCustomerId:customerId mode:@"customer"];
            dbLog(@"Cart User set Body: %@",requestBody);
            
            NSString *urlString = [STConstants getAPIURLWithParams:nil];
            NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                 methodType:@"POST"
                                                                       body:requestBody
                                                        responseHeaderBlock:^(NSURLResponse *response)
                                          {}
                                                               successBlock:^(NSData *responseData){}
                                                               failureBlock:^(NSError *error) {
                                                                   [STUtility stopActivityIndicatorFromView:nil];
                                                                   [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                                               message:@"Unexpected error has occured, Please try after some time."
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles: nil] show];
                                                                   dbLog(@"SublimeTea-STPlaceOrder-setCartUser:- %@",error);
                                                               }];
            
            NSData *responseData = [httpRequest synchronousStart];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                dbLog(@"Cart customer info set-- %@",xmlDic);
                [self parseCartCustomerSetResponseWithDict:xmlDic];
            });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

- (void)parseCartCustomerSetResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartCustomerSetResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                [self addProductToCart];
                // Sucess
                
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error setting user information to cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}
//- (STAddress *)getAddress {
//    STAddress *add = [[STAddress alloc] init];
//    add.shipAddress.mode = @"shipping";
//    add.shipAddress.firstname = @"";
//    @property (strong, nonatomic)NSString *lastname;
//    @property (strong, nonatomic)NSString *street;
//    @property (strong, nonatomic)NSString *city;
//    @property (strong, nonatomic)NSString *state;
//    @property (strong, nonatomic)NSString *postcode;
//    @property (strong, nonatomic)NSString *country_id;
//    @property (strong, nonatomic)NSString *telephone;
//    @property (strong, nonatomic)NSString *email;
//    @property (nonatomic) NSInteger is_default_shipping;
//    @property (nonatomic) NSInteger is_default_billing;
//}

/* Step4:-
 Set Address */
- (void)ShipmentAddress {

    if ([STUtility isNetworkAvailable]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sessionId =   [defaults objectForKey:kUSerSession_Key];
        NSMutableDictionary *userInfoDict = [defaults objectForKey:kUserInfo_Key];
        NSInteger usr_cartId = [userInfoDict[kUserCart_Key] integerValue];
        
        NSDictionary *paramDict = @{@"sessionId": sessionId,
                                    @"quoteId":[NSNumber numberWithInteger:usr_cartId]};
        
        NSDictionary *shippingAdd = [self.address.shipAddress dictionary];
        NSMutableDictionary *billingAdd = [shippingAdd mutableCopy];
        [billingAdd setObject:@"billing" forKey:@"mode"];
        if (!self.address.isBillingIsShipping) {
         billingAdd = [[self.address.billedAddress dictionary] mutableCopy];
        }
        
        NSArray *addressArr = @[shippingAdd,billingAdd];
        NSMutableDictionary *soapBodyDict = [NSMutableDictionary new];
        [soapBodyDict addEntriesFromDictionary:paramDict];
        [soapBodyDict setObject:addressArr forKey:kAddressNodeName];
        [soapBodyDict setValue:[STConstants storeId] forKey:@"storeId"];
        
        
        if (soapBodyDict) {
            NSString *requestBody = [STUtility prepareMethodSoapBody:@"shoppingCartCustomerAddresses"
                                                              params:soapBodyDict];
            dbLog(@"Shippment Address Request Body: %@",requestBody);
            
            NSString *urlString = [STConstants getAPIURLWithParams:nil];
            NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                                 methodType:@"POST"
                                                                       body:requestBody
                                                        responseHeaderBlock:^(NSURLResponse *response)
                                          {}
                                                               successBlock:^(NSData *responseData){}
                                                               failureBlock:^(NSError *error) {
                                                                   [STUtility stopActivityIndicatorFromView:nil];
                                                                   [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                                               message:@"Unexpected error has occured, Please try after some time."
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles: nil] show];
                                                                   dbLog(@"SublimeTea-STPlaceOrder-ShipmentAddress:- %@",error);
                                                               }];
            
            NSData *responseData = [httpRequest synchronousStart];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                dbLog(@"Address Add-- %@",xmlDic);
                [self parseAddressResponseWithDict:xmlDic];
            });
        }
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

- (void)parseAddressResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartCustomerAddressesResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                [self ShippingMethods];
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error adding address information to cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}


/* Step5:-
 get Shipping methods */
- (void)ShippingMethods {
//    shoppingCartShippingList
    
    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants getShippingMathodListBodyResponse];
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-createCart:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"Shipping Methods List xml: %@",xmlString);
            
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Shipping Methods List %@",xmlDic);
            [self parseShippingMethodListResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}
- (void)parseShippingMethodListResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        dbLog(@"%@",responseDict);
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (parentDataDict[@"SOAP-ENV:Fault"] == nil) {
            NSDictionary *dataDict;
            NSArray *dataArr;
            id itemObj = parentDataDict[@"ns1:shoppingCartShippingListResponse"][@"result"][@"item"];
            if ([itemObj isKindOfClass:[NSDictionary class]]) {
                dataDict = (NSDictionary *)itemObj;
            }
            else if ([itemObj isKindOfClass:[NSArray class]]) {
                dataArr = (NSArray *)itemObj;
            }
            if (dataArr.count) {
                NSPredicate *filterPred = [NSPredicate predicateWithFormat:@"code.__text LIKE %@",@"flatrate_flatrate"];
                NSArray *tempAr = [dataArr filteredArrayUsingPredicate:filterPred];
                dataDict = tempAr.count ? tempAr[0]: nil;
            }

            if (dataDict) {
                NSDictionary *shippingCodeDict = dataDict[@"code"];
                NSString *shippingMethodCode = shippingCodeDict[@"__text"];
                if (shippingMethodCode.length) {
                    // Sucess
                    [self setShippingMode:@"flatrate_flatrate"];
                }
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error in fetching shipping mode list ...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}



/* Step6:-
 set payment mode to cart */
- (void)setShippingMode:(NSString *)shippingCode {

    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants shippingMethodRequestBodyForMethodCode:shippingCode];
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-setShippingMode:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Set shipping method to cart %@",xmlDic);
            [self parseShippingMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

- (void)parseShippingMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartShippingMethodResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                [self getCartAmount];
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error setting shipping method cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}


/* Step7:-
 Get cart payment amount */
- (void)getCartAmount{
    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants cartTotalRequestBody];
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-getCartAmount:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Cart total %@",xmlDic);
            [self getPaymentModes];
            [self parseCartTotalResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

- (void)parseCartTotalResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
//            NSArray *dataArr = parentDataDict[@"ns1:shoppingCartTotalsResponse"][@"result"][@"item"];
////            NSDictionary *shippingCodeDict = dataDict[@"code"];
//            NSString *shippingMethodCode = shippingCodeDict[@"__text"];
//            if (shippingMethodCode.length) {
//                // Sucess
//                [self setShippingMode:shippingMethodCode];
//            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error in fetching shipping mode list ...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}

/* Step8:-
 Get list of cart products */
- (NSArray *)cartProducts {
    return nil;
}

/* Step6:-
 Get payment modes */
- (void)getPaymentModes {
//    shoppingCartPaymentList

    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants paymentMethodListRequestBody];
        dbLog(@"%@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-getPaymentModes:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Payment Methods List %@",xmlDic);
            [self parsePaymentMethodListResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

- (void)parsePaymentMethodListResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
//            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartPaymentListResponse"][@"result"][@"item"];
//            NSDictionary *shippingCodeDict = dataDict[@"code"];
//            NSString *shippingMethodCode = shippingCodeDict[@"__text"];
//            if (shippingMethodCode.length) {
                // Sucess
                [self setPaymentMode];
//            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error in fetching shipping mode list ...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

    
/* Step9:-
 set payment mode to cart */
- (void)setPaymentMode {
    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants paymentMethodReuestBody:@"checkmo"];
        dbLog(@"Payment mode: %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-setPaymentMode:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Payment method set to cart %@",xmlDic);
            [self parsePayementMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

- (void)parsePayementMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartPaymentMethodResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                //                [self getCartAmount];
                [self cartDetails];
            }
        }
        else {
            [STUtility stopActivityIndicatorFromView:nil];
            [self showAlert];
            dbLog(@"Error setting payment method cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}


/* Step10:-
 Get cart information */
- (void)cartDetails {

    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants cartInfoRequestBody];
        dbLog(@"Cart Info: %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-cartDetails:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Cart Info %@",xmlDic);
            [self createOrder];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

/* Step11:-
 Cart License */
- (void)shoppingCartLicense {
    
    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants cartLicenseRequestBody];
        dbLog(@"Cart License: %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-shoppingCartLicense:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            dbLog(@"Cart License %@",xmlDic);
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
}

/* Step12:-
 Create Order */
- (void)createOrder {

    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants orderRequestBody];
        dbLog(@"Order Creation: %@",requestBody);
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response){}
                                                           successBlock:^(NSData *responseData){}
                                                           failureBlock:^(NSError *error)
                                      {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          dbLog(@"SublimeTea-STPlaceOrder-createOrder:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *xmlString = [[NSString alloc] initWithBytes: [responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            dbLog(@"Order Creation xml: %@",xmlString);
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
            dbLog(@"Order Creation %@",xmlDic);
            if (!xmlDic) {
                NSArray *tempComponentsArr = [xmlString componentsSeparatedByString:@"<result xsi:type=\"xsd:string\">"];
                if(tempComponentsArr.count == 2)
                {
                    NSArray *comp = [tempComponentsArr[1] componentsSeparatedByString:@"</result>"];
                    if (comp.count > 1) {
                        if ([self.delegate respondsToSelector:@selector(orderResultWithId:)]) {
                            [self.delegate orderResultWithId:comp[0]];
                        }
                    }
                }
            }
//            [self parseOrderCreationMethodResponseWithDict:xmlDic];
        });
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)parseOrderCreationMethodResponseWithDict:(NSDictionary *)responseDict {
//    xmlDic[@"SOAP-ENV:Body"][@"ns1:shoppingCartOrderResponse"][@"result"][@"__text"]
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartOrderResponse"][@"result"];
            NSString *oderNumber = dataDict[@"__text"];
            if ([self.delegate respondsToSelector:@selector(orderResultWithId:)]) {
                [self.delegate orderResultWithId:oderNumber];
            }
        }
        else {
            dbLog(@"Error placing order...");
            [self showAlert];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
    }
        [STUtility stopActivityIndicatorFromView:nil];
}
- (void)showAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR!"
                                                    message:@"Order creation failed."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
@end
