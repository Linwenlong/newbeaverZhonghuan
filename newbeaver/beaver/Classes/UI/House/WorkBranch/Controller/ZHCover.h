//
//  ZHCover.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZHCover;
@protocol ZHCoverDelegate <NSObject>

@optional
// 点击蒙板的时候调用
- (void)coverDidClickCover:(ZHCover *)cover;

@end

@interface ZHCover : UIView
/**
 *  显示蒙板
 */
+ (instancetype)show;

// 设置浅灰色蒙板
@property (nonatomic, assign) BOOL dimBackground;

@property (nonatomic, weak) id<ZHCoverDelegate> delegate;

@end
