//
//  ToConfirmedView.h
//  beaver
//
//  Created by mac on 17/10/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToConfirmedViewDelegate <NSObject>

- (void)viewDidClick:(UITapGestureRecognizer *)tap;

@end

@interface ToConfirmedView : UIScrollView

@property (nonatomic, weak) id<ToConfirmedViewDelegate> confirmdDelegate;

/**
 *  初始化未确认的View
 *
 *  @param frame      frame
 *  @param titleArr   标题数组
 *  @param numArr     数字数组
 *  @param titleColor 标题颜色
 *  @param numColor   数字颜色
 *
 *  @return 实体对象
 */
-(instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)titleArr numArr:(NSArray *)numArr titleColor:(UIColor *)titleColor numColor:(UIColor *)numColor other:(NSDictionary *)dic;

@end
