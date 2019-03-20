//
//  ContractHeaderView.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractHeaderView.h"

@interface ContractHeaderView ()

@property (nonatomic, strong)UIButton *leftBtn;
@property (nonatomic, strong)UIButton *rightBtn;

@end

@implementation ContractHeaderView

- (instancetype)initWithFrame:(CGRect)frame leftTitle:(NSString *)left rightTitle:(NSString *)right{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI:left right:right];
    }
    return self;
}

- (void)setUI:(NSString *)left right:(NSString *)right{
    
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    UIView *backview = [UIView new];
    backview.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _leftBtn = [UIButton new];
    _leftBtn.tag = 0;
    [_leftBtn setTitle:left forState:UIControlStateNormal];
    [_leftBtn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _rightBtn = [UIButton new];
    _rightBtn.tag = 1;
    [_rightBtn setTitle:right forState:UIControlStateNormal];
    [_rightBtn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *sliderView = [UIView new];
    sliderView.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [self sd_addSubviews:@[backview,line1,line2,_leftBtn,_rightBtn,sliderView]];
    
    line1.sd_layout
    .topSpaceToView(self,0)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(1);
    
    backview.sd_layout
    .topSpaceToView(line1,0)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(6);
    
    line2.sd_layout
    .topSpaceToView(backview,0)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(1);
    
    _leftBtn.sd_layout
    .topSpaceToView(self,8)
    .leftSpaceToView(self,0)
    .widthIs(kScreenW/2.0f)
    .heightIs(self.height-8);
    
    _rightBtn.sd_layout
    .topSpaceToView(self,8)
    .rightSpaceToView(self,0)
    .widthIs(kScreenW/2.0f)
    .heightIs(self.height-8);
    
    sliderView.sd_layout
    .topSpaceToView(self,8)
    .centerXEqualToView(self)
    .widthIs(1)
    .heightIs(self.height-8);
}

- (void)btnClick:(UIButton *)btn{
    if (self.contractDelegate && [self.contractDelegate respondsToSelector:@selector(currentBtn:otherBtn:)]) {
        if (btn.tag == 0) {
             [self.contractDelegate currentBtn:btn otherBtn:_rightBtn];
        }else{
            [self.contractDelegate currentBtn:btn otherBtn:_leftBtn];
        }
    }
}

@end
