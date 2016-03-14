//
//  HttpRequest.m
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STHttpRequest.h"
#import "Reachability.h"

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

-(id)initWithURL:(NSURL *)requestURL
      methodType:(NSString *)methodType
            body:(NSString *)requestBody
        responseHeaderBlock:(ResponseBlock)responseBlock
    successBlock:(SuccessBlock)successBlock
    failureBlock:(FailureBlock)failureBlock
{
    self = [super init];
    if (self) {
        self.url  = requestURL;
        self.successBlock  = successBlock;
        self.failureBlock = failureBlock;
        self.responseBlock = responseBlock;
        self.methodType = methodType;
        self.requestBody = requestBody;
    }
    return  self;
}

-(void)start {
    
    if ([STUtility isNetworkAvailable]) {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
//        [urlRequest clearCookiesForURL];
//        [urlRequest setMazdaAppCookie];
        [urlRequest setHTTPMethod:self.methodType];
        NSString *sMessageLength = [NSString stringWithFormat:@"%lu", (unsigned long)self.requestBody.length];
        
        [urlRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue: @"urn:Action" forHTTPHeaderField:@"SOAPAction"];
        [urlRequest addValue:@"dev.sublime-house-of-tea.com" forHTTPHeaderField:@"Host"];
        [urlRequest addValue: sMessageLength forHTTPHeaderField:@"Content-Length"];
        if(self.requestBody.length) {
            [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
        NSLog(@"%@",urlRequest);
        NSLog(@"%@",urlRequest.allHTTPHeaderFields);
        self.responseData = [[NSMutableData alloc] init];
        self.urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest
                                                            delegate:self];
    } else {
        self.failureBlock(nil);
    }
}
- (NSData *)synchronousStart {
    NSData *data;
    if ([STUtility isNetworkAvailable]) {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
        //        [urlRequest clearCookiesForURL];
        //        [urlRequest setMazdaAppCookie];
        [urlRequest setHTTPMethod:self.methodType];
        NSString *sMessageLength = [NSString stringWithFormat:@"%lu", (unsigned long)self.requestBody.length];
        
        [urlRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue: @"urn:Action" forHTTPHeaderField:@"SOAPAction"];
        [urlRequest addValue:@"dev.sublime-house-of-tea.com" forHTTPHeaderField:@"Host"];
        [urlRequest addValue: sMessageLength forHTTPHeaderField:@"Content-Length"];
        if(self.requestBody.length) {
            [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
        NSLog(@"%@",urlRequest);
        NSLog(@"%@",urlRequest.allHTTPHeaderFields);
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        NSLog(@"Error in processing suncronous request:- %@",error);
    }
    return data;
}
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
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseBlock(response);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.failureBlock(error);
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.successBlock(self.responseData);
}
@end
