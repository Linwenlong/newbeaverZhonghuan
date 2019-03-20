//
//  PerformanceRankingViewController.m
//  beaver
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PerformanceRankingViewController.h"
#import "PerformanceRankingView.h"
#import "PerformanceTableViewCell.h"
#import "HooDatePicker/HooDatePicker.h"
#import "PerformanceRankingModel.h"

#import "MJRefresh.h"
#import "EBAlert.h"
#import "HttpTool.h"
#import "EBPreferences.h"

@interface PerformanceRankingViewController ()<UITableViewDelegate,UITableViewDataSource,PerformanceRankingViewDelegate,HooDatePickerDelegate>
{
    int page;
    BOOL loadingHeader;
}
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)UIView *backGroundView;
@property (nonatomic, strong)NSString *currentDate;

@property (nonatomic, strong)PerformanceRankingView *rankingView;

@end

@implementation PerformanceRankingViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _rankingView = [[PerformanceRankingView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 120)];
        _rankingView.rankingDelegate = self;
        _mainTableView.tableHeaderView = _rankingView;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"业绩排行";
    _dataArray = [NSMutableArray array];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:currentDate];
    _currentDate = currentOlderOneDateStr;
    
    [self.view addSubview:self.mainTableView];
    
    [self refreshHeader];
    [self footerLoading];

    [_mainTableView registerNib:[UINib nibWithNibName:@"PerformanceTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self beaverStatistics:@"CheckRankList"];
}

-(void)footerLoading{
    self.mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:page];
    }];
}
//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:page];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark -- RequestData
- (void)requestData:(int)pageindex{
    [self.view endEditing:YES];
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Index/getAllRank?token=%@&page=%d&page_size=20&date=%@",[EBPreferences sharedInstance].token,pageindex,_currentDate]);
    NSString *urlStr = @"Index/getAllRank";
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],
       @"date":_currentDate
       }success:^(id responseObject) {
            [EBAlert hideLoading];
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
               defaultView.placeText.text = @"暂无详情数据";
               if (  loadingHeader ==  YES) {
                   [self.dataArray removeAllObjects];
               }
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               NSDictionary *dic = currentDic[@"data"];
               
               //本身销售的名次
               NSArray *dealMySelf = dic[@"myself"];
               NSString *mySelfCount = nil;
               NSString *mySelfRank = nil;
               if (dealMySelf.count == 0) {
                   mySelfCount = @"0";
                   mySelfRank = @"暂无排名";
               }else{
                   NSDictionary *dic = dealMySelf.firstObject;
                   mySelfCount = [NSString stringWithFormat:@"%@",dic[@"deal_count"]];
                   mySelfRank = [NSString stringWithFormat:@"%@",dic[@"count"]];
                }
                _rankingView.myRankingNumber.text = mySelfCount;
                _rankingView.Ranking.text = mySelfRank;
                NSArray *tmpArray = dic[@"alldeal"];//公告列表
//            for (int i = 0; i<tmpArray.count; i++) {
//                NSDictionary *dic = tmpArray[i];
//                if(i == 0){
//                    PerformanceRankingModel *model = [[PerformanceRankingModel alloc]initWithDict:dic];
//                    [_dataArray addObject:model];
//                }
//               
//            }
               for (NSDictionary *dic in tmpArray) {
                   PerformanceRankingModel *model = [[PerformanceRankingModel alloc]initWithDict:dic];
                   [_dataArray addObject:model];
               }
               [self.mainTableView.mj_header endRefreshing];
               if (tmpArray.count == 0) {
                   [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
                   [self.mainTableView reloadData];
                   return ;
               }else{
                   [self.mainTableView.mj_footer endRefreshing];
               }
               [self.mainTableView reloadData];
               
           } failure:^(NSError *error) {
                [EBAlert hideLoading];
               if (_dataArray.count == 0) {
                   //是否启用占位图
                   _mainTableView.enablePlaceHolderView = YES;
                   DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
                   defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
                   defaultView.placeText.text = @"数据获取失败";
                   [self.mainTableView reloadData];
               }
               [EBAlert alertError:@"请检查网络" length:2.0f];
               [self.mainTableView.mj_header endRefreshing];
               [self.mainTableView.mj_footer endRefreshing];
           }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //只有一个的时候就一段
    return 2;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_dataArray.count>0) {
        if (section == 0) {
            return 1;
        }else{
            return _dataArray.count - 1;
        }
    }else{
        return _dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PerformanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        PerformanceRankingModel *model = _dataArray.firstObject;
        model = _dataArray.firstObject;
        [cell setHidden:YES model:model num:1];
    }else{
        PerformanceRankingModel *model = _dataArray[indexPath.row+1];
        model = _dataArray[indexPath.row+1];
        [cell setHidden:NO model:model num:indexPath.row+2];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 10)];
    
    view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
    line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [view addSubview:line1];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 9, kScreenW, 1)];
    line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [view addSubview:line2];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 0;
    }
}

- (UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _backGroundView.backgroundColor = [UIColor blackColor];
        _backGroundView.alpha = 0.5;
    }
    return _backGroundView;
}

- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    return _datePicker;
}

#pragma mark -- PerformanceRankingViewDelegate

- (void)selectedMonth:(UITapGestureRecognizer *)tap{

    [self.datePicker show];

}

#pragma mark -- HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date{
  
}
- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender{
    //销毁背景图
    [self.backGroundView removeFromSuperview];
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
  
    //获取当前的日期比较，如果是相当就本月
    NSDate *currentDate = [NSDate date];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
 
    if ([currentOlderOneDateStr isEqualToString:currentDateStr]) {
        NSLog(@"本月");
        _rankingView.month.text = @"本月";
    }else{
        _rankingView.month.text = _currentDate;
    }
    _datePicker.date = date;
    //在这里需要刷新数据
    [self refreshHeader];
}

@end
