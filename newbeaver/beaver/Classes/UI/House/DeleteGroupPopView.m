//
//  DeleteGroupPopView.m
//  dev-beaver
//
//  Created by 林文龙 on 2018/12/5.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "DeleteGroupPopView.h"

@interface DeleteGroupPopView()

@property (nonatomic, strong) UILabel * groupTitle;
@property (nonatomic, strong) UILabel * groupSubTitle;

@property (nonatomic, strong) UILabel * groupName;

@property (nonatomic, strong) UIView * line;

@property (nonatomic, strong) UIButton * cancle;
@property (nonatomic, strong) UIButton * submit;

@end

@implementation DeleteGroupPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
        self.layer.cornerRadius = 3.0f;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setUI{
    
    _groupTitle = [UILabel new];
    _groupTitle.textAlignment = NSTextAlignmentCenter;
    _groupTitle.font = [UIFont systemFontOfSize:22.0f];
    _groupTitle.textColor = UIColorFromRGB(0x404040);
    _groupTitle.text = @"提示";
    
    _groupSubTitle = [UILabel new];
    _groupSubTitle.textAlignment = NSTextAlignmentCenter;
    _groupSubTitle.font = [UIFont boldSystemFontOfSize:20.0f];
    _groupSubTitle.textColor = UIColorFromRGB(0xff3800);
    _groupSubTitle.text = @"你确定要删除该分组吗?";
    
    _groupName = [UILabel new];
    _groupName.textAlignment  = NSTextAlignmentCenter;
    _groupName.numberOfLines = 0;
    _groupName.text = @"(选定分组一旦被删除，组内房源将会一并删除，您可先将房源移至其他分组。)";
    _groupName.textColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00];
    _groupName.font = [UIFont systemFontOfSize:15.0f];
    
    _line = [UIView new];
    _line.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    
    
    _cancle = [UIButton new];
    _cancle.tag = 1;
    _cancle.backgroundColor = UIColorFromRGB(0xff3800);
    [_cancle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancle setTitle:@"取消" forState:UIControlStateNormal];
    _cancle.titleLabel.font = [UIFont systemFontOfSize:20.f];
    [_cancle addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancle.layer.borderWidth = 1.0f;
    _cancle.layer.cornerRadius = 3.0f;
    _cancle.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
    
    _submit = [UIButton new];
    _submit.tag = 2;
    _submit.backgroundColor = [UIColor clearColor];
    [_submit setTitleColor:UIColorFromRGB(0xff3800) forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_submit setTitle:@"确定" forState:UIControlStateNormal];
    _submit.titleLabel.font = [UIFont systemFontOfSize:20.f];
    _submit.layer.borderWidth = 1.0f;
    _submit.layer.cornerRadius = 3.0f;
    _submit.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
    
    [self sd_addSubviews:@[_groupTitle,_groupSubTitle,_groupName,_line,_cancle,_submit]];
    
    _groupTitle.sd_layout
    .leftSpaceToView(self, 0)
    .topSpaceToView(self, 15)
    .rightSpaceToView(self, 0)
    .heightIs(30);
    
    _groupSubTitle.sd_layout
    .leftSpaceToView(self, 0)
    .topSpaceToView(_groupTitle, 10)
    .rightSpaceToView(self, 0)
    .heightIs(30);
    
    _groupName.sd_layout
    .leftSpaceToView(self, 20)
    .topSpaceToView(_groupSubTitle, 10)
    .rightSpaceToView(self, 20)
    .heightIs(40);
    
    _line.sd_layout
    .leftSpaceToView(self, 20)
    .topSpaceToView(_groupName, 15)
    .rightSpaceToView(self, 20)
    .heightIs(1);
    
    _cancle.sd_layout
    .leftEqualToView(_line)
    .bottomSpaceToView(self, 25)
    .widthIs(120)
    .heightIs(45);
    
    _submit.sd_layout
    .rightEqualToView(_line)
    .bottomSpaceToView(self, 25)
    .widthIs(120)
    .heightIs(45);
}

- (void)btnClick:(UIButton *)btn{
    self.btnClick(btn);
}

@end
