//
//  NSMutableURLRequest+MazdaCookie.m
//  
//
//  Created by Arpit Mishra on 25/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import "NSMutableURLRequest+URLCookie.h"
#include "STConstants.h"

@implementation NSMutableURLRequest (URLCookie)

- (void)clearCookiesForURL
{
    if (self.URL) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL:self.URL];
        for (NSHTTPCookie *cookie in cookies) {
            dbLog(@"Deleting cookie for domain: %@", [cookie domain]);
            [cookieStorage deleteCookie:cookie];
        }
    }
}
@end
