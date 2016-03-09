//
//  STConstants.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMacros.h"

#define kStoreID 1

@interface STConstants : NSObject

+ (NSString *)getAPIURLWithParams:(NSString *)param;
+ (NSString *)storeId;

+ (NSString *)startSessionRequestBody;
+ (NSString *)categoryListRequestBody;
+ (NSString *)productListRequestBody;
+ (NSString *)productImageListRequestBodyWithId:(NSString *)prodId;
+ (NSString *)prodInfoRequestBodyWithID:(NSString *)prodId;

@end
