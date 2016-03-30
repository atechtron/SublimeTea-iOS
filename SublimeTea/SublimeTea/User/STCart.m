//
//  STCart.m
//  SublimeTea
//
//  Created by Apple on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCart.h"
#import "STHttpRequest.h"
#import "STConstants.h"
#import "XMLDictionary.h"

@implementation Product

@end

@interface STCart()
@end

@implementation STCart

static STCart *sharedInstance;

+ (instancetype)defaultCart {
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] initUniqueInstance];
        });
    }
    return sharedInstance;
}
-(instancetype) initUniqueInstance {
    
    _productsInCart = [NSMutableArray new];
    _productsDataArr = [NSMutableArray new];
    _tempCartProducts = [NSMutableArray new];
    return [super init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [STCart defaultCart];
}

-(void)addProductsInCart:(NSDictionary *)prodDict withQty:(NSInteger)qty {
    
//    [STUtility startActivityIndicatorOnView:nil withText:@"Please Wait.."];
    if (prodDict && qty >0) {
        Product *prod = [Product new];
        prod.prodDict = prodDict;
        prod.prodQty = qty;
        [self.productsDataArr addObject:prod];
        
        NSString *prodId = prodDict[@"product_id"][@"__text"];
        NSString *sku = prodDict[@"sku"][@"__text"];
        NSDictionary *dataDict = @{@"product_id" : prodId,
                                   @"qty": [NSNumber numberWithInteger:qty],
                                   @"sku": sku};
        [self.productsInCart addObject:dataDict];
        [self.tempCartProducts addObject:dataDict];
    }
}
- (NSInteger)numberOfProductsInCart {
    return self.tempCartProducts.count;
}
- (void)removeProductFromCart:(NSInteger)idx {
    [self.productsDataArr removeObjectAtIndex:idx];
    [self.tempCartProducts removeObjectAtIndex:idx];
    [self.productsInCart removeObjectAtIndex:idx];
}
- (void)updateProductToCartAtIndex:(NSInteger)idx withQty:(NSInteger)qty {
    if (qty > 0) {
        Product *prod = self.productsDataArr[idx];
        prod.prodQty = qty;
        [self.productsDataArr replaceObjectAtIndex:idx
                                        withObject:prod];
        
        NSMutableDictionary *prodDict = [self.tempCartProducts[idx] mutableCopy];
        [prodDict setObject:[NSNumber numberWithInteger:qty] forKey:@"qty"];
        
        [self.tempCartProducts replaceObjectAtIndex:idx
                                         withObject:prodDict];
        [self.productsInCart replaceObjectAtIndex:idx
                                       withObject:prodDict];
    }
}
@end
