//
//  ToConfirmedView.m
//  beaver
//
//  Created by mac on 17/10/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ToConfirmedView.h"

@interface ToConfirmedView ()

@property (nonatomic, strong)UILabel *status;       //状态
@property (nonatomic, strong)UILabel *checkName;    //审核人
@property (nonatomic, strong)UILabel *comfirmName;  //确认人

@property (nonatomic, strong)UILabel *store_achievement_type;    //门店业绩
@property (nonatomic, strong)UILabel *store_achievement_count;    //门店业绩数量

@property (nonatomic, strong)UILabel *divide_type; //预留后分成
@property (nonatomic, strong)UILabel *divide_count;//预留后数量

@property (nonatomic, weak)UIView *currentView;    //门店业绩数量

@property (nonatomic, strong)UILabel *xiaoType;    //小计
@property (nonatomic, strong)UILabel *xiaoCount;    //小计数量

@property (nonatomic, strong)UILabel *totleType;    //总计
@property (nonatomic, strong)UILabel *totelCount;    //总计数量

@property (nonatomic, weak)UIView *lastLineView;    //最后的view

@end

@implementation ToConfirmedView

-(instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)titleArr numArr:(NSArray *)numArr titleColor:(UIColor *)titleColor numColor:(UIColor *)numColor other:(NSDictionary *)dic{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI:titleArr numArr:numArr titleColor:titleColor numColor:numColor other:dic];
    }
    return self;
}
- (void)createUI:(NSArray *)titleArr numArr:(NSArray *)numArr titleColor:(UIColor *)titleColor numColor:(UIColor *)numColor other:(NSDictionary *)dic{
    
    
    UIFont *bigFont = [UIFont systemFontOfSize:13.f];
    UIFont *bold_bigFont = [UIFont boldSystemFontOfSize:13.f];
    UIFont *smallFont = [UIFont systemFontOfSize:12.f];
    UIFont *bold_smallFont = [UIFont boldSystemFontOfSize:12.f];
    
    UIColor *red = UIColorFromRGB(0xff3800);
    UIColor *black = UIColorFromRGB(0x404040);
    UIColor *gray = UIColorFromRGB(0x808080);
    UIColor *white = [UIColor whiteColor];
    //第一部分
    CGFloat view_w = 30;
    
    CGFloat padding_x = 15;
    CGFloat padding_y = 10;
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, view_w)];
    view1.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    [self addSubview:view1];

    _status = [[UILabel alloc]initWithFrame:CGRectMake(padding_x, (view_w-15)/2.f, 100, 15)];
    _status.text = dic[@"finance_status"];
    _status.textColor = white;
    _status.textAlignment = NSTextAlignmentLeft;
    _status.font = bold_bigFont;
    [view1 addSubview:_status];
    
    //修改这两个参数
    CGFloat spaing = 10;
    NSString *check_name =[NSString stringWithFormat:@"审核人 : %@",dic[@"verify_username"]];
    NSString *comfireName = [NSString stringWithFormat:@"确认人 : %@",dic[@"confirm_username"]];
    
    CGFloat w = [self sizeToWith:bigFont content:check_name];
    CGFloat comfireName_w = [self sizeToWith:bigFont content:comfireName];
    _checkName = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW - spaing - comfireName_w - w - 15, (view_w-15)/2.f, w, 15)];
    
    _checkName.textColor = white;
    _checkName.textAlignment = NSTextAlignmentRight;
    _checkName.font = bigFont;
    [view1 addSubview:_checkName];
    
    _comfirmName = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW-comfireName_w-15, (view_w-15)/2.f, comfireName_w, 15)];
    _comfirmName.text = comfireName;
    _comfirmName.textColor = white;
    _comfirmName.textAlignment = NSTextAlignmentRight;
    _comfirmName.font = bigFont;
    [view1 addSubview:_comfirmName];
    
    if ([dic[@"finance_status"] isEqualToString:@"已确认"]) {
        _checkName.text = check_name;
        _comfirmName.text = comfireName;
        view1.backgroundColor = UIColorFromRGB(0x8AA5FE);
    }else{
        _status.text = dic[@"finance_status"];
        _comfirmName.width = w;
        _comfirmName.text = check_name;
        _comfirmName.left =kScreenW-w-15;
        view1.backgroundColor = UIColorFromRGB(0xFDBD51);
    }

    
    if ([dic.allKeys containsObject:@"count"]) {
        _checkName.hidden = YES;
        _comfirmName.hidden = YES;
        _status.textColor = black;
        _status.text = [NSString stringWithFormat:@"门店数量 : %@",dic[@"count"]];
        view1.backgroundColor = [UIColor whiteColor];
    }
    
    
    //第三部门自适应
    CGFloat bg_x = 10;
    CGFloat bg_w = (kScreenW - 2*bg_x)/3.0f;
    CGFloat bg_h = 60;
//    CGFloat h = 35;
    //二手房业绩(自适应)
    NSDictionary *achievement = dic[@"achievement"];
   
    for (int i = 0; i < achievement.allKeys.count; i++) {
        NSString *key = achievement.allKeys[i];
        //背景视图
        UIView *bg_view = [[UIView alloc]initWithFrame:CGRectMake(padding_y + (i%3) * bg_w,CGRectGetMaxY(view1.frame)+padding_y +(i/3)*(1+bg_h), bg_w, bg_h)];
        bg_view.tag = i;
        bg_view.userInteractionEnabled = YES;
        _currentView = bg_view;
        
        //加个点击的手势
        if (![dic.allKeys containsObject:@"count"]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
            [bg_view addGestureRecognizer:tap];
        }
    
        //        bg_view.backgroundColor = [UIColor redColor];
        UILabel *numLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 11, bg_view.width, 15)];
        
        numLable.text = [NSString stringWithFormat:@"%.02f",[achievement[key] floatValue]];
        numLable.font = bold_smallFont;
        numLable.textColor = black;
        numLable.textAlignment = NSTextAlignmentCenter;
        [bg_view addSubview:numLable];
        
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(numLable.frame)+8, bg_view.width, 15)];
        titleLable.text = key;
        titleLable.tag = 1000;
        titleLable.font = smallFont;
        titleLable.textColor = gray;
        titleLable.textAlignment = NSTextAlignmentCenter;
        [bg_view addSubview:titleLable];
        //如果是中间的
        if ((i-1) % 3 == 0) {
            UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, padding_y, 1, 41)];
            leftView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
            [bg_view addSubview:leftView];
            UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(bg_view.width-1, padding_y, 1, 41)];
            rightView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
            [bg_view addSubview:rightView];
        }
        [self addSubview:bg_view];
    }
    //如果有一行只有一个的时候
    if (titleArr.count % 3 == 1) {
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(_currentView.width-1, padding_y, 1, 41)];
        rightView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
        [_currentView addSubview:rightView];
    }
    
    UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(padding_x, CGRectGetMaxY(_currentView.frame)+padding_y, kScreenW-2*padding_x, 1)];
    tmpView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    [self addSubview:tmpView];
    
    _lastLineView = tmpView;
    
    
    
    float small_count = 0;
    float totle_count = 0;
    
    for (NSNumber *number in achievement.allValues) {
        totle_count += [number floatValue];
    }
    
    //中间加个门店业绩统计
    UILabel *costTotle = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2.0, CGRectGetMaxY(_lastLineView.frame)+padding_y, kScreenW/2.0f-30, 15)];
    costTotle.text = [NSString stringWithFormat:@"门店业绩总计 : %@",[NSNumber numberWithFloat:totle_count]];
    costTotle.textAlignment = NSTextAlignmentRight;
    costTotle.textColor = black;
    costTotle.font = bold_bigFont;
    [self addSubview:costTotle];
    
    UIView *tmpView1 = [[UIView alloc]initWithFrame:CGRectMake(padding_x, CGRectGetMaxY(costTotle.frame)+padding_y, kScreenW-2*padding_x, 1)];
    tmpView1.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    [self addSubview:tmpView1];
    
    _lastLineView = tmpView1;
    
    
    NSDictionary *fee = dic[@"fee"];
    
    for (int i = 0; i < titleArr.count; i++) {
        
        UIView *bg_view = [[UIView alloc]initWithFrame:CGRectMake(padding_y + (i%3) * bg_w,CGRectGetMaxY(_lastLineView.frame)+padding_y +(i/3)*(1+bg_h), bg_w, bg_h)];
        bg_view.userInteractionEnabled = YES;
        
        _currentView = bg_view;
        //加个点击的手势
        if (![dic.allKeys containsObject:@"count"]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
            [bg_view addGestureRecognizer:tap];
        }
        
//        bg_view.backgroundColor = [UIColor redColor];
        UILabel *numLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 11, bg_view.width, 15)];
//        numLable.text = [NSString stringWithFormat:@"%@",numArr[i]];
        numLable.text = [NSString stringWithFormat:@"%@",fee[titleArr[i]]];
        numLable.font = bold_smallFont;
        numLable.textColor = black;
        numLable.textAlignment = NSTextAlignmentCenter;
        [bg_view addSubview:numLable];
        
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(numLable.frame)+8, bg_view.width, 15)];
        titleLable.tag = 1000;
//        titleLable.text = titleArr[i];
        titleLable.text = titleArr[i];
        titleLable.font = smallFont;
        titleLable.textColor = gray;
        titleLable.textAlignment = NSTextAlignmentCenter;
        [bg_view addSubview:titleLable];
        
        //如果是中间的
        if ((i-1) % 3 == 0) {
            UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, padding_y, 1, 41)];
            leftView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
            [bg_view addSubview:leftView];
            UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(bg_view.width-1, padding_y, 1, 41)];
            rightView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
            [bg_view addSubview:rightView];
        }
        
        [self addSubview:bg_view];
    }
    
    //如果有一行只有一个的时候
    if (titleArr.count % 3 == 1) {
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(_currentView.width-1, padding_y, 1, 41)];
        rightView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
        [_currentView addSubview:rightView];
    }
    
    //第三部分
    UIView *view3 = [[UIView alloc]initWithFrame:CGRectMake(padding_x, CGRectGetMaxY(_currentView.frame)+padding_y, kScreenW-2*padding_x, 1)];
    view3.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    [self addSubview:view3];
    
    _xiaoType = [[UILabel alloc]initWithFrame:CGRectMake(padding_x, CGRectGetMaxY(view3.frame)+padding_y, 100, 15)];
//    _xiaoType.text = @"小计";
    _xiaoType.textColor = gray;
    _xiaoType.textAlignment = NSTextAlignmentLeft;
    _xiaoType.font = bigFont;
    [self addSubview:_xiaoType];
    
    
    //小计
//    NSDictionary *fee = dic[@"fee"];
    
    for (NSNumber *number in fee.allValues) {
        small_count += [number floatValue];
    }
    _xiaoCount = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2.0f, CGRectGetMaxY(view3.frame)+padding_y, (kScreenW-30)/2.0f, 15)];
    _xiaoCount.text = [NSString stringWithFormat:@"门店费用统计 : %.02f",small_count];
    _xiaoCount.textColor = black;
    _xiaoCount.textAlignment = NSTextAlignmentRight;
    _xiaoCount.font = bold_bigFont;
    [self addSubview:_xiaoCount];
    
    UIView *view4 = [[UIView alloc]initWithFrame:CGRectMake(padding_x, CGRectGetMaxY(_xiaoType.frame)+padding_y, kScreenW-2*padding_x, 1)];
    view4.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.00];
    [self addSubview:view4];
    
   // 合计
    _totleType = [[UILabel alloc]initWithFrame:CGRectMake(padding_x, CGRectGetMaxY(view4.frame)+padding_y, 100, 15)];
//    _totleType.text = @"合计";
    _totleType.textColor = gray;
    _totleType.textAlignment = NSTextAlignmentLeft;
    _totleType.font = bigFont;
    [self addSubview:_totleType];
    
    
    _totelCount = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2.0f, CGRectGetMaxY(view4.frame)+padding_y, (kScreenW-30)/2.0f, 15)];
    _totelCount.text = [NSString stringWithFormat:@"合计 : %.02f",totle_count - small_count];
    _totelCount.textColor = black;
    _totelCount.textAlignment = NSTextAlignmentRight;
    _totelCount.font = bold_bigFont;
    [self addSubview:_totelCount];
    
    self.contentSize = CGSizeMake(kScreenW, CGRectGetMaxY(_totelCount.frame)+64+90);
    
}

- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}

- (CGFloat)sizeToHeight:(UIFont *)font content:(NSString *)content{
    CGFloat image_h = 100;
    CGFloat image_w = image_h*200/150;
    CGSize size = CGSizeMake(kScreenW-30-image_w,40);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    return actualsize.height;
}

- (void)viewClick:(UITapGestureRecognizer *)tap{
    
    if (self.confirmdDelegate && [self.confirmdDelegate respondsToSelector:@selector(viewDidClick:)]) {
        
        [self.confirmdDelegate viewDidClick:tap];
    }
}

@end
