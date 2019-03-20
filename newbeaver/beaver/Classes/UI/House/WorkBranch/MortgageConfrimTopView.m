//
//  MortgageConfrimTopView.m
//  dev-beaver
//
//  Created by 林文龙 on 2019/1/8.
//  Copyright © 2019年 eall. All rights reserved.
//

#import "MortgageConfrimTopView.h"

@interface MortgageConfrimTopView ()


@property (nonatomic, strong) UILabel * groupTitle;
@property (nonatomic, strong) UITextField * groupName;

@property (nonatomic, strong) UIView * line;
@property (nonatomic, strong) UIView * line1;

@property (nonatomic, strong) UIButton * cancle;
@property (nonatomic, strong) UIButton * submit;

@end

@implementation MortgageConfrimTopView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)str {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        
        [self setUI:str];
    }
    return self;
}

- (void)setUI:(NSString *)str{
    
    _groupTitle = [UILabel new];
    _groupTitle.textAlignment = NSTextAlignmentCenter;
    _groupTitle.font = [UIFont systemFontOfSize:18.0f];
    _groupTitle.numberOfLines = 0 ;
    _groupTitle.textColor = RGBA(0, 0, 0, 1);
    _groupTitle.text = str;
    
 
    _line = [UIView new];
    _line.backgroundColor = RGBA(220, 220, 220, 1);
    
    _line1 = [UIView new];
    _line1.backgroundColor = RGBA(220, 220, 220, 1);
    
    _cancle = [UIButton new];
    _cancle.tag = 1;
    _cancle.backgroundColor = [UIColor clearColor];
    [_cancle setTitleColor:RGBA(73, 73, 73, 1) forState:UIControlStateNormal];
    [_cancle setTitle:@"取消" forState:UIControlStateNormal];
    _cancle.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [_cancle addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _submit = [UIButton new];
    _submit.tag = 2;
    _submit.backgroundColor = [UIColor clearColor];
    [_submit setTitleColor:RGBA(218, 37, 29, 1)  forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_submit setTitle:@"确定" forState:UIControlStateNormal];
    _submit.titleLabel.font = [UIFont systemFontOfSize:18.f];
    
    [self sd_addSubviews:@[_groupTitle,_line,_line1,_cancle,_submit]];
    
    
    _groupTitle.sd_layout
    .centerXEqualToView(self)
    .topSpaceToView(self, 28)
    .widthIs(146)
    .heightIs(45);
    
    _line.sd_layout
    .leftSpaceToView(self, 0)
    .topSpaceToView(_groupTitle, 24)
    .rightSpaceToView(self, 0)
    .heightIs(1);
    
    _line1.sd_layout
    .centerXEqualToView(self)
    .topSpaceToView(_line, 0)
    .widthIs(1)
    .bottomSpaceToView(self, 1);
    
    _cancle.sd_layout
    .leftSpaceToView(self, 1)
    .topSpaceToView(_line, 1)
    .rightSpaceToView(_line1, 1)
    .bottomSpaceToView(self, 1);
    
    _submit.sd_layout
    .leftSpaceToView(_line1, 1)
    .topSpaceToView(_line, 1)
    .rightSpaceToView(self, 1)
    .bottomSpaceToView(self, 1);
    
}

- (void)setUI{
    
    _groupTitle = [UILabel new];
    _groupTitle.textAlignment = NSTextAlignmentCenter;
    _groupTitle.font = [UIFont systemFontOfSize:20.0f];
    _groupTitle.textColor = UIColorFromRGB(0x404040);
    _groupTitle.text = @"新建分组";
    
    _groupName = [UITextField new];
    _groupName.textAlignment  = NSTextAlignmentLeft;
    _groupName.placeholder = @"请输入新分组名称";
    _groupName.font = [UIFont systemFontOfSize:18.0f];
    _groupName.layer.borderColor = [UIColor clearColor].CGColor;
    _groupName.layer.borderWidth = 1.0f;
    
    _line = [UIView new];
    _line.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    
    
    _cancle = [UIButton new];
    _cancle.tag = 1;
    _cancle.backgroundColor = [UIColor clearColor];
    [_cancle setTitleColor:UIColorFromRGB(0xff3800) forState:UIControlStateNormal];
    [_cancle setTitle:@"取消" forState:UIControlStateNormal];
    _cancle.titleLabel.font = [UIFont systemFontOfSize:20.f];
    [_cancle addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancle.layer.borderWidth = 1.0f;
    _cancle.layer.cornerRadius = 3.0f;
    _cancle.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
    
    _submit = [UIButton new];
    _submit.tag = 2;
    _submit.backgroundColor = UIColorFromRGB(0xff3800);
    [_submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_submit setTitle:@"提交" forState:UIControlStateNormal];
    _submit.titleLabel.font = [UIFont systemFontOfSize:20.f];
    _submit.layer.borderWidth = 1.0f;
    _submit.layer.cornerRadius = 3.0f;
    _submit.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
    
    [self sd_addSubviews:@[_groupTitle,_groupName,_line,_cancle,_submit]];
    
    
    _groupTitle.sd_layout
    .leftSpaceToView(self, 0)
    .topSpaceToView(self, 15)
    .rightSpaceToView(self, 0)
    .heightIs(30);
    
    _groupName.sd_layout
    .leftSpaceToView(self, 20)
    .topSpaceToView(_groupTitle, 20)
    .rightSpaceToView(self, 20)
    .heightIs(30);
    
    _line.sd_layout
    .leftSpaceToView(self, 20)
    .topSpaceToView(_groupName, 5)
    .rightSpaceToView(self, 20)
    .heightIs(1);
    
    _cancle.sd_layout
    .leftEqualToView(_line)
    .bottomSpaceToView(self, 30)
    .widthIs(120)
    .heightIs(45);
    
    _submit.sd_layout
    .rightEqualToView(_line)
    .bottomSpaceToView(self, 30)
    .widthIs(120)
    .heightIs(45);
    
}

- (void)btnClick:(UIButton *)btn{
    self.btnClick(btn);
}


@end
