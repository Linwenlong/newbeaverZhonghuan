//
//  MyJourneyViewController.m
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyJourneyViewController.h"
#import "MySeeHeaderView.h"
#import "ZFChart.h"
#import "HooDatePicker.h"


@interface MyJourneyViewController ()<ZFGenericChartDataSource, ZFBarChartDelegate,MySeeHeaderViewDelegate,HooDatePickerDelegate>

@property (nonatomic, strong) ZFBarChart * barChart;
@property (nonatomic, strong) NSMutableArray * myData;//我的数据
@property (nonatomic, strong) NSMutableArray * averageData;//平均数据
@property (nonatomic, strong) NSMutableArray * maxData;//最大数据
@property (nonatomic,strong) NSArray *titleArr;

@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)MySeeHeaderView *seeView;
@property (nonatomic, strong)NSString *currentDate;

@property (nonatomic, assign)CGFloat maxFloat;//最大的
@property (nonatomic, strong)NSMutableArray * maxFloatArr;//最大的

@end

#define MY_COLOR  [UIColor colorWithRed:0.00 green:0.61 blue:0.58 alpha:1.00]
#define AVERAGE_COLOR  [UIColor colorWithRed:1.00 green:0.27 blue:0.25 alpha:1.00]
#define MAX_COLOR  [UIColor colorWithRed:0.85 green:0.63 blue:0.00 alpha:1.00]

@implementation MyJourneyViewController


- (void)setUI{
    _seeView = [[MySeeHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 70)];
    _seeView.seeDelegate = self;
    NSArray *tmpArr1 = @[@"我的数据",@"平均值",@"最大值"];
    NSArray *tmpArr2 = @[MY_COLOR,AVERAGE_COLOR,MAX_COLOR];
    [self.view addSubview:_seeView];
    CGFloat h = 15;
    CGFloat spaing = 3;
    CGFloat w = 50;
    CGFloat y = 10;
    CGFloat right = 7;
    for (int i = 0; i < 3; i++) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW- right - w, CGRectGetMaxY(_seeView.frame)+y+(spaing + h)*i, w, h)];
        lable.text = tmpArr1[i];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.font = [UIFont systemFontOfSize:11.0f];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(kScreenW- right - w - h-spaing, CGRectGetMaxY(_seeView.frame)+y+(spaing + h)*i, h, h)];
        view.layer.cornerRadius = h/2.0f;
        view.clipsToBounds = YES;
        view.backgroundColor = tmpArr2[i];
        [self.view addSubview:lable];
        [self.view addSubview:view];
    
    }
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(_seeView.frame)+70, SCREEN_WIDTH-10, kScreenH - 64 - 40 - 50- 70)];
    backView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [self.view addSubview:backView];
    
    self.barChart = [[ZFBarChart alloc] initWithFrame:CGRectMake(5, 5, backView.width - 10,backView.height-10)];
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
    self.barChart.unit = @"个数";
    self.barChart.isShowYLineSeparate = YES;
    self.barChart.isShowXLineSeparate = YES;
    self.barChart.valueType = kValueTypeDecimal;
//    self.barChart.numberOfDecimal = 1;
//    [self.barChart strokePath];
    [backView addSubview:self.barChart];
}


- (void)requestData{
    
    _averageData = [NSMutableArray array];
    _myData = [NSMutableArray array];
    _maxData = [NSMutableArray array];
    _maxFloatArr = [NSMutableArray array];
    _titleArr = [NSMutableArray array];
    
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/trip/tripData?token=%@&month=%@",[EBPreferences sharedInstance].token,_currentDate]);
    NSString *urlStr =  @"trip/tripData";
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"month":_currentDate
       }success:^(id responseObject) {
           [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"] integerValue] == 0) {
               if (![currentDic[@"data"]isKindOfClass:[NSDictionary class]]) {
                   [EBAlert alertError:@"数据加载异常" length:2.0f];
                   return ;
               }
               NSDictionary *resultDic = currentDic[@"data"][@"company"]; //已经改动一次
               NSArray *keyArr = resultDic.allKeys;   //已经改动一次(获取所有的key)
               NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:keyArr];
               _titleArr = [[tmpArr reverseObjectEnumerator]allObjects];
               for (NSString *str in _titleArr) {
                   NSDictionary *dic = resultDic[str];
                    [_myData addObject:[NSString stringWithFormat:@"%.02f",[dic[@"num"] doubleValue]]];
                   [_maxData addObject:[NSString stringWithFormat:@"%@",dic[@"max_num"]]];
                   [_maxFloatArr addObject:dic[@"max_num"]];
                   _maxFloat = [[_maxFloatArr valueForKeyPath:@"@max.floatValue"] floatValue];
                   //后期得配置
                   [_averageData addObject:[NSString stringWithFormat:@"%@",dic[@"average_num"]]];
               }
           }
           [self.barChart strokePath];
          
           } failure:^(NSError *error) {
                 [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
           }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的行程";
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:currentDate];
    _currentDate = currentOlderOneDateStr;
    
    [self requestData];
    [self setUI];
}

#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return @[_myData,_averageData,_maxData];
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return _titleArr;
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    NSArray *tmpArr2 = @[MY_COLOR,AVERAGE_COLOR,MAX_COLOR];
    return tmpArr2;
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    
    if (_maxFloat==0) {
        return 10;
    }else{
        return _maxFloat;
    }
}



- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    return 10;
}

#pragma mark - ZFBarChartDelegate

- (id)valueTextColorArrayInBarChart:(ZFBarChart *)barChart{
    return UIColorFromRGB(0xff3800);
}

- (void)barChart:(ZFBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex bar:(ZFBar *)bar popoverLabel:(ZFPopoverLabel *)popoverLabel{

    NSLog(@"第%ld个颜色中的第%ld个",(long)groupIndex,(long)barIndex);

}

- (void)barChart:(ZFBarChart *)barChart didSelectPopoverLabelAtGroupIndex:(NSInteger)groupIndex labelIndex:(NSInteger)labelIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    //理由同上
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)labelIndex);
   
}

- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    return _datePicker;
}

#pragma mark -- SeeHeaderViewViewDelegate

- (void)selectedMonth:(UITapGestureRecognizer *)tap{

    [self.datePicker show];
    
}

#pragma mark -- HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date{
    
}
- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender{
    NSLog(@"取消");
    
}
- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    
    if ([date compare:[NSDate date]] < 0) {
        _currentDate = currentOlderOneDateStr;
    }else{
        [EBAlert alertError:@"请选择小于本月的月份" length:2.0 ];
        return;
    }
    
    //获取当前的日期比较，如果是相当就本月
    NSDate *currentDate = [NSDate date];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    
    if ([currentOlderOneDateStr isEqualToString:currentDateStr]) {
        NSLog(@"本月");
        _seeView.month.text = @"本月";
    }else{
        _seeView.month.text = _currentDate;
    }
    _datePicker.date = date;
    //在这里需要刷新数据
    [self requestData];
}

@end
