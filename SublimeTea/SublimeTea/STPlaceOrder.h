//
//  STPlaceOrder.h
//  SublimeTea
//
//  Created by Apple on 17/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STAddress.h"

@protocol STPlaceOrderDelegate <NSObject>
- (void)orderResultWithId:(NSString *)orderId;
@end


@interface STPlaceOrder : NSObject
@property (strong, nonatomic)STAddress *address;
@property (weak, nonatomic)id <STPlaceOrderDelegate> delegate;

- (void)placeOrder;
@end
