//
//  AppDelegate.h
//  qrcode
//
//  Created by 何 义 on 13-10-19.
//  Copyright (c) 2013年 crazyant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) LoginViewController * loginView;

@end
