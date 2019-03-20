//
//  FinancialHeaderView.m
//  beaver
//
//  Created by mac on 17/11/26.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialHeaderView.h"
#import "SDAutoLayout.h"

@implementation FinancialHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI];
    }
    return self;
}
- (void)setUI{
    UIButton *leftBtn = [UIButton new];
    leftBtn.tag = 0;
    [leftBtn setTitle:@"客 户" forState:UIControlStateNormal];
    [leftBtn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton new];
     rightBtn.tag = 1;
    [rightBtn setTitle:@"业 主" forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _sliderview = [UIView new];
    _sliderview.backgroundColor = UIColorFromRGB(0xff3800);
    [self sd_addSubviews:@[leftBtn,rightBtn,_sliderview]];
    
    leftBtn.sd_layout
    .topSpaceToView(self,0)
    .leftSpaceToView(self,0)
    .widthIs(kScreenW/2.0f)
    .heightIs(50);
    
    rightBtn.sd_layout
    .topSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .widthIs(kScreenW/2.0f)
    .heightIs(50);
    
    CGFloat view_w = 50;
    CGFloat view_h = 3;
    _sliderview.sd_layout
    .bottomSpaceToView(self,0)
    .centerXEqualToView(leftBtn)
    .widthIs(view_w)
    .heightIs(view_h);
    
}

- (void)btnClick:(UIButton *)btn{
    if (self.financiaDelegate && [self.financiaDelegate respondsToSelector:@selector(currentPage:)]) {
        [self.financiaDelegate currentPage:btn.tag];
    }
}

@end
