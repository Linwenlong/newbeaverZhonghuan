//
//  ChongZhiViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/8/1.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "ChongZhiViewController.h"
#import "ChongZhiTableViewCell.h"
#import "MySeeHeaderView.h"
#import "HooDatePicker.h"

@interface ChongZhiViewController ()<UITableViewDelegate,UITableViewDataSource,HooDatePickerDelegate,MySeeHeaderViewDelegate>
{
    int page;
    BOOL loadingHeader;
    UITableView *_tableView;
}

@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;

@property (nonatomic, strong)MySeeHeaderView *seeView;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)NSString *currentDate;

@end

@implementation ChongZhiViewController

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
    
    [self refreshHeader];
}


- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = _tableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];
        _defaultView.placeText.text = @"暂未获取到充值记录";
    }
    return _defaultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = @"充值记录";
    //初始化数据(先初始化日期数据)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)style:UITableViewStylePlain];
    //    _tableView.backgroundColor = UIColorFromRGB(0xff3800);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    _seeView = [[MySeeHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 70)];
    _seeView.seeDelegate = self;
    _tableView.tableHeaderView = _seeView;
    _tableView.separatorColor = UIColorFromRGB(0xe8e8e8);

    
    [self.view addSubview:_tableView];
    
    [self refreshHeader];
    [self footerLoading];
    
    [_tableView registerClass:[ChongZhiTableViewCell class] forCellReuseIdentifier:@"cell"];

}

- (void)requestData:(int)pageindex{
    
    
    NSString *urlStr = @"call/payList";
    
    NSLog(@"urlData = %@",[NSString stringWithFormat:@"%@/call/payList?token=%@&page=%@&page_size=%@&caller=%@&date=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,[NSNumber numberWithInt:pageindex],[NSNumber numberWithInt:12],_bind_phone,_currentDate]);
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    __weak typeof(self) weakSelf = self;
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],
       @"caller":_bind_phone,
       @"date":_currentDate
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           
           if ( loadingHeader ==  YES) {
               [weakSelf.dataArray removeAllObjects];
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           NSArray *tmpArray = currentDic[@"data"][@"data"];//公告列表
           
           if ([currentDic[@"code"] integerValue] == 0) {
               for (NSDictionary *dic in tmpArray) {
                   [_dataArray addObject:dic];
               }
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           if (_dataArray.count == 0) {//如果没有数据
               [_tableView addSubview:self.defaultView];
           }else{
               if (weakSelf.defaultView) {
                   [weakSelf.defaultView  removeFromSuperview];
               }
           }
           
           [_tableView.mj_header endRefreshing];
           
           if (tmpArray.count == 0) {
               [_tableView.mj_footer endRefreshingWithNoMoreData];
               [_tableView reloadData];
               return ;
           }else{
               [_tableView.mj_footer endRefreshing];
           }
           [_tableView reloadData];
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [_tableView.mj_footer endRefreshing];
           [_tableView.mj_header endRefreshing];
       }];
    
}


-(void)footerLoading{
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:page];
    }];
}
//刷新头部、、MJ
-(void)refreshHeader{
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:page];//加载数据
    }];
    [_tableView.mj_header beginRefreshing];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChongZhiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = _dataArray[indexPath.row];
    
    [cell setDic:dic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
