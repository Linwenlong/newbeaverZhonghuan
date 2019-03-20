//
//  HeaderViewForDailCheckView.h
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderViewForDailCheckViewDelegate <NSObject>

- (void)btnClick:(UIButton *)btn;

@end

@interface HeaderViewForDailCheckView : UIView


- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)btns   BottonView:(UIView *)view;

- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)btns  isShowBottomView:(BOOL)isShowBottomView;

- (instancetype)initWithFrameWithContact:(CGRect)frame titleArr:(NSArray *)btns;

@property (nonatomic, weak)id<HeaderViewForDailCheckViewDelegate> headerViewDelegate;

@property (nonatomic, strong) UILabel *headerLable;

@property (nonatomic, strong) UILabel *leftLable;
@property (nonatomic, strong) UILabel *rightLable;

@property (nonatomic, weak) UIButton *zhiwuBtn;

//第二个,第三个
@property (nonatomic, weak) UIButton *dateBtn;
@property (nonatomic, weak) UIButton *totleTypeBtn;


@end
