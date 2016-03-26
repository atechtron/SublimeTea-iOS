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

//-(void)setMazdaAppCookie
//{
//    NSUserDefaults *sessionDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *sessionValue = [sessionDefaults objectForKey:@"SessionKey"];
//    
//    if(sessionValue.length) {
//        
//        [self clearCookiesForURL];
//        
//        NSDictionary *junctionCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                           PORTAL_NAME, NSHTTPCookieDomain,
//                                           @"\\", NSHTTPCookiePath,JUNCTION_NAME
//                                           , NSHTTPCookieName,
//                                           JUNCTION_VALUE, NSHTTPCookieValue,
//                                           nil];
//        
//        
//        
//        NSDictionary *sessionCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                           PORTAL_NAME, NSHTTPCookieDomain,
//                                           @"\\", NSHTTPCookiePath,
//                                           SESSION_KEY, NSHTTPCookieName,
//                                           sessionValue, NSHTTPCookieValue,
//                                           nil];
//        
//        NSHTTPCookie *junctionCookie = [NSHTTPCookie cookieWithProperties:junctionCookieProperties];
//        NSHTTPCookie *sessionCookie = [NSHTTPCookie cookieWithProperties:sessionCookieProperties];
//        
//        NSArray* cookieArray = [NSArray arrayWithObjects:junctionCookie,sessionCookie, nil];
//        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
//        [self setAllHTTPHeaderFields:headers];
//    }
//    
//    
//}

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
