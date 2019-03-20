//
//  ZHDCCustomSheet.m
//  CentralManagerAssistant
//
//  Created by mac on 17/2/9.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//

#import "ZHDCCustomSheet.h"

@interface ZHDCCustomSheet ()

@property (nonatomic,strong) UIView * contentView;

@end

@implementation ZHDCCustomSheet

static NSArray * allbus = nil;

-(ZHDCCustomSheet*)initWithButtons:(NSArray*)allButtons
{
    allbus = allButtons;
    ZHDCCustomSheet * sheet = [[ZHDCCustomSheet alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [sheet set];
    return sheet;
}

-(void)set
{
    [UIView animateWithDuration:0.5 animations:^{
        _contentView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44*(allbus.count + 1) -10, [UIScreen mainScreen].bounds.size.width, 44*(allbus.count + 1 )+10);
    }];
}
-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {

        UIView *back = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        back.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGesture)];
        [back addGestureRecognizer:tap];
        
        [self addSubview:back];
        
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height,  [UIScreen mainScreen].bounds.size.width,44*allbus.count)];
        [self addSubview:_contentView];
        
        for (int i = 0; i<allbus.count; i++)
        {
            UIButton * bu = [UIButton buttonWithType:UIButtonTypeCustom];
            bu.tag = i;
            bu.backgroundColor = [UIColor whiteColor];
            bu.frame = CGRectMake(0, 44*i, [UIScreen mainScreen].bounds.size.width, 44);
            [_contentView addSubview:bu];
            [bu setTitle:allbus[i] forState:UIControlStateNormal];
            [bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [bu addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 1)];
            line.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
            [bu addSubview:line];
        }
        
        UIView *bView = [[UIView alloc]initWithFrame:CGRectMake(0, 44*allbus.count,[UIScreen mainScreen].bounds.size.width, 10)];
        bView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        [_contentView addSubview:bView];
        
        UIButton *cancalBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(bView.frame), [UIScreen mainScreen].bounds.size.width, 44)];
        [cancalBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancalBtn.backgroundColor = [UIColor whiteColor];
        [cancalBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancalBtn addTarget:self action:@selector(TapGesture) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:cancalBtn];
    }
    return self;
    
}

-(void)TapGesture
{
    [self removeFromSuperview];
}
-(void)clickButton:(UIButton*)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickButton: superView:)]) {
         [self.delegate  clickButton:button.tag superView:self];
    }
    [self removeFromSuperview];
}




@end

