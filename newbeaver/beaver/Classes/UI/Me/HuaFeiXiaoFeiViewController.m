//
//  HuaFeiXiaoFeiViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HuaFeiXiaoFeiViewController.h"
#import "HuaFeiXiaoFeiTableViewCell.h"
#import "MySeeHeaderView.h"
#import "HooDatePicker.h"

@interface HuaFeiXiaoFeiViewController ()<UITableViewDelegate,UITableViewDataSource,MySeeHeaderViewDelegate,HooDatePickerDelegate>
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

@property (nonatomic, assign) NSString * totlePrice;//总金额

@end

@implementation HuaFeiXiaoFeiViewController

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
        _defaultView.placeText.text = @"暂未获取到消费记录";
    }
    return _defaultView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = @"话费消费记录";
    //初始化数据(先初始化日期数据)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
    //    _tableView.backgroundColor = UIColorFromRGB(0xff3800);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    _tableView.separatorColor = UIColorFromRGB(0xe8e8e8);
    _seeView = [[MySeeHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 70)];
    _seeView.seeDelegate = self;
    _tableView.tableHeaderView = _seeView;
    
    [self.view addSubview:_tableView];
    
    [self refreshHeader];
    [self footerLoading];
    
    [_tableView registerClass:[HuaFeiXiaoFeiTableViewCell class] forCellReuseIdentifier:@"cell"];
    

}


- (void)requestData:(int)pageindex{
    
    
    NSString *urlStr = @"call/currentCallList";
    
    NSLog(@"urlData = %@",[NSString stringWithFormat:@"%@/call/currentCallList?token=%@&page=%@&page_size=%@&date=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,[NSNumber numberWithInt:pageindex],[NSNumber numberWithInt:12],_currentDate]);
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    __weak typeof(self) weakSelf = self;
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],
       @"date":_currentDate
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           
           if ( loadingHeader ==  YES) {
               [weakSelf.dataArray removeAllObjects];
               
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           NSArray *tmpArray = currentDic[@"data"][@"data"];//公告列表
           _totlePrice = currentDic[@"data"][@"statistic"][@"amount"];

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
    return 100.0f;
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HuaFeiXiaoFeiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
   
    NSDictionary *dic = _dataArray[indexPath.row];
    
    [cell setDic:dic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 48)];
    view.backgroundColor = [UIColor whiteColor];
//    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
//    line1.backgroundColor = UIColorFromRGB(0x333333);
//    [view addSubview:line1];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, kScreenW/2, 21)];
    lable.text = @"消费总金额:";
    lable.textAlignment = NSTextAlignmentLeft;
    lable.font = [UIFont systemFontOfSize:18.0f];
    [view addSubview:lable];
    
    UILabel *rightLable = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2, 13, kScreenW/2-15, 21)];
    NSString *origionStr =[NSString stringWithFormat:@"%@元",_totlePrice];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:origionStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(0, _totlePrice.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(_totlePrice.length,origionStr.length - _totlePrice.length)];
    rightLable.attributedText = attributeStr;
    rightLable.textAlignment = NSTextAlignmentRight;
    rightLable.font = [UIFont systemFontOfSize:18.0f];
    [view addSubview:rightLable];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kScreenW, 1)];
    line.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [view addSubview:line];
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
