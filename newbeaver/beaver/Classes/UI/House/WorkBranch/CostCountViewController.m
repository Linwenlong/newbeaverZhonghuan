//
//  CostCountViewController.m
//  beaver
//
//  Created by mac on 17/10/8.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CostCountViewController.h"
#import "HeaderViewForDailCheckView.h"
#import "HooDatePicker/HooDatePicker.h"

#import "UIView+MJExtension.h"

#import "CostCountDetailViewController.h"

#import "MJRefresh.h"
#import "CKSlideMenu.h"

@interface CostCountViewController ()<HeaderViewForDailCheckViewDelegate,HooDatePickerDelegate,CKSlideMenuDelegate>

@property (nonatomic, strong)NSString *currentDate;
@property (nonatomic, strong)NSDate *Date;
@property (nonatomic, strong)HeaderViewForDailCheckView *headerLable;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)ValuePickerView *pickerView;
@property (nonatomic, strong)DefaultView *defaultView;
@property (nonatomic, weak) UIButton *dateBtn;
@property (nonatomic, weak) UIButton *typeBtn;
@property (nonatomic, copy) NSString *type; //统计类型
@property (nonatomic, copy) NSString *subtype;//子类型

//上半月还是下半月
@property (nonatomic, copy)NSString *upOrDown;
@property (nonatomic, strong)NSArray *titleArr;

@property (nonatomic, strong) NSString *statistics;//统计类型

@property (nonatomic, strong) NSMutableArray * costTotleTypes;


@end

@implementation CostCountViewController

#pragma mark -- CKSlideMenuDelegate

-(void)changeTitle:(NSInteger)index{
    self.title = self.titleArr[index];
}

#pragma mark -- HeaderViewForDailCheckViewDelegate
//月结，半月结，还是日结
- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 0) {
        self.pickerView.dataSource = self.costTotleTypes;
        self.pickerView.pickerTitle = @"请选择统计决策";
        __weak typeof(self) weakSelf = self;
        self.pickerView.valueDidSelect = ^(NSString *str){
            NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
            [btn setTitle:result forState:UIControlStateNormal];
            
            if ([result isEqualToString:@"月结统计"]) {
                weakSelf.costCountType = ZHCostCountTypeMonth;
                weakSelf.datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
            }else if ([result isEqualToString:@"半月结"]){
                weakSelf.costCountType = ZHCostCountTypeHalfMonth;
                weakSelf.datePicker.datePickerMode = HooDatePickerModeUpAndDown;
            }else if ([result isEqualToString:@"单日结"]){
                weakSelf.costCountType = ZHCostCountTypeDay;
                weakSelf.datePicker.datePickerMode = HooDatePickerModeDate;
            }else if ([result isEqualToString:@"十日结佣"]){
                weakSelf.costCountType = ZHCostCountTypeTen;
                weakSelf.datePicker.datePickerMode = HooDatePickerModeTen;
            }
            [weakSelf initData];
            [weakSelf requestData];
        };
        [self.pickerView show];
    }else if (btn.tag == 1) {
        _dateBtn = btn;
         [self.datePicker show];
    }else if (btn.tag == 2){
        self.pickerView.dataSource = self.totletype;
        self.pickerView.pickerTitle = @"请选择统计类型";
        __weak typeof(self) weakSelf = self;
        self.pickerView.valueDidSelect = ^(NSString *str){
            NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
    
            [btn setTitle:result forState:UIControlStateNormal];
            _type = result;
            //重新刷新数据
            [weakSelf requestData];
        };
        [self.pickerView show];
    }
}


#pragma mark -- HooDatePickerDelegate

- (void)datePicker:(HooDatePicker *)dataPicker didSelectedMonth:(NSString *)str andUpOrDown:(NSString *)type{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM"];//设定时间格式,这里可以设置成自己需要的格式
    NSDate *date =[dateFormat dateFromString:str];
    if ([date compare:[NSDate date]] < 0) {
        _currentDate = [dateFormat stringFromDate:date];
    }else{
        [EBAlert alertError:@"请选择小于当前日期的天数" length:2.0 ];
        return;
    }
    [_dateBtn setTitle:[NSString stringWithFormat:@"%@-%@",[dateFormat stringFromDate:date],type] forState:UIControlStateNormal];
    _subtype = type;
    _datePicker.date = date;
    [self requestData];
}

- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date{
    
}

- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender{
    NSLog(@"取消");
}

- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date{
    NSLog(@"选择了日期");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (_costCountType == ZHCostCountTypeMonth) {
        [dateFormatter setDateFormat:@"yyyy-MM"];
    }else if (_costCountType == ZHCostCountTypeDay){
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    if ([date compare:[NSDate date]] < 0) {
        _currentDate = currentOlderOneDateStr;
    }else{
        [EBAlert alertError:@"请选择小于当前日期的天数" length:2.0 ];
        return;
    }
    [_dateBtn setTitle:_currentDate forState:UIControlStateNormal];
    _Date = date;
    _datePicker.date = date;
    [self requestData];
}

- (NSDate *)getEailer:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:-1];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    return newdate;
}


- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view withIsShowClearBtn:NO];
        _datePicker.delegate = self;
        _datePicker.date = [self getEailer:[NSDate date]];
        //月结
        if (_costCountType == ZHCostCountTypeMonth) {
             _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
        }else if (_costCountType == ZHCostCountTypeDay){
            _datePicker.datePickerMode = HooDatePickerModeDate;
        }else if (_costCountType == ZHCostCountTypeHalfMonth){
            _datePicker.datePickerMode = HooDatePickerModeUpAndDown;
        }else if (_costCountType == ZHCostCountTypeTen){
            _datePicker.datePickerMode = HooDatePickerModeTen;
        }
    }
    return _datePicker;
}

- (void)initData{
    if (self.totletype.count > 0) {
        _type = self.totletype.firstObject;
    }else{
        _type = @"";
    }
    if (self.costCountType == ZHCostCountTypeHalfMonth) {
        _subtype = @"上半月";
    }else if(self.costCountType == ZHCostCountTypeTen){
        _subtype = @"月上旬";
    }else{
        _subtype = @"";
    }
//     _statistics = @"";
    
    NSDate *currentDate = [self getEailer:[NSDate date]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (_costCountType == ZHCostCountTypeMonth || _costCountType == ZHCostCountTypeHalfMonth ||_costCountType == ZHCostCountTypeTen) {
        [dateFormatter setDateFormat:@"yyyy-MM"];
    }else if (_costCountType == ZHCostCountTypeDay){
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:currentDate];
    
    _currentDate = currentOlderOneDateStr;
    
    _Date = [NSDate date];
    NSString *secondStr = @"";
    if (self.totletype.count == 0) {
        secondStr = @"暂无";
    }else{
        secondStr = self.totletype.firstObject;
    }
    
    if (_headerLable == nil) {
        _headerLable = [[HeaderViewForDailCheckView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40) titleArr:@[_financeDec,_currentDate,secondStr] isShowBottomView:NO];
        _headerLable.headerViewDelegate = self;
    }else{
        NSString *tmpStr = nil;
        if (self.costCountType == ZHCostCountTypeHalfMonth || self.costCountType == ZHCostCountTypeTen) {
            NSArray *arr = [_currentDate componentsSeparatedByString:@"-"];
            if (arr.count >= 2) {
                tmpStr = [NSString stringWithFormat:@"%@-%@-%@",arr[0],arr[1],_subtype];
            }else{
                tmpStr = _currentDate;
            }
        }else{
            tmpStr = _currentDate;
        }
        [_headerLable.dateBtn setTitle:tmpStr forState:UIControlStateNormal];
        
    }
    [self.view addSubview:_headerLable];
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
   
    _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    _defaultView.center = self.view.center;
    _defaultView.centerY -= 60;
    _defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
    _defaultView.placeText.text = @"数据获取失败";
    _defaultView.hidden = YES;
    [self.view addSubview:_defaultView];
    
    _costTotleTypes = [NSMutableArray array];
    
    _monthfinance == 0 ? 1 : [_costTotleTypes addObject:@"月结统计"];
    _halfmonthfinance == 0 ? 1 : [_costTotleTypes addObject:@"半月结"];
    _dayfinance == 0 ? 1 : [_costTotleTypes addObject:@"单日结"];
    _tenfinance == 0 ? 1 : [_costTotleTypes addObject:@"十日结佣"];
    
    [self initData];
    
     self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    [self requestData];
}

- (void)addViewControllers:(NSArray *)data{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSMutableArray *titlrArr = [NSMutableArray array];
    NSMutableDictionary *totleAchievement = [NSMutableDictionary dictionary];
    NSMutableDictionary *totleFee = [NSMutableDictionary dictionary];
    
    
    [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        if (![dic[@"achievement"] isKindOfClass:[NSDictionary class]]||![dic[@"fee"] isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        NSDictionary *achievement = dic[@"achievement"];
        NSDictionary *fee = dic[@"fee"];
       
        //遍历字典（门店业绩）
        [achievement enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //如果存在key
            if ([totleAchievement.allKeys containsObject:key]){
                float num = [totleAchievement[key] floatValue];
                num += [obj floatValue];
                [totleAchievement setObject:[NSNumber numberWithFloat:num] forKey:key];
            }else{
            //不存在key的时候(保存key)
                [totleAchievement setObject:obj forKey:key];
            }
        }];
        //遍历字典（门店费用）
        [fee enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //如果存在key
            if ([totleFee.allKeys containsObject:key]) {
                float num = [totleFee[key] floatValue];
                num += [obj floatValue];
                [totleFee setObject:[NSNumber numberWithFloat:num] forKey:key];
            }else{
                //不存在key的时候(保存key)
                [totleFee setObject:obj forKey:key];
            }
        }];
    }];
    
    //添加总计
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:totleAchievement forKey:@"achievement"];
    [dic setObject:totleFee forKey:@"fee"];

    [dic setObject:[NSNumber numberWithInteger:data.count] forKey:@"count"];
    [titlrArr addObject:@"总计"];
    

    NSDictionary *feeDickeys = (NSDictionary *)data.firstObject;
    NSDictionary *fee = feeDickeys[@"fee"];
    CostCountDetailViewController *cost = [[CostCountDetailViewController alloc]init];
    cost.dic = dic;
    cost.type = _type;
    cost.feedickeys = fee.allKeys;
    cost.month = _currentDate;
    [arr addObject:cost];
    
    for (NSDictionary *dic in data) {
        if (![dic[@"achievement"] isKindOfClass:[NSDictionary class]]||![dic[@"fee"] isKindOfClass:[NSDictionary class]]) {
            continue ;
        }
        [titlrArr addObject:dic[@"department"]];
        CostCountDetailViewController *cost = [[CostCountDetailViewController alloc]init];
         __weak typeof(self) weakSelf = self;
        //回调
        cost.textBlock = ^(){
            [weakSelf requestData];//重新刷新房源
        };
        cost.dic = dic;
        cost.feedickeys = fee.allKeys;
        cost.type = _type;
        cost.month = _currentDate;
        
        cost.month_half = self.subtype;
        cost.statistics = self.statistics;
        
        [arr addObject:cost];
    }
    //生成一个数据
    self.titleArr = titlrArr;
    
    CKSlideMenu *slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerLable.frame), self.view.frame.size.width, 40) titles:titlrArr controllers:arr];
    slideMenu.bodyFrame = CGRectMake(0,  CGRectGetMaxY(slideMenu.frame), self.view.frame.size.width, self.view.frame.size.height- CGRectGetMaxY(slideMenu.frame));
    slideMenu.ckslideMenuDelegate = self;
    slideMenu.bodySuperView = self.view;
    slideMenu.indicatorOffsety = 2;
    slideMenu.indicatorWidth = 25;
    slideMenu.font = [UIFont systemFontOfSize:16.0f];
    slideMenu.indicatorStyle = SlideMenuIndicatorStyleStretch;
    if (data.count < 4) {
        slideMenu.isFixed = YES;
    }else{
        slideMenu.isFixed = NO;
    }
    slideMenu.titleStyle = SlideMenuTitleStyleGradient;
    slideMenu.selectedColor = [UIColor orangeColor];
    slideMenu.unselectedColor = [UIColor grayColor];
    [self.view addSubview:slideMenu];
    _datePicker = nil;
}

- (void)requestData{
    NSDictionary *parm = nil;
    NSNumber *num = nil;
    if (_costCountType == ZHCostCountTypeMonth || _costCountType == ZHCostCountTypeDay) {//月和日
        
        if (_costCountType == ZHCostCountTypeMonth) {
            _statistics = @"月结统计";
            num = @14;
        }else{
            _statistics = @"单日统计";
            num = @817;
        }
        parm = @{
                @"token" : [EBPreferences sharedInstance].token,
                @"type" :  _type,
                @"month" : _currentDate,
                @"statistics" : _statistics,
//                @"department_id":num
        };
        NSLog(@"httpurl = %@",[NSString stringWithFormat:@"%@/finance/financeData?token=%@&type=%@&month=%@&statistics=%@&department_id=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_type,_currentDate,_statistics,num]);
    }else if (_costCountType == ZHCostCountTypeHalfMonth||_costCountType == ZHCostCountTypeTen){//半月
        if (_costCountType == ZHCostCountTypeHalfMonth) {
            _statistics = @"半月统计";
            num = @812;
        }else{
            _statistics = @"十日统计";
            num = @55;
        }
        parm = @{
                 @"token" : [EBPreferences sharedInstance].token,
                 @"type" :  _type,
                 @"month" : _currentDate,
                 @"statistics" : _statistics,
                 @"month_half": _subtype,
//                 @"department_id":num
        };
        NSLog(@"httpurl = %@",[NSString stringWithFormat:@"%@/finance/financeData?token=%@&type=%@&month=%@&statistics=%@&month_half=%@&department_id=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_type,_currentDate,_statistics,_subtype,num]);
    }
    NSString *urlStr = @"finance/financeData";
    NSLog(@"parm = %@",parm);
    
//    NSString *urlStr = [NSString stringWithFormat:@"%@/finance/financeData",NewHttpBaseUrl];
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:parm
              success:^(id responseObject) {
        //添加费用统计
//    ![dic[@"achievement"] isKindOfClass:[NSDictionary class]]||![dic[@"fee"] isKindOfClass:[NSDictionary class]]
                  
        [EBAlert hideLoading];
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dic = currentDic[@"data"];
        NSArray *data = dic[@"data"];
        for (UIView *view in self.view.subviews) {
            if (!([view isKindOfClass:[HeaderViewForDailCheckView class]]||[view isKindOfClass:[DefaultView class]])) {
                    [view removeFromSuperview];
            }
        }
        NSDictionary *tmpDic = data.firstObject;//第一个数据
        if (data.count == 0 || ![tmpDic[@"achievement"] isKindOfClass:[NSDictionary class]]||![tmpDic[@"fee"] isKindOfClass:[NSDictionary class]]) {
            _defaultView.hidden = NO;
            _defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
            _defaultView.placeText.text = @"暂无详情数据";
            self.title = @"费用统计";
            _datePicker = nil;
            return ;
        }
        self.title = @"总计";
        [self addViewControllers:data];
        
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        self.title = @"费用统计";
        _defaultView.hidden = NO;
        _defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
        _defaultView.placeText.text = @"数据获取失败";
        [EBAlert alertError:@"请检查网络" length:2.0f];
    }];
}



@end
