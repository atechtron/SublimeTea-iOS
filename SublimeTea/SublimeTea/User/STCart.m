//
//  STCart.m
//  SublimeTea
//
//  Created by Apple on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCart.h"
#import "STHttpRequest.h"
#import "STConstants.h"
#import "XMLDictionary.h"

@implementation Product


@end

@interface STCart()
@end

@implementation STCart

static STCart *sharedInstance;

+ (instancetype)defaultCart {
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] initUniqueInstance];
        });
    }
    return sharedInstance;
}
-(instancetype) initUniqueInstance {
    
    _productsInCart = [NSMutableArray new];
    _productsDataArr = [NSMutableArray new];
    _tempCartProducts = [NSMutableArray new];
    
    // Create cart on server
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *userInfo = [defaults objectForKey:kUserInfo_Key];
//    //        createCart
//    if (!userInfo[kUserCart_Key] && [STUtility isNetworkAvailable]) {
//        [self createCart];
//    }
    
    return [super init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [STCart defaultCart];
}

-(void)addProductsInCart:(NSDictionary *)prodDict withQty:(NSInteger)qty {
    
//    [STUtility startActivityIndicatorOnView:nil withText:@"Please Wait.."];
    if (prodDict && qty >0) {
        Product *prod = [Product new];
        prod.prodDict = prodDict;
        prod.prodQty = qty;
        [self.productsDataArr addObject:prod];
        
        NSString *prodId = prodDict[@"product_id"][@"__text"];
        NSDictionary *dataDict = @{@"product_id" : prodId,
                                   @"qty": [NSNumber numberWithInteger:qty]};
        [self.productsInCart addObject:dataDict];
        [self.tempCartProducts addObject:dataDict];
    }
}
- (NSInteger)numberOfProductsInCart {
    return self.productsInCart.count;
}
- (void)removeProductFromCart:(NSInteger)idx {
    [self.productsDataArr removeObjectAtIndex:idx];
    [self.tempCartProducts removeObjectAtIndex:idx];
    [self.productsInCart removeObjectAtIndex:idx];
}
- (void)updateProductToCartAtIndex:(NSInteger)idx withQty:(NSInteger)qty {
    if (qty > 0) {
        Product *prod = self.productsDataArr[idx];
        prod.prodQty = qty;
        [self.productsDataArr replaceObjectAtIndex:idx
                                        withObject:prod];
        NSDictionary *prodDict = @{@"qty" :[NSNumber numberWithInteger:qty]};
        
        [self.tempCartProducts replaceObjectAtIndex:idx
                                         withObject:prodDict];
        [self.productsInCart replaceObjectAtIndex:idx
                                       withObject:prodDict];
    }
}
- (void)addProductToCart:(NSDictionary *)prodDataDict {
    if (prodDataDict) {
        NSString *requestBody = [STUtility prepareMethodSoapBody:@"shoppingCartProductAdd"
                                                          params:prodDataDict];
        NSLog(@"Cart Request Body: %@",requestBody);
        
        NSString *urlString = [STConstants getAPIURLWithParams:nil];
        NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                             methodType:@"POST"
                                                                   body:requestBody
                                                    responseHeaderBlock:^(NSURLResponse *response)
                                      {
                                          
                                      }successBlock:^(NSData *responseData){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                              NSLog(@"Cart %@",xmlDic);
                                              [self parseProductResponseWithDict:xmlDic];
                                          });
                                          
                                      }failureBlock:^(NSError *error) {
                                          [STUtility stopActivityIndicatorFromView:nil];
                                          [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Unexpected error has occured, Please try after some time."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil] show];
                                          NSLog(@"SublimeTea-STCart-createCart:- %@",error);
                                      }];
        
        [httpRequest start];
    }
}
- (void)createCart {
    [STUtility startActivityIndicatorOnView:nil withText:@"Please Wait.."];
    NSString *requestBody = [STConstants createCartRequestBody];
    
    NSString *urlString = [STConstants getAPIURLWithParams:nil];
    NSURL *url  = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    STHttpRequest *httpRequest = [[STHttpRequest alloc] initWithURL:url
                                                         methodType:@"POST"
                                                               body:requestBody
                                                responseHeaderBlock:^(NSURLResponse *response)
                                  {
                                      
                                  }successBlock:^(NSData *responseData){
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLData:responseData];
                                          NSLog(@"Cart %@",xmlDic);
                                          [self parseResponseWithDict:xmlDic];
                                      });
                                      
                                  }failureBlock:^(NSError *error) {
                                      [STUtility stopActivityIndicatorFromView:nil];
                                      [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"Unexpected error has occured, Please try after some time."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil] show];
                                      NSLog(@"SublimeTea-STCart-createCart:- %@",error);
                                  }];
    
    [httpRequest start];
}
- (void)parseResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartCreateResponse"][@"quoteId"];
            self.cartId = dataDict[@"__text"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *userInfoDict = [[defaults objectForKey:kUserInfo_Key] mutableCopy];
            [userInfoDict setObject:self.cartId forKey:kUserCart_Key];
            [defaults setValue:userInfoDict forKey:kUserInfo_Key];
            [defaults synchronize];
        }
        else {
            NSLog(@"Error while adding product to cart.");
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        //No categories found.
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
- (void)parseProductResponseWithDict:(NSDictionary *)responseDict {
    if (responseDict) {
        NSDictionary *parentDataDict = responseDict[@"SOAP-ENV:Body"];
        if (!parentDataDict[@"SOAP-ENV:Fault"]) {
            [self.tempCartProducts removeAllObjects];
            NSDictionary *dataDict = parentDataDict[@"ns1:shoppingCartProductAddResponse"][@"result"];
            BOOL requestStatus = [dataDict[@"__text"] boolValue];
            if (requestStatus) {
                
            }
        }
        else {
            NSLog(@"Error adding product to cart...");
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT" object:nil];
        }
    }else {
        //No categories found.
    }
    [STUtility stopActivityIndicatorFromView:nil];
}
/*
 {
 "SOAP-ENV:Body" =     {
 "ns1:shoppingCartProductAddResponse" =         {
 result =             {
 "__text" = true;
 "_xsi:type" = "xsd:boolean";
 };
 };
 };
 "_SOAP-ENV:encodingStyle" = "http://schemas.xmlsoap.org/soap/encoding/";
 "__name" = "SOAP-ENV:Envelope";
 "_xmlns:SOAP-ENC" = "http://schemas.xmlsoap.org/soap/encoding/";
 "_xmlns:SOAP-ENV" = "http://schemas.xmlsoap.org/soap/envelope/";
 "_xmlns:ns1" = "urn:Magento";
 "_xmlns:xsd" = "http://www.w3.org/2001/XMLSchema";
 "_xmlns:xsi" = "http://www.w3.org/2001/XMLSchema-instance";
 }
 */
@end
