//
//  LWLWebViewController.h
//  WebViewDemo
//
//  Created by 林文龙 on 16/10/29.
//  Copyright © 2016年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ZHDCWebViewController : BaseViewController

@property (strong, nonatomic) NSURL *homeUrl;

/** 传入控制器、url、标题 */
- (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title;

@end

