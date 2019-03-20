//
//  LWLNewsView.m
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "LWLNewsView.h"
#import "SDAutoLayout.h"

@interface LWLNewsView ()

@property (nonatomic, strong)UIImageView *backGroundView;
@property (nonatomic, strong)UIImageView *textTitleView;
@property (nonatomic, strong)UIImageView *countView;
@property (nonatomic, strong)UIImageView *tipView;
@property (nonatomic, strong)UIView *coverView;

@property (nonatomic, strong)UIView *lineView1;
@property (nonatomic, strong)UIView *lineView2;

@end

@implementation LWLNewsView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)imageClick:(UIImageView *)imageView{
    if (self.lwlShowViewDelegate && [self.lwlShowViewDelegate respondsToSelector:@selector(LWLNewsViewImageClick:)]) {
        [self.lwlShowViewDelegate LWLNewsViewImageClick:imageView];
    }
}

//ui

- (void)setUI{
    
    _lineView1 = [UIView new];
    _lineView1.backgroundColor = UIColorFromRGB(0xe8e8e8);
  
    [self addSubview:_lineView1];
    
    _backGroundView = [UIImageView new];
    _backGroundView.image = [UIImage imageNamed:@"通知栏"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
    [_backGroundView addGestureRecognizer:tap];
    _backGroundView.userInteractionEnabled = YES;
     [self addSubview:_backGroundView];
    
    _textTitleView = [UIImageView new];
    _textTitleView.image = [UIImage imageNamed:@"通知公告"];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
    [_textTitleView addGestureRecognizer:tap1];
    _textTitleView.userInteractionEnabled = YES;
    [_backGroundView addSubview:_textTitleView];
    
    _countView = [UIImageView new];
    _countView.image = [UIImage imageNamed:@"count"];
     [_backGroundView addSubview:_countView];
    
    _countLable = [UILabel new];
    _countLable.text = @"99⁺";
    _countLable.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:16.0f];
    _countLable.textColor = UIColorFromRGB(0xff3800);
    _countLable.textAlignment = NSTextAlignmentCenter;
    [_countView addSubview:_countLable];
    
    _tipView = [UIImageView new];
    _tipView.image = [UIImage imageNamed:@"箭头"];

     [_backGroundView addSubview:_tipView];
    _coverView = [UIView new];
    [self addSubview:_coverView];
    _mainTableView = [UITableView new];
    [_coverView addSubview:_mainTableView];
    
    _lineView2 = [UIView new];
    _lineView2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    [self addSubview:_lineView2];
    
    CGFloat y = 25;
    CGFloat x=5;
    
    _lineView1.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .topSpaceToView(self,0)
    .heightIs(1);
    
    _backGroundView.sd_layout
    .topSpaceToView(self,y)
    .leftSpaceToView(self,x)
    .rightSpaceToView(self,x)
    .heightIs(60);
   
    CGFloat textY  = 12;
    CGFloat W = 198*30/52;
    CGFloat textX = ((kScreenW-2*x)-W)/2.0-15;
    
    _textTitleView.sd_layout
    .topSpaceToView(_backGroundView,textY)
    .leftSpaceToView(_backGroundView,textX)
    .heightIs(30)
    .widthIs(W);
    
    //56*65
    CGFloat count_h = 65/1.5;
    CGFloat count_y = (_backGroundView.height - count_h)/2.0-2;
    CGFloat count_w = 56/1.5;
    _countView.sd_layout
    .topSpaceToView(_backGroundView,count_y)
    .leftSpaceToView(_textTitleView,10)
    .heightIs(count_h)
    .widthIs(count_w);
    
    CGFloat ratio = 1.0;
    CGFloat centerpadding = 5;
    _countLable.sd_layout
    .centerXIs(_countView.centerX+1 )
    .centerYIs(_countView.centerY-centerpadding)
    .widthRatioToView(_countView,ratio)
    .heightRatioToView(_countView,ratio);
    
    _tipView.sd_layout
    .rightSpaceToView(_backGroundView,30)
    .topSpaceToView(_backGroundView,17)
    .widthIs(17/2)
    .heightIs(33/2);
    
    CGFloat tableViewX = 15;
    
    _coverView.sd_layout
    .leftSpaceToView(self,tableViewX)
    .rightSpaceToView(self,tableViewX)
    .topSpaceToView(_backGroundView,-25)
    .heightIs(self.height - _backGroundView.height - 2*y+25);
    
    _mainTableView.sd_layout
    .leftSpaceToView(_coverView,0)
    .rightSpaceToView(_coverView,0)
    .topSpaceToView(_coverView,0)
    .bottomSpaceToView(_coverView,0);
    
    [self bringSubviewToFront:_backGroundView];
    
    _coverView.layer.shadowColor = UIColorFromRGB(0xffa18d).CGColor;
    _coverView.layer.shadowOffset = CGSizeMake(2, 2);
    _coverView.layer.shadowOpacity = 0.7f;
    //设置阴影
    _mainTableView.separatorColor = UIColorFromRGB(0xffe1d9);
    _mainTableView.backgroundColor = [UIColor clearColor];
    
//    _mainTableView.layer.shadowColor = UIColorFromRGB(0xffa18d).CGColor;
//    _mainTableView.layer.shadowOffset = CGSizeMake(1, 1);
//    _mainTableView.layer.shadowOpacity = 0.7f;
//    _mainTableView.clipsToBounds = NO;
//    _mainTableView.layer.masksToBounds = NO;
    
    _mainTableView.layer.borderColor =UIColorFromRGB(0xffa18d).CGColor;
    _mainTableView.layer.borderWidth = 1.0f;
     _mainTableView.layer.cornerRadius = 10.0f;
    [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    
    //tableView加头部视图
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _mainTableView.width, 25)];
    headerView.backgroundColor = [UIColor whiteColor];
    _mainTableView.tableHeaderView = headerView;
    
    _lineView2.sd_layout
    .leftSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .bottomSpaceToView(self,0)
    .heightIs(1);

}


@end
