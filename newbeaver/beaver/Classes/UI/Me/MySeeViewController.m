//
//  MySeeViewController.m
//  beaver
//
//  Created by mac on 17/8/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySeeViewController.h"

#import "MySeeTableViewCell.h"
#import "MySeeHeaderView.h"
#import "HooDatePicker.h"
#import "MySeeDetailViewController.h"

@interface MySeeViewController ()<UITableViewDelegate,UITableViewDataSource,MySeeHeaderViewDelegate,HooDatePickerDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)MySeeHeaderView *seeView;
@property (nonatomic, strong)NSString *currentDate;

@end


@implementation MySeeViewController


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-70)];
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
      self.title = @"我的带看";
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
    
    //初始化数据(先初始化日期数据)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [self requestData];
    [_mainTableView registerNib:[UINib nibWithNibName:@"MySeeTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)requestData{

    //成交漏斗
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Visit/visitHouse?token=%@&month=%@",[EBPreferences sharedInstance].token,_currentDate]);
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    NSString *urlStr = @"Visit/visitHouse";
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"month":_currentDate
       }success:^(id responseObject) {
           //是否启用占位图
           _mainTableView.enablePlaceHolderView = YES;
           DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
           defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
           defaultView.placeText.text = @"暂无带看数据";
           [_dataArray removeAllObjects];
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
   
           if ([currentDic[@"code"] integerValue] == 0) {
               NSDictionary *tmpDic = currentDic[@"data"][@"data"];
               NSMutableDictionary *houseDic = [NSMutableDictionary dictionary];
               NSMutableDictionary *clientDic = [NSMutableDictionary dictionary];
               if([tmpDic[@"house"] isKindOfClass:[NSDictionary class]]&& [tmpDic[@"client"] isKindOfClass:[NSDictionary class]]){
                   [houseDic addEntriesFromDictionary:tmpDic[@"house"]];
                   [clientDic addEntriesFromDictionary:tmpDic[@"client"]];
               }else{
                    [houseDic setObject:@0 forKey:@"house_sort"];
                    [houseDic setObject:@0 forKey:@"house_num"];
                    [clientDic setObject:@0 forKey:@"client_sort"];
                    [clientDic setObject:@0 forKey:@"client_num"];
               }
               NSDictionary *breakData = tmpDic[@"breakData"];
               if (breakData != nil) {
                   if ([breakData[@"house_avgnum"] isEqual:[NSNull null]]) {
                       [houseDic setObject:@0 forKey:@"average"];
                   }else{
                       [houseDic setObject:breakData[@"house_avgnum"] forKey:@"average"];
                   }
                   if ([breakData[@"house_max"] isEqual:[NSNull null]]) {
                        [houseDic setObject:@0 forKey:@"max"];
                   }else{
                       [houseDic setObject:breakData[@"house_max"] forKey:@"max"];
                   }
                   if ([breakData[@"client_avgnum"] isEqual:[NSNull null]]) {
                        [clientDic setObject:@0 forKey:@"average"];
                   }else{
                        [clientDic setObject:breakData[@"client_avgnum"] forKey:@"average"];
                   }
                   if ([breakData[@"max_client"] isEqual:[NSNull null]]) {
                      [clientDic setObject:@0 forKey:@"max"];
                   }else{
                      [clientDic setObject:breakData[@"max_client"] forKey:@"max"];
                   }
               }
               [_dataArray addObject:houseDic];
               [_dataArray addObject:clientDic];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MySeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        [cell setModel:_dataArray[indexPath.row] withType:@"带看房"];
    }else{
        [cell setModel:_dataArray[indexPath.row] withType:@"带看客"];
    }
 
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MySeeDetailViewController  *msdvc = [[MySeeDetailViewController alloc]init];
    msdvc.hidesBottomBarWhenPushed = YES;
    msdvc.currentDate = _currentDate;
    //点击了某个
    if (indexPath.row == 0) {
        NSLog(@"点击了带看房");
        msdvc.type = @"house";
        msdvc.title = @"带看房";
    }else{
        NSLog(@"点击了带看客");
         msdvc.type = @"client";
        msdvc.title = @"带看客";
    }
    [self.navigationController pushViewController:msdvc animated:YES];
}

#pragma mark -- SeeHeaderViewViewDelegate

- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    return _datePicker;
}


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
    
    if ([date compare:[NSDate date]] < 0) {
        _currentDate = currentOlderOneDateStr;
    }else{
        [EBAlert alertError:@"请选择小于本月的月份" length:2.0 ];
        return;
    }
    _currentDate = currentOlderOneDateStr;
    
    //获取当前的日期比较，如果是相当就本月
    NSDate *currentDate = [NSDate date];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    
    if ([currentOlderOneDateStr isEqualToString:currentDateStr]) {
        NSLog(@"本月");
        _seeView.month.text = @"本月";
    }else{
        _seeView.month.text = _currentDate;
    }
    //在这里需要刷新数据
    _datePicker.date = date;
    [self requestData];
}


@end

