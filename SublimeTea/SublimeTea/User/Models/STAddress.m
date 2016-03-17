//
//  STAddress.m
//  SublimeTea
//
//  Created by Apple on 17/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STAddress.h"
#import <objc/runtime.h>

@implementation Shipping

- (NSInteger)is_default_billing {
    return 0;
}
- (NSInteger)is_default_shipping {
    return 0;
}
- (NSString *)mode {
    return @"shipping";
}
- (NSDictionary *)dictionary {
    unsigned int count = 0;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];
        
        if (value == nil) {
            // nothing todo
        }
        else if ([value isKindOfClass:[NSNumber class]]
                 || [value isKindOfClass:[NSString class]]
                 || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableArray class]]) {
            // TODO: extend to other types
            [dictionary setObject:value forKey:key];
        }
        else if ([value isKindOfClass:[NSObject class]]) {
            [dictionary setObject:[value dictionary] forKey:key];
        }
        else {
            NSLog(@"Invalid type for %@ (%@)", NSStringFromClass([self class]), key);
        }
    }
    free(properties);
    return dictionary;
}
@end

@implementation Billing

- (NSString *)mode {
    return @"billing";
}

@end


@implementation STAddress

- (instancetype)init {
    if (self == [super init]) {
        _shipAddress = [Shipping new];
        _billedAddress = [Billing new];
    }
    return self;
}
- (void)setIsBillingIsShipping:(BOOL)isBillingIsShipping {
    if (isBillingIsShipping) {
//        _billedAddress = [_shipAddress copy];
        _isBillingIsShipping = isBillingIsShipping;
    }
}
@end
