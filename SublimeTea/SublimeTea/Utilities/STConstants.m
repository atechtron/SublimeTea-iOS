//
//  STConstants.m
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "STConstants.h"

#define kAPI_ENDPOINT @"http://dev.sublime-house-of-tea.com/index.php/api/v2_soap/index/"

@implementation STConstants

+ (NSString *)getAPIURLWithParams:(NSString *)param {
    NSString *str;
    if (!param || !param.length) {
        str = kAPI_ENDPOINT;
    }
    else
    {
        str = [NSString stringWithFormat:@"%@%@",kAPI_ENDPOINT,param];
    }
    return str;
}

@end
