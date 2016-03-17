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
    [self createCart];
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
                                          NSLog(@"SublimeTea-STPlaceOrder-createCart:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Cart %@",xmlDic);
            [self parseCartResponseWithDict:xmlDic];
        });
    }
    else {
        [self addProductToCart];
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
            
            [self addProductToCart];
        }
        else {
            NSLog(@"Error while adding product to cart.");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        //No categories found.
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
            NSLog(@"add product to Cart Request Body: %@",requestBody);
            
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
                                              NSLog(@"SublimeTea-STPlaceOrder-addProductToCart:- %@",error);
                                          }];
            
          NSData *responseData = [httpRequest synchronousStart];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                NSLog(@"Product Add-- %@",xmlDic);
                [self parseProductResponseWithDict:xmlDic];
            });
        }
    }
    
}
- (void)parseProductResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            [[STCart defaultCart].tempCartProducts removeAllObjects];
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartProductAddResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                [self setCartUser];
            }
        }
        else {
            NSLog(@"Error adding product to cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
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
            NSLog(@"Cart User set Body: %@",requestBody);
            
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
                                                                   NSLog(@"SublimeTea-STPlaceOrder-setCartUser:- %@",error);
                                                               }];
            
            NSData *responseData = [httpRequest synchronousStart];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                NSLog(@"Cart customer info set-- %@",xmlDic);
                [self parseCartCustomerSetResponseWithDict:xmlDic];
            });
    }
}

- (void)parseCartCustomerSetResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartCustomerSetResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                [self ShipmentAddress];
            }
        }
        else {
            NSLog(@"Error setting user information to cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}


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
        [billingAdd setObject:@"Billing" forKey:@"mode"];
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
            NSLog(@"Cart Request Body: %@",requestBody);
            
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
                                                                   NSLog(@"SublimeTea-STPlaceOrder-ShipmentAddress:- %@",error);
                                                               }];
            
            NSData *responseData = [httpRequest synchronousStart];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                NSLog(@"Address Add-- %@",xmlDic);
                [self parseAddressResponseWithDict:xmlDic];
            });
        }
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
            NSLog(@"Error adding address information to cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
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
                                          NSLog(@"SublimeTea-STPlaceOrder-createCart:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Shipping Methods List %@",xmlDic);
            [self parseShippingMethodListResponseWithDict:xmlDic];
        });
    }
}
- (void)parseShippingMethodListResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartShippingListResponse"][@"result"][@"item"];
            NSDictionary *shippingCodeDict = dataDict[@"code"];
            NSString *shippingMethodCode = shippingCodeDict[@"__text"];
            if (shippingMethodCode.length) {
                // Sucess
                [self setShippingMode:shippingMethodCode];
            }
        }
        else {
            NSLog(@"Error in fetching shipping mode list ...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
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
                                          NSLog(@"SublimeTea-STPlaceOrder-setShippingMode:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Set shipping method to cart %@",xmlDic);
            [self parseShippingMethodResponseWithDict:xmlDic];
        });
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
//                [self getCartAmount];
                [self getPaymentModes];
            }
        }
        else {
            NSLog(@"Error setting shipping method cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
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
                                          NSLog(@"SublimeTea-STPlaceOrder-getCartAmount:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Cart total %@",xmlDic);
            [self parseCartTotalResponseWithDict:xmlDic];
        });
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
            NSLog(@"Error in fetching shipping mode list ...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
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
                                          NSLog(@"SublimeTea-STPlaceOrder-getPaymentModes:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Payment Methods List %@",xmlDic);
            [self parsePaymentMethodListResponseWithDict:xmlDic];
        });
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
            NSLog(@"Error in fetching shipping mode list ...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
    }
}


/* Step9:-
 set payment mode to cart */
- (void)setPaymentMode {
    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants paymentMethodReuestBody:@"cashondelivery"];
        
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
                                          NSLog(@"SublimeTea-STPlaceOrder-setPaymentMode:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Payment method set to cart %@",xmlDic);
            [self parsePayementMethodResponseWithDict:xmlDic];
        });
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
                [self createOrder];
            }
        }
        else {
            NSLog(@"Error setting payment method cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}


/* Step10:-
 Get cart information */
- (void)cartDetails {

}

/* Step11:-
 Create Order */
- (void)createOrder {

    if ([STUtility isNetworkAvailable]) {
        NSString *requestBody = [STConstants paymentMethodReuestBody:@"cashondelivery"];
        
        NSString *urlString = [STConstants orderRequestBody];
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
                                          NSLog(@"SublimeTea-STPlaceOrder-createOrder:- %@",error);
                                      }];
        
        
        
        NSData *responseData = [httpRequest synchronousStart];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
            NSLog(@"Order Creation %@",xmlDic);
            [self parsePayementMethodResponseWithDict:xmlDic];
        });
    }
}
- (void)parseOrderCreationMethodResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartOrderResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                // Sucess
                //                [self getCartAmount];

            }
        }
        else {
            NSLog(@"Error setting payment method cart...");
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
    }
    //    [STUtility stopActivityIndicatorFromView:nil];
}
@end