//
//  PerformanceRankingView.m
//  beaver
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PerformanceRankingView.h"
#import "PerformanceTableViewCell.h"
#import "SDAutoLayout.h"

@interface PerformanceRankingView ()

@property (nonatomic, strong)UIView *firstBackGround;//第一个背景图

@property (nonatomic, strong)UIImageView *pullDownImage;//下拉图片

@property (nonatomic, strong)UIView *line1;

@property (nonatomic, strong)UILabel *myRanking;//我的排名

@property (nonatomic, strong)UIView *line2;

@end

@implementation PerformanceRankingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
   
        [self setUI];
        
    }
    return self;
}

- (void)selected:(UITapGestureRecognizer *)tap{
    if (self.rankingDelegate && [self.rankingDelegate respondsToSelector:@selector(selectedMonth:)]) {
        [self.rankingDelegate selectedMonth:tap];
    }
}

- (void)setUI{
    _firstBackGround = [UIView new];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selected:)];
    _firstBackGround.userInteractionEnabled = YES;
    [_firstBackGround addGestureRecognizer:tap];
    [self addSubview:_firstBackGround];
    
    UIColor *grayColor1 =[UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1.0f ];
    UIColor *redColor1 =[UIColor colorWithRed:255/255.0f green:55/255.0f blue:0/255.0f alpha:1.0f ];
    UIColor *greenColor1=[UIColor colorWithRed:96/255.0f green:190/255.0f blue:224/255.0f alpha:1.0f ];
    
    UIFont *bigFont = [UIFont systemFontOfSize:15.0f];
        //第一行
    _month = [UILabel new];
    _month.font = bigFont;
    _month.textColor = grayColor1;
    _month.text = @"本月";
    _month.textAlignment = NSTextAlignmentLeft;
    
    [_firstBackGround addSubview:_month];
    _pullDownImage = [UIImageView new];
    _pullDownImage.image = [UIImage imageNamed:@"pullDown"];

    [_firstBackGround addSubview:_pullDownImage];

    _line1 = [UIView new];
     _line1.backgroundColor = UIColorFromRGB(0xf5f5f5);
    //排名
    _myRanking  = [UILabel new];
    _myRanking.text = @"我的排名";
    _myRanking.font = bigFont;
    _myRanking.textColor = grayColor1;
    _myRanking.textAlignment = NSTextAlignmentLeft;
    
    _Ranking = [UILabel new];
    _Ranking.text = @"排名";
    _Ranking.font = [UIFont boldSystemFontOfSize:15.0f];
    _Ranking.textColor = redColor1;
    _Ranking.textAlignment = NSTextAlignmentLeft;
    
    _myRankingNumber = [UILabel new];//_myRankingNumber我的单数
    _myRankingNumber.text = @"";
    _myRankingNumber.font = [UIFont boldSystemFontOfSize:15.0f];
    _myRankingNumber.textColor = greenColor1;
    _myRankingNumber.textAlignment = NSTextAlignmentRight;
    
    _line2 = [UIView new];
     _line2.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self sd_addSubviews:@[_line1,_myRanking,_Ranking,_myRankingNumber,_line2]];
    
    //sd
    _firstBackGround.sd_layout
    .topEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .heightIs(self.height/2);
    
    CGFloat x = 15;
    CGFloat y = 15;

    //第一行
    _month.sd_layout
    .topSpaceToView(_firstBackGround,y)
    .leftSpaceToView(_firstBackGround,x)
    .widthIs(kScreenW/2)
    .heightIs(60 - 2*y);
    
    CGFloat scale = 1.5;
    _pullDownImage.sd_layout
    .topSpaceToView(_firstBackGround,y+7)
    .rightSpaceToView(_firstBackGround,x)
    .widthIs(12/scale)
    .heightIs(14/scale);
    
    _line1.sd_layout
    .bottomEqualToView(_firstBackGround)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .heightIs(1);
    
     //第二行
    _myRanking.sd_layout
    .topSpaceToView(_line1,y)
    .leftSpaceToView(self,x)
    .widthIs(80)
    .heightIs(_month.height);
    
    _Ranking.sd_layout
    .topSpaceToView(_line1,y)
    .leftSpaceToView(_myRanking,x*2)
    .widthIs(80)
    .heightIs(_month.height);
    
    _myRankingNumber.sd_layout
    .topSpaceToView(_line1,y)
    .rightSpaceToView(self,x)
    .widthIs(100)
    .heightIs(_month.height);
    
    _line2.sd_layout
    .bottomEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .heightIs(1);
    
}

@end
