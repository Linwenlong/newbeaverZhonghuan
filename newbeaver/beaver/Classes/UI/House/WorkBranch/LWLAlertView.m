//
//  LWLAlertView.m
//  beaver
//
//  Created by mac on 17/10/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "LWLAlertView.h"

@interface LWLAlertView ()

@property (nonatomic, strong)UIButton *cancle;//取消
@property (nonatomic, strong)UIButton *comfire;//确认

@end

@implementation LWLAlertView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
       self.alpha = 0.7;
       [self createUI];
    }
    return self;
}

- (void)createUI{

    UILabel *lable = [UILabel new];
    lable.text = @"确认";
    lable.textColor = [UIColor whiteColor];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont boldSystemFontOfSize:18.0f];
    [self addSubview:lable];
    
    UIView *view1 = [UIView new];
    view1.backgroundColor = [UIColor whiteColor];
    [self addSubview:view1];
    
    UILabel *lable1 = [UILabel new];
    lable1.text = @"是否确定进行该操作?";
    lable1.textColor = [UIColor whiteColor];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.font = [UIFont systemFontOfSize:16.0f];
    [self addSubview:lable1];
    
    UIView *view2 = [UIView new];
    view2.backgroundColor = [UIColor whiteColor];
    [self addSubview:view2];
    
    _cancle = [UIButton new];
    _cancle.tag = 1;
    [_cancle setTitle:@"取消" forState:UIControlStateNormal];
    [_cancle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancle addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancle.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [self addSubview:_cancle];
    
    UIView *view3 = [UIView new];
    view3.backgroundColor = [UIColor whiteColor];
    [self addSubview:view3];
    
    _comfire = [UIButton new];
    [_comfire addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _comfire.tag = 2;
    [_comfire setTitle:@"确认" forState:UIControlStateNormal];
    [_comfire setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _comfire.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [self addSubview:_comfire];
    
    CGFloat h = 40;
    lable.sd_layout
    .topSpaceToView(self,0)
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .heightIs(h);
    
    view1.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .topSpaceToView(lable,0)
    .heightIs(1);
    
    lable1.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .topSpaceToView(lable,0)
    .heightIs(90);
    
    view2.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .topSpaceToView(lable1,0)
    .heightIs(1);
    
    _cancle.sd_layout
    .leftSpaceToView(self,0)
    .topSpaceToView(view2,0)
    .widthIs(self.width/2.0f)
    .heightIs(h);
    
     view3.sd_layout
    .leftSpaceToView(_cancle,0)
    .topSpaceToView(view2,0)
    .widthIs(1)
    .heightIs(h);
    
    _comfire.sd_layout
    .leftSpaceToView(view3,0)
    .topSpaceToView(view2,0)
    .widthIs(self.width/2.0f-1)
    .heightIs(h);
}

- (void)btnClick:(UIButton *)sender{
    if (self.alertViewDelegate && [self.alertViewDelegate respondsToSelector:@selector(alertViewSelectedBtn:)]) {
        [self.alertViewDelegate alertViewSelectedBtn:sender];
    }
}

@end
