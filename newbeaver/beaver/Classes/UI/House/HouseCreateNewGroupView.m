//
//  HouseCreateNewGroupView.m
//  dev-beaver
//
//  Created by 林文龙 on 2018/11/26.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseCreateNewGroupView.h"

@interface HouseCreateNewGroupView ()


@property (nonatomic, strong) UILabel * groupTitle;
@property (nonatomic, strong) UITextField * groupName;

@property (nonatomic, strong) UIView * line;

@property (nonatomic, strong) UIButton * cancle;
@property (nonatomic, strong) UIButton * submit;

@end

@implementation HouseCreateNewGroupView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
       
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)str placeholder:(NSString *)placeholder{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        
        [self setUI:str placeholder:placeholder];
    }
    return self;
}

- (void)setUI:(NSString *)str placeholder:(NSString *)placeholder{
    _groupTitle = [UILabel new];
    _groupTitle.textAlignment = NSTextAlignmentCenter;
    _groupTitle.font = [UIFont systemFontOfSize:20.0f];
    _groupTitle.textColor = UIColorFromRGB(0x404040);
    _groupTitle.text = str;
    
    _groupName = [UITextField new];
    _groupName.textAlignment  = NSTextAlignmentLeft;
    _groupName.text = placeholder;
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
    self.btnClick(btn,_groupName);
}

@end
