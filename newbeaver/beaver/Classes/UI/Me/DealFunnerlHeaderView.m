//
//  DealFunnerlHeaderView.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "DealFunnerlHeaderView.h"
#import "SDAutoLayout.h"

@interface DealFunnerlHeaderView ()

@property (nonatomic, strong)UIImageView *pullDownImage1;//下拉图片
@property (nonatomic, strong)UIImageView *pullDownImage2;//下拉图片



@property (nonatomic, strong)UIView *line1;

@property (nonatomic, strong)UIView *line2;

@end

@implementation DealFunnerlHeaderView

- (void)selectedChange:(UITapGestureRecognizer *)tap{
    if (self.headerViewDelegate && [self.headerViewDelegate respondsToSelector:@selector(selected:)]) {
        [self.headerViewDelegate selected:tap.view.tag];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _pullDownImage1 = [UIImageView new];
    _pullDownImage1.image = [UIImage imageNamed:@"pullDown"];
    [self addSubview:_pullDownImage1];
    
    _pullDownImage2 = [UIImageView new];
    _pullDownImage2.image = [UIImage imageNamed:@"pullDown"];
    [self addSubview:_pullDownImage2];
    
    UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
    UIColor *textColor1 = UIColorFromRGB(0x404040);
    
    _deparment = [UILabel new];
    _deparment.textColor = textColor1;
    _deparment.text = @"部门";
    _deparment.font  = font;
    _deparment.tag = 1;
    _deparment.userInteractionEnabled = YES;
    _deparment.textAlignment = NSTextAlignmentCenter;
     [self addSubview:_deparment];
    _month = [UILabel new];
    _month.textColor = textColor1;
    _month.text = @"本月";
    _month.font  = font;
     _month.tag = 2;
    _month.userInteractionEnabled = YES;
    _month.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_month];
    
    //手势
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector( selectedChange:)];
    [_deparment addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector( selectedChange:)];
    [_month addGestureRecognizer:tap2];
    
    _line1 = [UIView new];
    _line1.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    [self addSubview:_line1];
    
    _line2 = [UIView new];
    _line2.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
     [self addSubview:_line2];
    
    //设置约束
    _deparment.sd_layout
    .topSpaceToView(self,0)
    .leftSpaceToView(self,0)
    .widthIs(kScreenW/2)
    .heightIs(self.height);
    
    _month.sd_layout
    .topSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .widthIs(kScreenW/2)
    .heightIs(self.height);
    
    _line1.sd_layout
    .topSpaceToView(self,0)
    .leftSpaceToView(self,kScreenW/2)
    .widthIs(1)
    .heightIs(self.height);
    
    _line2.sd_layout
    .topSpaceToView(self,self.height-1)
    .leftSpaceToView(self,0)
    .widthIs(kScreenW)
    .heightIs(1);
    
    CGFloat scale = 1.5;
    CGFloat y = 15;

    _pullDownImage1.sd_layout
    .topSpaceToView(self,y+9)
    .rightSpaceToView(_line1,10)
    .widthIs(12/scale)
    .heightIs(14/scale);
    
    _pullDownImage2.sd_layout
    .topSpaceToView(self,y+7)
    .rightSpaceToView(self,10)
    .widthIs(12/scale)
    .heightIs(14/scale);
}

@end
