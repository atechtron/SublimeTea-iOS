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

- (instancetype)init {
    if (self == [super init]) {
        
    }
    return self;
}

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
    NSMutableArray *propertyKeys = [NSMutableArray array];
    Class currentClass = self.class;
    
    while ([currentClass superclass]) { // avoid printing NSObject's attributes
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if (propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                [propertyKeys addObject:propertyName];
            }
        }
        free(properties);
        currentClass = [currentClass superclass];
    }
    
    return [self dictionaryWithValuesForKeys:propertyKeys];
}
@end

@implementation Billing

- (instancetype)init {
    if (self == [super init]) {
        
    }
    return self;
}

- (NSString *)mode {
    return @"billing";
}
- (NSDictionary *)dictionary {
    NSMutableArray *propertyKeys = [NSMutableArray array];
    Class currentClass = self.class;
    
    while ([currentClass superclass]) { // avoid printing NSObject's attributes
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if (propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                [propertyKeys addObject:propertyName];
            }
        }
        free(properties);
        currentClass = [currentClass superclass];
    }
    
    return [self dictionaryWithValuesForKeys:propertyKeys];
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
