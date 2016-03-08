//
//  ViewController.h
//  SublimeTea
//
//  Created by Arpit Mishra on 24/02/16.
//  Copyright © 2016 Arpit Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "XMLDictionary.h"
#import "STConstants.h"
#import "STAppDelegate.h"

@interface STViewController : UIViewController

@property (nonatomic)BOOL menuButtonHidden;
@property (nonatomic)BOOL backButtonHidden;
@property (nonatomic)BOOL hideLeftBarItems;
@property (nonatomic)BOOL hideRightBarItems;

-(void)addNavBarButtons;
@end

