//
//  HttpRequest.m
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STHttpRequest.h"
#import "Reachability.h"
#import "STConstants.h"

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
        [urlRequest setHTTPMethod:self.methodType];
        NSString *sMessageLength = [NSString stringWithFormat:@"%lu", (unsigned long)self.requestBody.length];
        
        [urlRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue: @"urn:Action" forHTTPHeaderField:@"SOAPAction"];
        [urlRequest addValue:kAPIdomainName forHTTPHeaderField:@"Host"];
        [urlRequest addValue: sMessageLength forHTTPHeaderField:@"Content-Length"];
        if(self.requestBody.length) {
            [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
        dbLog(@"%@",urlRequest);
        dbLog(@"%@",urlRequest.allHTTPHeaderFields);
        self.responseData = [[NSMutableData alloc] init];
        self.urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest
                                                            delegate:self];
    } else {
        self.failureBlock(nil);
        [STUtility stopActivityIndicatorFromView:nil];
    }
}
- (NSData *)synchronousStart {
    NSData *data;
    if ([STUtility isNetworkAvailable]) {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
        [urlRequest setHTTPMethod:self.methodType];
        NSString *sMessageLength = [NSString stringWithFormat:@"%lu", (unsigned long)self.requestBody.length];
        
        [urlRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue: @"urn:Action" forHTTPHeaderField:@"SOAPAction"];
        [urlRequest addValue:kAPIdomainName forHTTPHeaderField:@"Host"];
        [urlRequest addValue: sMessageLength forHTTPHeaderField:@"Content-Length"];
        if(self.requestBody.length) {
            [urlRequest setHTTPBody:[self.requestBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
        dbLog(@"%@",urlRequest);
        dbLog(@"%@",urlRequest.allHTTPHeaderFields);
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        if (self.failureBlock && error) {
         self.failureBlock(error);
        }
    }
    else {
        [STUtility stopActivityIndicatorFromView:nil];
    }
    return data;
}

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
