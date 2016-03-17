//
//  STPlaceOrder.h
//  SublimeTea
//
//  Created by Apple on 17/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STAddress.h"

@interface STPlaceOrder : NSObject
@property (strong, nonatomic)STAddress *address;

- (void)placeOrder;
@end
