//
//  STAddress.h
//  SublimeTea
//
//  Created by Apple on 17/03/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shipping : NSObject

@property (strong, nonatomic)NSString *mode;
@property (strong, nonatomic)NSString *firstname;
@property (strong, nonatomic)NSString *lastname;
@property (strong, nonatomic)NSString *street;
@property (strong, nonatomic)NSString *city;
@property (strong, nonatomic)NSString *region;
@property (strong, nonatomic)NSString *region_id;
@property (strong, nonatomic)NSString *postcode;
@property (strong, nonatomic)NSString *country_id;
@property (strong, nonatomic)NSString *telephone;
@property (strong, nonatomic)NSString *email;
@property (nonatomic) NSInteger is_default_shipping;
@property (nonatomic) NSInteger is_default_billing;

- (NSDictionary *)dictionary;
@end

@interface Billing : Shipping

//@property (strong, nonatomic)NSString *couponCode;
- (NSDictionary *)dictionary;
@end

@interface STAddress : NSObject

@property (strong, nonatomic)Shipping *shipAddress;
@property (strong, nonatomic)Billing *billedAddress;
@property (nonatomic)BOOL isBillingIsShipping;
@end
