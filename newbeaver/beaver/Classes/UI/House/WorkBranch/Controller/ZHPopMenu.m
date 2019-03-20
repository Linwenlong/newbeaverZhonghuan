//
//  ZHPopMenu.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//

#define CZKeyWindow [UIApplication sharedApplication].keyWindow

#import "ZHPopMenu.h"

@implementation ZHPopMenu

// 显示弹出菜单
+ (instancetype)showInRect:(CGRect)rect
{
    ZHPopMenu *menu = [[ZHPopMenu alloc] initWithFrame:rect];
    menu.userInteractionEnabled = YES;
    //menu.image = [UIImage imageNamed:@"popover_background"];
    menu.backgroundColor = [UIColor clearColor];
    
    //    menu.backgroundColor = [UIColor whiteColor];
    
    [CZKeyWindow addSubview:menu];
    
    return menu;
}

// 隐藏弹出菜单
+ (void)hide
{
    for (UIView *popMenu in CZKeyWindow.subviews) {
        if ([popMenu isKindOfClass:self]) {
            [popMenu removeFromSuperview];
        }
    }
}

// 设置内容视图
- (void)setContentView:(UIView *)contentView
{
    // 先移除之前内容视图
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    contentView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:contentView];
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 计算内容视图尺寸
    //    CGFloat y = 9;
    //    CGFloat margin = 5;
    //    CGFloat x = margin;
    //    CGFloat w = self.width - 2 * margin;
    //    CGFloat h = self.height - y - margin;
    
    //_contentView.frame = CGRectMake(x, y, w, h);
    
    _contentView.frame = self.bounds;
    
}


@end
