//
//  UITabBar+badge.h
//  beaver
//
//  Created by linger on 16/3/1.
//  Copyright © 2016年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
