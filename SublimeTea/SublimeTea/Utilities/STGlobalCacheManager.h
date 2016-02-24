//
//  ParloreGlobalCacheManager.h
//  Parlore
//
//  Created by Arpit Mishra on 06/02/15.
//  Copyright (c) 2015 Parlore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGlobalCacheManager : NSObject

+ (STGlobalCacheManager *)defaultManager;
- (BOOL)addItemToCache:(id)item withKey:(NSString *)itemKey;
- (instancetype)getItemForKey:(NSString *)itemKey;
- (BOOL)removeItemFromCacheWithKey:(NSString *)itemKey;
- (void)clearGlobalCache;

+(instancetype) alloc __attribute__((unavailable("alloc not available, call defaultManager instead")));
-(instancetype) init  __attribute__((unavailable("init not available, call defaultManager instead")));
+(instancetype) new   __attribute__((unavailable("new not available, call defaultManager instead")));

@end
