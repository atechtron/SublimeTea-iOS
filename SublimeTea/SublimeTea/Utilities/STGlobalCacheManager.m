//
//  ParloreGlobalCacheManager.m
//  Parlore
//
//  Created by Arpit Mishra on 06/02/15.
//  Copyright (c) 2015 Parlore. All rights reserved.
//


#import "STGlobalCacheManager.h"

@interface STGlobalCacheManager ()
{
    NSCache *globalCache;
}
@end

@implementation STGlobalCacheManager

static STGlobalCacheManager *sharedInstance;

+ (instancetype)defaultManager{
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] initUniqueInstance];
        });
    }
    return sharedInstance;
}
-(instancetype) initUniqueInstance {
    globalCache = [[NSCache alloc] init];
    return [super init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [STGlobalCacheManager defaultManager];
}
- (BOOL)addItemToCache:(id)item withKey:(NSString *)itemKey{
    NSString *trimmedItemKey = [itemKey stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceCharacterSet]];
    BOOL isSuccessfullyAdded = NO;
    if (trimmedItemKey.length && item) {
        [globalCache setObject:item forKey:trimmedItemKey];
        isSuccessfullyAdded = YES;
    }
    return isSuccessfullyAdded;
}
- (id)getItemForKey:(NSString *)itemKey{
    id item = nil;
    NSString *trimmedItemKey = [itemKey stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if (trimmedItemKey.length) {
        item = [globalCache objectForKey:trimmedItemKey];
    }
    return item;
}
- (BOOL)removeItemFromCacheWithKey:(NSString *)itemKey{
    NSString *trimmedItemKey = [itemKey stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceCharacterSet]];
    BOOL isSuccessfullyRemoved = NO;
    if (trimmedItemKey.length) {
        [globalCache removeObjectForKey:trimmedItemKey];
    }
    return isSuccessfullyRemoved;
}
- (void)clearGlobalCache{
    [globalCache removeAllObjects];
    globalCache = nil;
}

@end
