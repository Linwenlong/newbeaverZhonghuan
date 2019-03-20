//
//  MySeeHeaderView.m
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySeeHeaderView.h"
#import "SDAutoLayout.h"

@interface MySeeHeaderView ()

@property (nonatomic, strong)UIView *firstBackGround;//第一个背景图

@property (nonatomic, strong)UIImageView *pullDownImage;//下拉图片

@property (nonatomic, strong)UIView *line1;

@end

@implementation MySeeHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUI];
        
    }
    return self;
}


- (void)setUI{
    _firstBackGround = [UIView new];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selected:)];
    _firstBackGround.userInteractionEnabled = YES;
    [_firstBackGround addGestureRecognizer:tap];
    _firstBackGround.backgroundColor = [UIColor whiteColor];
    [self addSubview:_firstBackGround];
    
    UIFont *bigFont = [UIFont boldSystemFontOfSize:18.0f];
    //第一行
    _month = [UILabel new];
    _month.font = bigFont;
    _month.textColor = UIColorFromRGB(0x2e2e2e);
    _month.text = @"本月";
    _month.textAlignment = NSTextAlignmentLeft;
    
    [_firstBackGround addSubview:_month];
    _pullDownImage = [UIImageView new];
    _pullDownImage.image = [UIImage imageNamed:@"pullDown"];
    [_firstBackGround addSubview:_pullDownImage];
    
    
    _line1 = [UIView new];
    _line1.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    //排名
    
   
    [self sd_addSubviews:@[_line1]];
    
    //sd
    _firstBackGround.sd_layout
    .topEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .heightIs(self.height);
    
    CGFloat x = 15;
    CGFloat y = 15;
    
    //第一行
    _month.sd_layout
    .topSpaceToView(_firstBackGround,y)
    .leftSpaceToView(_firstBackGround,x)
    .widthIs(kScreenW/2)
    .heightIs(self.height-10 - 2*y);
    
    CGFloat scale = 1.5;
    _pullDownImage.sd_layout
    .topSpaceToView(_firstBackGround,y+12)
    .rightSpaceToView(_firstBackGround,x)
    .widthIs(12/scale)
    .heightIs(14/scale);
    
    _line1.sd_layout
    .bottomEqualToView(_firstBackGround)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .heightIs(10);
    
}

- (void)selected:(UITapGestureRecognizer *)tap{
    if (self.seeDelegate && [self.seeDelegate respondsToSelector:@selector(selectedMonth:)]) {
        [self.seeDelegate selectedMonth:tap];
    }
}

@end
