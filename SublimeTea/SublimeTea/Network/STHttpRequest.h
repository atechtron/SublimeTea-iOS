//
//  HttpRequest.h
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSMutableURLRequest+URLCookie.h"
#import "STMacros.h"
#import "STUtility.h"

typedef void(^ResponseBlock)(NSURLResponse *response);
typedef void(^SuccessBlock)(NSData *responseData);
typedef void(^FailureBlock)(NSError *error);

@interface STHttpRequest : NSObject<NSURLSessionDelegate>

- (id)initWithURL:(NSURL *)requestURL methodType:(NSString *)methodType body:(NSString *)requestBody responseHeaderBlock:(ResponseBlock)responseBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
- (void)start;
//- (void)startWithAuth:(BOOL)isAuthReq;
//- (void)startSalesxMDS;
//- (void)startSalesxMDS:(NSString *) withContentType withAcceptHeader:(NSString *) acceptHeader;

@end
