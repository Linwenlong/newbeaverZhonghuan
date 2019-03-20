//
//  ButtonViews.h
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ButtonViewsDelegate <NSObject>

- (void)btnClick:(UIButton *)btn;

@end

@interface ButtonViews : UIScrollView

@property (nonatomic, weak) id<ButtonViewsDelegate> btnDelegate;

- (instancetype)initWithFrame:(CGRect)frame containView1:(NSArray *)firstArrays contaionView2:(NSArray *)secondArrays;

- (void)setUI:(NSArray *)firstArrays andView2:(NSArray *)secondArrays;

@end
