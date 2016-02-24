//
//  HttpRequest.h
//  MazdaDealerService
//
//  Created by Shanmukesh on 6/22/15.
//  Copyright (c) 2015 Mazda. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NSMutableURLRequest+MazdaCookie.h"

typedef void(^ResponseBlock)(NSURLResponse *response);
typedef void(^SuccessBlock)(NSData *responseData);
typedef void(^FailureBlock)(NSError *error);

@interface STHttpRequest : NSObject<NSURLSessionDelegate>

- (id)initWithURL:(NSURL *)requestURL methodType:(NSString *)methodType body:(NSString *)requestBody responseHeaderBlock:(ResponseBlock)responseBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
- (void)start;
- (void)startWithAuth:(BOOL)isAuthReq;
- (void)startSalesxMDS;
- (void)startSalesxMDS:(NSString *) withContentType withAcceptHeader:(NSString *) acceptHeader;

@end
