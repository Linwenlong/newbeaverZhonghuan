//
//  EBRefreshHeader.m
//  beaver
//
//  Created by 凯文马 on 15/12/16.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "EBRefreshHeader.h"

@interface EBRefreshHeader ()
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation EBRefreshHeader

#pragma mark - 懒加载子控件

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorViewStyle];
        loadingView.hidesWhenStopped = NO;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

#pragma mark - 公共方法
- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    self.loadingView = nil;
    [self setNeedsLayout];
}

#pragma makr - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    // 箭头的中心
    CGFloat centerX = self.mj_w * 0.5;
    CGFloat centerY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(centerX, centerY);
    
    // 圈圈
    self.loadingView.center = arrowCenter;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                [self.loadingView stopAnimating];
            }];
        } else {
            [self.loadingView stopAnimating];
            
        }
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView startAnimating];

    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
    }
}

@end
