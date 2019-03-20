//
//  MyAchievementView.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyAchievementView.h"
#import "ZFChart.h"

@interface MyAchievementView ()<ZFGenericChartDataSource, ZFLineChartDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) ZFLineChart * lineChart1;
@property (nonatomic, strong) ZFLineChart * lineChart2;
@property (nonatomic, strong) ZFLineChart * lineChart3;

@property (nonatomic, strong) UILabel *deal_count;//成交数量
@property (nonatomic, strong) UILabel *deal_Lable;//成交文字
@property (nonatomic, strong) UILabel *deal_index;//成交上升下降百分比
@property (nonatomic, strong) UIPageControl *pageControl;//成交上升下降百分比
@property (nonatomic, strong) UIScrollView *mainScrollView;//成交上升下降百分比

@property (nonatomic, strong)NSArray   *sevenDate;
@property (nonatomic, strong)NSArray   *fifteenDate;
@property (nonatomic, strong)NSArray   *thirtyDate;

@property (nonatomic, strong)NSArray   *sevenNum;
@property (nonatomic, strong)NSArray   *fifteenNum;
@property (nonatomic, strong)NSArray   *thirtyNum;

@property (nonatomic, strong)NSString   *sevendealnum;
@property (nonatomic, strong)NSString   *fifteendealnum;
@property (nonatomic, strong)NSString   *thirtydealnum;

@end

@implementation MyAchievementView

- (instancetype)initWithFrame:(CGRect)frame sevenDate:(NSMutableArray *)sevenDate fifteenDate:(NSMutableArray *)fifteenDate thirtyDate:(NSMutableArray *)thirtyDate sevenNum:(NSMutableArray *)sevenNum fifteenNum:(NSMutableArray *)fifteenNum thirtyNum:(NSMutableArray *)thirtyNum sevendealnum:(NSString *)sevendealnum fifteendealnum:(NSString *)fifteendealnum thirtydealnum:(NSString *)thirtydealnum{
    
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {

        _sevenDate = sevenDate;
        _fifteenDate = fifteenDate;
        _thirtyDate = thirtyDate;
        
        _sevenNum = sevenNum;
        _fifteenNum = fifteenNum;
        _thirtyNum = thirtyNum;
        
        _sevendealnum = sevendealnum;
        _fifteendealnum = fifteendealnum;
        _thirtydealnum = thirtydealnum;
        
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI];
    }
    return self;
}
- (void)setUI{
    _deal_count = [UILabel new];
    _deal_count.text  = _sevendealnum;
    _deal_count.textAlignment = NSTextAlignmentCenter;
    _deal_count.font = [UIFont boldSystemFontOfSize:15.0f];
    
    _deal_Lable = [UILabel new];
    _deal_Lable.text  = @"近七日成交";
    _deal_Lable.font = [UIFont systemFontOfSize:14.0f];
    _deal_Lable.textColor = [UIColor blackColor];
    _deal_Lable.textAlignment = NSTextAlignmentCenter;
    
    _deal_index = [UILabel new];
    _deal_index.hidden  = YES;
    _deal_index.text  = @"0.5%";
    _deal_index.textColor = [UIColor colorWithRed:0.40 green:0.39 blue:0.41 alpha:1.00];
    _deal_index.font = [UIFont systemFontOfSize:13.0f];
    _deal_index.textAlignment = NSTextAlignmentCenter;
    
    _pageControl = [UIPageControl new];
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    
    _mainScrollView = [UIScrollView new];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.contentSize = CGSizeMake(kScreenW*3, 0);
    
    [self sd_addSubviews:@[_deal_count,_deal_Lable,_deal_index,_pageControl,_mainScrollView]];
    
    CGFloat y = 50;
    CGFloat w = 100;
    
    _deal_count.sd_layout
    .topSpaceToView(self,y)
    .centerXEqualToView(self)
    .widthIs(w)
    .heightIs(30);
    
    _deal_Lable.sd_layout
    .topSpaceToView(_deal_count,0)
    .centerXEqualToView(self)
    .widthIs(w)
    .heightIs(20);
    
    _deal_index.sd_layout
    .topSpaceToView(self,y+5)
    .leftSpaceToView(_deal_count,5)
    .widthIs(30)
    .heightIs(20);
    
    _pageControl.sd_layout
    .topSpaceToView(_deal_Lable,-2)
    .centerXEqualToView(self)
    .widthIs(100)
    .heightIs(20);
    
    _mainScrollView.sd_layout
    .leftSpaceToView(self,0)
    .topSpaceToView(self,95)
    .widthIs(kScreenW)
    .heightIs(250);
    
    for (int i = 0; i < 3; i++) {
        
        ZFLineChart *lineChart = [[ZFLineChart alloc]initWithFrame:CGRectMake(10+kScreenW*i, 0, kScreenW-40, 250)];
        if (i == 0) {
            self.lineChart1 = lineChart;
        }else  if (i == 1) {
            self.lineChart2 = lineChart;
        }  if (i == 2) {
            self.lineChart3 = lineChart;
        }
        lineChart.dataSource = self;
        lineChart.delegate = self;
        lineChart.unit = @"数量";
        lineChart.topicLabel.textColor = ZFWhite;
        lineChart.isShowXLineSeparate = YES;
        lineChart.isShowYLineSeparate = YES;
        lineChart.isResetAxisLineMinValue = YES;
        lineChart.isShadow = NO;
        lineChart.unitColor = ZFBlack;
        lineChart.xAxisColor = ZFBlack;
        lineChart.yAxisColor = ZFBlack;
        lineChart.axisLineNameColor = ZFBlack;
        lineChart.axisLineValueColor = ZFBlack;
        lineChart.xLineNameLabelToXAxisLinePadding = 10;
        [_mainScrollView addSubview:lineChart];
        [lineChart strokePath];
        
    }
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    [self addSubview:view];
    view.sd_layout
    .bottomEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .heightIs(1);
    
    [self bringSubviewToFront:_deal_Lable];
    [self bringSubviewToFront:_deal_count];
    [self bringSubviewToFront:_deal_index];
    [self bringSubviewToFront:_pageControl];

}

#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    if (chart == _lineChart1) {
        return _sevenNum;
    }else if (chart == _lineChart2){
        return _fifteenNum;
    }else{
        return _thirtyNum;
    }
    
    
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    if (chart == _lineChart1) {
        return _sevenDate;
    }else if (chart == _lineChart2){
        return _fifteenDate;
    }else{
        return _thirtyDate;
    }
    
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[UIColorFromRGB(0xff3800)];
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    if (chart == _lineChart1) {
        return 7;
    }else if (chart == _lineChart2){
        return 15;
    }else{
        return 30;
    }
}



- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    return 7;
}

- (void)lineChart:(ZFLineChart *)lineChart didSelectCircleAtLineIndex:(NSInteger)lineIndex circleIndex:(NSInteger)circleIndex circle:(ZFCircle *)circle popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld条线========第%ld个",(long)lineIndex,(long)circleIndex);
    
    //可在此处进行circle被点击后的自身部分属性设置,可修改的属性查看ZFCircle.h
    //    circle.circleColor = ZFYellow;
    circle.isAnimated = YES;
    //    circle.opacity = 0.5;
    
    [circle strokePath];
    [lineChart strokePath];
    
    //    可将isShowAxisLineValue设置为NO，然后执行下句代码进行点击才显示数值
    //    popoverLabel.hidden = NO;
}

- (NSArray *)valuePositionInLineChart:(ZFLineChart *)lineChart{
    return  @[@(kChartValuePositionOnTop)];
}

- (void)lineChart:(ZFLineChart *)lineChart didSelectPopoverLabelAtLineIndex:(NSInteger)lineIndex circleIndex:(NSInteger)circleIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld条线========第%ld个",(long)lineIndex,(long)circleIndex);
    
    //可在此处进行popoverLabel被点击后的自身部分属性设置
    //    popoverLabel.textColor = ZFGold;
    //    [popoverLabel strokePath];
}

#pragma mark -- UIScrollDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //点击对应的按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    _pageControl.currentPage = index;
    if (index == 0 ) {
        _deal_count.text  = _sevendealnum;
        _deal_Lable.text  = @"近七日成交";

    }else if (index == 1){
        _deal_count.text  = _fifteendealnum;
        _deal_Lable.text  = @"近十五日成交";
    }else{
        _deal_count.text  = _thirtydealnum;
        _deal_Lable.text  = @"近三十日成交";
    }
   
  
}

@end
