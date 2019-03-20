//
//  KWProgressCircleView.h
//  KWProgressCircleViewDemo
//
//  Created by 凯文马 on 15/12/16.
//  Copyright © 2015年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KWProgressComponent;

@interface KWProgressCircleView : UIView

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong) NSArray *percents;

@property (nonatomic, strong) UIColor *tintColor;

+ (instancetype)progressCircleViewWithPercents:(NSArray *)percents frame:(CGRect)frame;

+ (instancetype)progressCircleViewWithPercents:(NSArray *)percents;

+ (instancetype)progressCircleViewWithPercent:(KWProgressComponent *)percent;

+ (instancetype)progressCircleViewWithPercent:(KWProgressComponent *)percent withPercentText:(BOOL)text andAnimation:(BOOL)animation;

/**
 *   用于带动画的视图渲染
 */
- (void)startAnimationWithTimeInterval:(CGFloat)timeInterval;

@end


@interface KWProgressComponent : NSObject

@property (nonatomic, assign) CGFloat percent;

@property (nonatomic, strong) UIColor *color;

+ (instancetype)componentWithPercent:(CGFloat)percent color:(UIColor *)color;

@end