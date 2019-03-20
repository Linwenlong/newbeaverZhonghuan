//
//  ButtonViews.m
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ButtonViews.h"
#import "MYButton.h"
#import "SDAutoLayout.h"

@interface ButtonViews ()

@property (nonatomic, strong)UIView *lineView1;

@end

@implementation ButtonViews

- (instancetype)initWithFrame:(CGRect)frame containView1:(NSArray *)firstArrays contaionView2:(NSArray *)secondArrays
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentSize = CGSizeMake(kScreenW*2, 0);
        self.backgroundColor = [UIColor whiteColor];
        self.pagingEnabled = YES;
        
        [self setUI:firstArrays andView2:secondArrays];
    }
    return self;
}

- (void)setUI:(NSArray *)firstArrays andView2:(NSArray *)secondArrays{
    
    //先移除上面所有的view
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, self.height)];
    
    _lineView1 = [UIView new];
    _lineView1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [self addSubview:_lineView1];
    
    _lineView1.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .topSpaceToView(self,0)
    .heightIs(1);
    
    //添加view1的按钮
    CGFloat btnW = 80;
    CGFloat btnH = 108;
    CGFloat btnX = 20;
    CGFloat btnY = 20;
    CGFloat margin = (kScreenW - 3*btnW - btnX*2)/2.0;
    for (int i = 0; i < firstArrays.count; i++) {

        UIButton *button = [[UIButton alloc]init];
        button.tag = i;
        [button setTitle:firstArrays[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font  =[UIFont systemFontOfSize:13.0f];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setImage:[UIImage imageNamed:firstArrays[i]] forState:UIControlStateNormal];
        //点击方法
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i < 3) {
            button.frame = CGRectMake(btnX+(btnW+margin)*i, btnY, btnW, btnH);
        }else{
            button.frame = CGRectMake(btnX+(btnW+margin)*(i-3), btnY+(btnH+btnY), btnW, btnH);
        }
        [view1 addSubview:button];
        
        //设置下图片跟文字的位置
        // 设置button的图片的约束
        button.imageView.sd_layout
        .widthRatioToView(button, 0.8)
        .topSpaceToView(button, 10)
        .centerXEqualToView(button)
        .heightRatioToView(button, 0.6);
        
        // 设置button的label的约束
        button.titleLabel.sd_layout
        .topSpaceToView(button.imageView, 10)
        .leftEqualToView(button.imageView)
        .rightEqualToView(button.imageView)
        .bottomSpaceToView(button, 10);
    }
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(kScreenW, 0, kScreenW, self.height)];
    
    for (int i = 0; i < secondArrays.count; i++) {
        UIButton *button = [[UIButton alloc]init];
        button.tag = 100+i;
     
        [button setTitle:secondArrays[i] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:secondArrays[i]] forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font  =[UIFont systemFontOfSize:13.0f];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        //点击方法
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i<3) {
            button.frame = CGRectMake(btnX+(btnW+margin)*i, btnY, btnW, btnH);
        }else{
            button.frame = CGRectMake(btnX+(btnW+margin)*(i-3), btnY+(btnH+btnY), btnW, btnH);
        }
        [view2 addSubview:button];
        //设置下图片跟文字的位置
        // 设置button的图片的约束
        button.imageView.sd_layout
        .widthRatioToView(button, 0.8)
        .topSpaceToView(button, 10)
        .centerXEqualToView(button)
        .heightRatioToView(button, 0.6);
        
        // 设置button的label的约束
        button.titleLabel.sd_layout
        .topSpaceToView(button.imageView, 10)
        .leftEqualToView(button.imageView)
        .rightEqualToView(button.imageView)
        .bottomSpaceToView(button, 10);
    }
    
     [self addSubview:view1];
     [self addSubview:view2];
}

- (void)btnClick:(UIButton *)btn{
    if (self.btnDelegate && [self.btnDelegate respondsToSelector:@selector(btnClick:)]) {
        [self.btnDelegate btnClick:btn];
    }
}

@end
