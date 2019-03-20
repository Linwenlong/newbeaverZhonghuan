//
//  MyReconnoitreViewController.m
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyReconnoitreViewController.h"
#import "MySeeDetailModel.h"

//共用的
#import "MySeeTableViewCell.h"
#import "MySeeHeaderView.h"
#import "HooDatePicker.h"
#import "MyReconoitreTableViewCell.h"

@interface MyReconnoitreViewController ()<UITableViewDelegate,UITableViewDataSource,MySeeHeaderViewDelegate,HooDatePickerDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)NSMutableArray *surveydataArray;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)MySeeHeaderView *seeView;
@property (nonatomic, strong)NSString *currentDate;

@end


@implementation MyReconnoitreViewController


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-60)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        _seeView = [[MySeeHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 70)];
        _seeView.seeDelegate = self;
        _mainTableView.tableHeaderView = _seeView;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的实勘";
    _dataArray = [NSMutableArray array];
    _surveydataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
    
    //初始化数据(先初始化日期数据)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
     [self requestData];
    
    [_mainTableView registerNib:[UINib nibWithNibName:@"MySeeTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [_mainTableView registerNib:[UINib nibWithNibName:@"MyReconoitreTableViewCell" bundle:nil] forCellReuseIdentifier:@"reconoitreCell"];
}

- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Visit/surveyHouse?token=%@&month=%@",[EBPreferences sharedInstance].token,_currentDate]);
    NSString *urlStr = @"Visit/surveyHouse";
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"month":_currentDate
       }success:^(id responseObject) {
           //是否启用占位图
           _mainTableView.enablePlaceHolderView = YES;
           DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
           defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
           defaultView.placeText.text = @"暂无数据";
           [_surveydataArray removeAllObjects];
           [_dataArray removeAllObjects];
           [EBAlert hideLoading];
           NSDictionary *resultDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *currentDic = resultDic[@"data"];
           if ([resultDic[@"code"] integerValue] == 0) {
               if (currentDic[@"surveydata"] != nil && currentDic[@"breakData"] != nil &&![currentDic[@"surveydata"] isKindOfClass:[NSArray class]]&&![currentDic[@"surveydata"] isKindOfClass:[NSArray class]]) {
                   NSMutableDictionary *surveydata = [NSMutableDictionary dictionaryWithDictionary:currentDic[@"surveydata"]];
                   NSDictionary *breakData = currentDic[@"breakData"];
                   if ([breakData[@"avg_surveynum"] isEqual:[NSNull null]]) {
                       [surveydata setObject:@0 forKey:@"average"];
                   }else{
                       [surveydata setObject:breakData[@"avg_surveynum"] forKey:@"average"];
                   }
                   if ([breakData[@"max_survey"] isEqual:[NSNull null]]) {
                      [surveydata setObject:@0 forKey:@"max"];
                   }else{
                       [surveydata setObject:breakData[@"max_survey"] forKey:@"max"];
                   }

                   [_surveydataArray addObject:surveydata];
               }else{
//                   [EBAlert alertError:@"暂无数据" length:2.0f];
               }
               _dataArray = currentDic[@"vistHouse"];
//               for (NSDictionary *dic in currentDic[@"vistHouse"]) {
//                   MySeeDetailModel *model = [[MySeeDetailModel alloc]initWithDict:dic];
//                   [_dataArray addObject:model];
//               }
               [self.mainTableView reloadData];
           }else{
               [EBAlert alertError:@"请求失败" length:2.0f];
           }
       } failure:^(NSError *error) {
           if (_dataArray.count == 0) {
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
               defaultView.placeText.text = @"数据获取失败";
               [self.mainTableView reloadData];
           }
           [EBAlert hideLoading];
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}



#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 ) {
        return _surveydataArray.count;
    }else{
        return _dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MySeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        [cell setModel:_surveydataArray[indexPath.row] withType:@"我的实勘"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }else{
        MyReconoitreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reconoitreCell" forIndexPath:indexPath];
        [cell setModel:indexPath.row withDarrCount:_dataArray.count withDic:_dataArray[indexPath.row]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
          return 300;
    }else{
        return 80;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
         return 20;
    }else{
        return 0;
    }
   
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 20)];
        view.backgroundColor = [UIColor whiteColor];
        return view;
//    }else{
//        return nil;
//    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
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
    NSLog(@"选择了日期");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    _currentDate = currentOlderOneDateStr;
    
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
