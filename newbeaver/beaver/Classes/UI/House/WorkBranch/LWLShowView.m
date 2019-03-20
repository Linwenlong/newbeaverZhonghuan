//
//  LWLShowView.m
//  beaver
//
//  Created by 林文龙 on 2017/7/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "LWLShowView.h"
#import "SDAutoLayout.h"

@interface LWLShowView ()

/**
 近7日成交
 */
@property (nonatomic, strong) UILabel * textLable1;

/**
 近7日新增房源
 */
@property (nonatomic, strong) UILabel * textLable2;

/**
  近7日新增客源
 */
@property (nonatomic, strong) UILabel * textLable3;

//查看业绩排行
@property (nonatomic, strong) UIButton * button;

@property (nonatomic, strong) UIView * lineview;

@end

@implementation LWLShowView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    UIFont *bigFont = [UIFont boldSystemFontOfSize:30.0f];
    UIFont *smallFont = [UIFont systemFontOfSize:13.0f];
    UIColor *lableColor = UIColorFromRGB(0xff3800);
    UIColor *textLableColor = UIColorFromRGB(0x8a8a8a);
    
    _lable1 = [UICountingLabel new];
    _lable1.text  = @"0";
    _lable1.textAlignment= NSTextAlignmentCenter;
    _lable1.font = bigFont;
    _lable1.textColor = lableColor;
    
    _textLable1 = [UILabel new];
    _textLable1.text = @"近7日新增成交";
    _textLable1.textAlignment= NSTextAlignmentCenter;
    _textLable1.font = smallFont;
    _textLable1.textColor = textLableColor;
    
    
    _lable2 = [UICountingLabel new];
    _lable2.text  = @"0";
    _lable2.textAlignment= NSTextAlignmentCenter;
    _lable2.font = bigFont;
    _lable2.textColor = lableColor;
    
    _textLable2 = [UILabel new];
    _textLable2.text = @"近7日新增房源";
    _textLable2.textAlignment= NSTextAlignmentCenter;
    _textLable2.font = smallFont;
    _textLable2.textColor =textLableColor;
    
    
    _lable3 = [UICountingLabel new];
    _lable3.text  = @"0";
    _lable3.textAlignment= NSTextAlignmentCenter;
    _lable3.font = bigFont;
    _lable3.textColor = lableColor;
    
    _textLable3 = [UILabel new];
    _textLable3.text = @"近7日新增客源";
    _textLable3.textAlignment= NSTextAlignmentCenter;
    _textLable3.font = smallFont;
    _textLable3.textColor = textLableColor;
    
    _button = [UIButton new];
    [_button setTitleColor:lableColor forState:UIControlStateNormal];
    [_button setTitle:@"查看业绩排行" forState:UIControlStateNormal];
    
    [_button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _button.titleLabel.font = smallFont;
    _button.layer.cornerRadius = 15.0f;
    _button.layer.borderColor = lableColor.CGColor;
    _button.layer.borderWidth = 1.0f;
    _button.backgroundColor = [UIColor clearColor];
    
    _lineview = [UIView new];
    _lineview.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    [self sd_addSubviews:@[_lable1,_textLable1,_lable2,_textLable2,_lable3,_textLable3,_button,_lineview]];
    //添加约束
    
    CGFloat spcing = 10;
    CGFloat y = 30;
    CGFloat w = 100;
    
    //先添加中间两个
    _lable2.sd_layout
    .topSpaceToView(self,y)
    .centerXIs(self.centerX)
    .heightIs(30);
    
    [_lable2 setSingleLineAutoResizeWithMaxWidth:w];
    
    _textLable2.sd_layout
    .topSpaceToView(_lable2,spcing)
    .centerXIs(self.centerX)
    .heightIs(30);
    
    [_textLable2 setSingleLineAutoResizeWithMaxWidth:90];
    
    //左边两个
    CGFloat lable_x = 0;
    if (kScreenW > 320) {
        lable_x = 70/2;
    }else{
        lable_x = 30/2;
    }
    
    
    
    _lable1.sd_layout
    .topSpaceToView(self,y)
    .leftSpaceToView(self,lable_x)
    .heightIs(30)
    .widthIs(w);
    
//    [_lable1 setSingleLineAutoResizeWithMaxWidth:80];
    
    _textLable1.sd_layout
    .topSpaceToView(_lable1,spcing)
    .centerXEqualToView(_lable1)
    .heightIs(30)
    .widthIs(90);
    
//    [_textLable1 setSingleLineAutoResizeWithMaxWidth:90];
    
    //右边两个
    
    _lable3.sd_layout
    .topSpaceToView(self,y)
    .rightSpaceToView(self,lable_x)
    .heightIs(30)
    .widthIs(w);
    
//    [_lable3 setSingleLineAutoResizeWithMaxWidth:80];
    
    _textLable3.sd_layout
    .topSpaceToView(_lable3,spcing)
    .centerXEqualToView(_lable3)
    .heightIs(30)
    .widthIs(90);
    
//    [_textLable3 setSingleLineAutoResizeWithMaxWidth:90];
    
    //最后一个button
    
    _button.sd_layout
    .topSpaceToView(_textLable2,20)
    .centerXEqualToView(self)
    .heightIs(30);
    
    [_button setupAutoSizeWithHorizontalPadding:30 buttonHeight:30];
    
    _lineview.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .bottomSpaceToView(self,0)
    .heightIs(1);

    
}
- (void)btnClick:(UIButton *)btn{
    if (self.lwlShowViewDelegate && [self.lwlShowViewDelegate respondsToSelector:@selector(LWLShowViewBtnClick:)]) {
        [self.lwlShowViewDelegate LWLShowViewBtnClick:btn];
    }
}

@end
