//
//  newViewController.h
//  TestKit
//
//  Created by Saravana Kumar Annadurai on 14/12/15.
//  Copyright (c) 2015 Saravana Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newViewController : UIViewController
{
    NSDictionary *dict;
    
}
@property(nonatomic,retain)NSMutableDictionary *jsondict;
@property(nonatomic,retain)IBOutlet UIScrollView *scroll;


@end
