//
//  STCart.m
//  SublimeTea
//
//  Created by Apple on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STCart.h"
@implementation Product


@end

@interface STCart()

@property (strong, nonatomic)NSMutableArray *productsInCart;

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
    return [super init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [STCart defaultCart];
}

-(void)addProductsInCart:(NSDictionary *)prodDict withQty:(NSInteger)qty {
    if (prodDict && qty >0) {
        Product *prod = [Product new];
        prod.prodDict = prodDict;
        prod.prodQty = qty;
        [self.productsDataArr addObject:prod];
        
        NSString *prodId = prodDict[@"product_id"][@"__text"];
        [self.productsInCart addObject:@[prodId,[NSNumber numberWithInteger:qty]]];
    }
}
- (NSInteger)numberOfProductsInCart {
    return self.productsInCart.count;
}
@end
