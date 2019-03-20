//
//  HeaderViewForDailCheckView.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HeaderViewForDailCheckView.h"
#import "Topbutton.h"

@implementation HeaderViewForDailCheckView


- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)btns   BottonView:(UIView *)view{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI:btns showBottonView:view];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)btns isShowBottomView:(BOOL)isShowBottomView
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI:btns showView:isShowBottomView];
    }
    return self;
}


- (instancetype)initWithFrameWithContact:(CGRect)frame titleArr:(NSArray *)btns{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUIForContact:btns];
    }
    return self;
}

- (void)setUI:(NSArray *)btns showBottonView:(UIView*)bottomView{
    CGFloat btn_h = self.height;
    
    btn_h = self.height-34;
    CGFloat btnw = self.width/btns.count;
    for (int i = 0; i < btns.count; i++) {
        Topbutton *btn = [[Topbutton alloc]initWithFrame:CGRectMake(btnw*i, 0, btnw, btn_h)];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClickMethod:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00].CGColor;
        [btn setTitle:btns[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
        btn.titleLabel.font  = [UIFont systemFontOfSize:13.0f];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setImage:[UIImage imageNamed:@"pullDown"] forState:UIControlStateNormal];
        [self addSubview:btn];
    }
 
    bottomView.frame = CGRectMake(0, self.height-34, kScreenW, 34);
    bottomView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    [self addSubview:bottomView];
    //404040 808080
    CGFloat lable_H = 20;
    CGFloat lable_X = 15;
    CGFloat lable_W = (kScreenW - 2*lable_X)/2;
    CGFloat lable_Y = (bottomView.height- 1 -lable_H)/2.0f;
    _leftLable = [[UILabel alloc]initWithFrame:CGRectMake(lable_X, lable_Y, lable_W, lable_H)];
    _leftLable.textColor = UIColorFromRGB(0x404040);
    _leftLable.font = [UIFont systemFontOfSize:12.0f];
    _leftLable.textAlignment = NSTextAlignmentLeft;
    
    NSString *leftStr = @"总额 (元) : 15000";
    NSLog(@"leftStr = %ld",leftStr.length);
    NSMutableAttributedString *attributeStr1 =[[NSMutableAttributedString alloc]initWithString:leftStr];
    [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 8)];
    [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(8, leftStr.length-8)];
    _leftLable.attributedText = attributeStr1;
    
    [bottomView addSubview:_leftLable];
    
    _rightLable = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2.0f, lable_Y, lable_W, lable_H)];
    _rightLable.textColor = UIColorFromRGB(0x404040);
    _rightLable.font = [UIFont systemFontOfSize:12.0f];
    _rightLable.textAlignment = NSTextAlignmentRight;

    NSString *rightStr = @"总量 (条) : 158";
    NSLog(@"rightStr = %ld",rightStr.length);
    NSMutableAttributedString *attributeStr2 =[[NSMutableAttributedString alloc]initWithString:rightStr];
    [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 8)];
    [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(8, rightStr.length-8)];
    _rightLable.attributedText = attributeStr2;
    
    [bottomView addSubview:_rightLable];
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(0, 33, kScreenW, 1)];
    lineview.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [bottomView addSubview:lineview];
}


- (void)setUI:(NSArray *)btns showView:(BOOL)isShowBottomView{
        CGFloat btn_h = self.height;
    
    if (isShowBottomView == YES){
        btn_h = self.height-45;
    }else{
        btn_h = self.height;
    }
    
    CGFloat btnw = self.width/btns.count;
    for (int i = 0; i < btns.count; i++) {
        Topbutton *btn = [[Topbutton alloc]initWithFrame:CGRectMake(btnw*i, 0, btnw, btn_h)];
        if (i == 0) {
            _zhiwuBtn = btn;
        }else if (i == 1){
            _dateBtn = btn;
        }else if (i == 2){
            _totleTypeBtn = btn;
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClickMethod:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00].CGColor;
        [btn setTitle:btns[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
        btn.titleLabel.font  = [UIFont systemFontOfSize:13.0f];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setImage:[UIImage imageNamed:@"pullDown"] forState:UIControlStateNormal];
        [self addSubview:btn];
    }
    if (isShowBottomView == YES) {
        _headerLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.height-45, kScreenW, 45)];
        _headerLable.text = @"共0条数据";
        _headerLable.font = [UIFont systemFontOfSize:14.0f];
        _headerLable.textColor =  UIColorFromRGB(0xa4a4a4);
        _headerLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_headerLable];
    }
}

- (void)setUIForContact:(NSArray *)btns{
    
    self.backgroundColor = [UIColor whiteColor];
    CGFloat btn_h = self.height;
    
    
    CGFloat btnw = self.width/btns.count;
    for (int i = 0; i < btns.count; i++) {
        Topbutton *btn = [[Topbutton alloc]initWithFrame:CGRectMake(btnw*i, 0, btnw, btn_h)];
        if (i != btns.count - 1) {
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), 13, 1, 20)];
            line.backgroundColor = UIColorFromRGB(0xDCDCDC);
            [self addSubview:line];
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClickMethod:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:btns[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x474747) forState:UIControlStateNormal];
        btn.titleLabel.font  = [UIFont systemFontOfSize:15.0f];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:btn];
    }
}



- (void)btnClickMethod:(UIButton *)btn{
    if (self.headerViewDelegate && [self.headerViewDelegate respondsToSelector:@selector(btnClick:)]) {
        [self.headerViewDelegate btnClick:btn];
    }
}

@end
