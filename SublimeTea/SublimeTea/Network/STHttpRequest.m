//
//  HttpRequest.m
//  MazdaDealerService
//
//  Created by Shanmukesh on 6/22/15.
//  Copyright (c) 2015 Mazda. All rights reserved.
//

#import "STHttpRequest.h"
#import "STMacros.h"
#import "Reachability.h"

#define kAccept_key @"Accept"
#define kAccept_val @"text/plain"

#define kRSHeaderIV_key @"RS_SEC_HDR_IV_NAME"
#define kRSHeaderIV_val @"BrsjDK6t5TSQ+SoxRS6QAg=="

#define kRSHeaderTK_key @"RS_SEC_HDR_TOKEN_NAME"
#define kRSHeaderTK_val @"Y6CzeV3vPYvyjR4cSI2y38FRk8EcwMjNr0QHlDqe0rU="

#define kRSHeaderVID_key @"RS_SEC_HDR_VENDOR_ID"
#define kRSHeaderVID_val @"mnao"

#define NO_INTERNET_MSG @"Please make sure you have an active Internet connection and try again."

@interface STHttpRequest()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *methodType;
@property (nonatomic, strong) NSString *requestBody;
@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;
@property (nonatomic, copy) ResponseBlock responseBlock;

@end

@implementation STHttpRequest

//-(id)initWithURL:(NSURL *)requestURL
//      methodType:(NSString *)methodType
//            body:(NSString *)requestBody
//        responseHeaderBlock:(ResponseBlock)responseBlock
//    successBlock:(SuccessBlock)successBlock
//    failureBlock:(FailureBlock)failureBlock
//{
//    self = [super init];
//    if (self) {
//        self.url  = requestURL;
//        self.successBlock  = successBlock;
//        self.failureBlock = failureBlock;
//        self.responseBlock = responseBlock;
//        self.methodType = methodType;
//        self.requestBody = requestBody;
//    }
//    return  self;
//}
//
//-(void)start {
//    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
//    if ([reachability isReachable]) {
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
//        [urlRequest setMazdaAppCookie];
//        [urlRequest setHTTPMethod:self.methodType];
//        if(self.requestBody.length) {
//            if([[self.url absoluteString] rangeOfString:@"login"].location != NSNotFound) {
//                
//                //Percentile Escape encoding is needed only in LoginAPI as user might have % character as a Password.
//                NSString *escapedCharString = [self.requestBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                [urlRequest setHTTPBody:[escapedCharString dataUsingEncoding:NSUTF8StringEncoding]];
//            } else {
//                [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
//            }
//        }
//        self.responseData = [[NSMutableData alloc] init];
//        self.urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest
//                                                            delegate:self];
//    } else {
//        self.failureBlock(nil);
//        // Network not available
//        [MazdaUtility showAlertForNoInternetConnectionWithMessage:NO_INTERNET_MSG];
//    }
//}
//- (void)startSalesxMDS {
//    [self startSalesxMDS:@"application/x-www-form-urlencoded" withAcceptHeader:@"application/xml"];
//}
//
//- (void) startSalesxMDS:(NSString *)contentType withAcceptHeader:(NSString *)acceptHeader {
//    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
//    if ([reachability isReachable]) {
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
//        
//        [urlRequest setHTTPMethod:self.methodType];
//        [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
//        [urlRequest addValue:acceptHeader forHTTPHeaderField:kAccept_key];
//        [urlRequest addValue:kRSHeaderIV_val forHTTPHeaderField:kRSHeaderIV_key];
//        [urlRequest addValue:kRSHeaderTK_val forHTTPHeaderField:kRSHeaderTK_key];
//        [urlRequest addValue:kRSHeaderVID_val forHTTPHeaderField:kRSHeaderVID_key];
//        
//        if(self.requestBody.length) {
//            [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
//        }
//        self.responseData = [[NSMutableData alloc] init];
//        self.urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest
//                                                            delegate:self];
//    } else {
//        self.failureBlock(nil);
//        // Network not available
//        [MazdaUtility showAlertForNoInternetConnectionWithMessage:NO_INTERNET_MSG];
//    }
//}
//- (void)startWithAuth:(BOOL)isAuthReq {
//    if (isAuthReq) {
//        [self start];
//    }else {
//        Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
//        if ([reachability isReachable]) {
//            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
//
//            [urlRequest setHTTPMethod:self.methodType];
//            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//            [urlRequest addValue:kAccept_val forHTTPHeaderField:kAccept_key];
//            [urlRequest addValue:kRSHeaderIV_val forHTTPHeaderField:kRSHeaderIV_key];
//            [urlRequest addValue:kRSHeaderTK_val forHTTPHeaderField:kRSHeaderTK_key];
//            [urlRequest addValue:kRSHeaderVID_val forHTTPHeaderField:kRSHeaderVID_key];
//            
//            if(self.requestBody.length) {
//                [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
//            }
//            self.responseData = [[NSMutableData alloc] init];
//            self.urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest
//                                                                delegate:self];
//        } else {
//            self.failureBlock(nil);
//            // Network not available
//            // This method is only called from postUsageDataAnalyticsDataToServer, which is a background process and does not need to show the warning message, hence below line of code to show a warning pop up is commented.
//            //[MazdaUtility showAlertForNoInternetConnectionWithMessage:NO_INTERNET_MSG];
//        }
//    }
//}
//
//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    self.responseBlock(response);
//}
//
//-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.responseData appendData:data];
//}
//
//-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    self.failureBlock(error);
//    
//}
//
//-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    self.successBlock(self.responseData);
//}
@end
