//
//  STCart.h
//  SublimeTea
//
//  Created by Apple on 09/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product:NSObject

@property (strong,nonatomic) NSDictionary *prodDict;
@property (nonatomic) NSInteger prodQty;
@property (nonatomic) BOOL buy;
@end

@interface STCart : NSObject
{

}
@property (strong, nonatomic)NSMutableArray *productsDataArr;

@property (strong, nonatomic)NSMutableArray *productsInCart;
@property (strong, nonatomic)NSString *cartId;

@property (strong, nonatomic)NSMutableArray *tempCartProducts;

+ (STCart *)defaultCart;

+ (instancetype) alloc __attribute__((unavailable("alloc not available, call defaultManager instead")));
- (instancetype) init  __attribute__((unavailable("init not available, call defaultManager instead")));
+ (instancetype) new   __attribute__((unavailable("new not available, call defaultManager instead")));

- (void)addProductsInCart:(NSDictionary *)prodDict withQty:(NSInteger)qty;
- (void)removeProductFromCart:(NSInteger)idx;
- (void)updateProductToCartAtIndex:(NSInteger)idx withQty:(NSInteger)qty;

- (NSInteger)numberOfProductsInCart;
@end
