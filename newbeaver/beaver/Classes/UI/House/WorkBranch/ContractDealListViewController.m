//
//  ContractDealListViewController.m
//  beaver
//
//  Created by mac on 17/12/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractDealListViewController.h"

#import "ContractDealTableViewCell.h"

#import "ContactRentTableViewCell.h"

#import "ContractDealDetailViewController.h"
#import "ContractRentDetailViewController.h"

#import "HttpTool.h"
#import "MJRefresh.h"
#import "HooDatePicker.h"

#import "HeaderViewForDailCheckView.h"

@interface ContractDealListViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,HeaderViewForDailCheckViewDelegate,HooDatePickerDelegate>
{
    int page;
    BOOL loadingHeader;
    
    NSString *startDate;//开始日期
    NSString *endDate;//开始日期
    
    NSString *contract_type;//合同状态
    
}

@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据

@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, copy) NSString *search;  //搜索字段

@property (nonatomic, strong)DefaultView *defaultView;

@property (nonatomic, strong) HeaderViewForDailCheckView * headerLable;

@property (nonatomic, strong)HooDatePicker *datePicker1;  //开始日期
@property (nonatomic, strong)HooDatePicker *datePicker2;  //结束日期
@property (nonatomic, strong)ValuePickerView *pickerView;

@property (nonatomic, weak)UIButton *btn1;  //开始日期btn
@property (nonatomic, weak)UIButton *btn2;  //结束日期btn

@property (nonatomic, weak)UIButton *btn3;  //type btn

@end

@implementation ContractDealListViewController


- (HooDatePicker *)datePicker1{
    if (!_datePicker1) {
        _datePicker1 = [[HooDatePicker alloc] initWithSuperView:self.view withTitle:@"请选择开始日期"];
        _datePicker1.delegate = self;
        _datePicker1.datePickerMode = HooDatePickerModeDate;
    }
    return _datePicker1;
}

- (HooDatePicker *)datePicker2{
    if (!_datePicker2) {
        _datePicker2 = [[HooDatePicker alloc] initWithSuperView:self.view withTitle:@"请选择结束日期"];
        _datePicker2.delegate = self;
        _datePicker2.datePickerMode = HooDatePickerModeDate;
    }
    return _datePicker2;
}


- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
        _searchBar.placeholder = @"合同编号/买家姓名、电话/卖家姓名、电话";
        _searchBar.delegate = self;
        _searchBar.tintColor = UIColorFromRGB(0xff3800);
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version == 7.0) {
            _searchBar.backgroundColor = [UIColor clearColor];
            _searchBar.barTintColor = [UIColor clearColor];
        }else{
            for(int i =  0 ;i < _searchBar.subviews.count;i++){
                UIView * backView = _searchBar.subviews[i];
                if ([backView isKindOfClass:NSClassFromString(@"UISearchBarBackground")] == YES) {
                    [backView removeFromSuperview];
                    [_searchBar setBackgroundColor:[UIColor clearColor]];
                    break;
                }else{
                    NSArray * arr = _searchBar.subviews[i].subviews;
                    for(int j = 0;j<arr.count;j++   ){
                        UIView * barView = arr[i];
                        if ([barView isKindOfClass:NSClassFromString(@"UISearchBarBackground")] == YES) {
                            [barView removeFromSuperview];
                            [_searchBar setBackgroundColor:[UIColor clearColor]];
                            break;
                        }
                    }
                }
            }
        }
    }
    return _searchBar;
}

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];
        _defaultView.placeText.text = @"暂未获取到任何合同信息";
    }
    return _defaultView;
}

- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:_mainTableView.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.5;
    }
    return _backgroundView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        
        CGFloat offex = 64;
        
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH - offex)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
//        _headerLable = [[HeaderViewForDailCheckView alloc] initWithFrameWithContact:CGRectMake(0, 0, kScreenW, 46) titleArr:@[currentDateStr,currentDateStr,@"成交类型"]];
        _headerLable = [[HeaderViewForDailCheckView alloc] initWithFrameWithContact:CGRectMake(0, 0, kScreenW, 46) titleArr:@[currentDateStr,currentDateStr,@"买卖"]];
        _headerLable.headerViewDelegate = self;
        _mainTableView.tableHeaderView = _headerLable;
    }
    return _mainTableView;
}

- (void)requestData:(int)pageindex{
   
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealList?token=%@&search=%@&start_time=%@&end_time=%@&type=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_search,startDate,endDate,contract_type]);
    NSString *urlStr = @"zhpay/NewDealList";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];

    NSDictionary *parm = @{ @"token":[EBPreferences sharedInstance].token,
                            @"page":[NSNumber numberWithInt:pageindex],
                            @"page_size":[NSNumber numberWithInt:12],
                            @"search":_search,
                            @"start_time":startDate,
                            @"end_time":endDate,
                            @"type":contract_type
                           };
    
    NSLog(@"parm = %@",parm);
    [HttpTool post:urlStr parameters:parm
      success:^(id responseObject) {
           [EBAlert hideLoading];
           
           if (  loadingHeader ==  YES) {
               [self.dataArray removeAllObjects];
               //清空
               _searchBar.text = @"";
               _search = @"";
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           
           NSArray *tmpArray = currentDic[@"data"][@"data"];//公告列表
           
           if ([currentDic[@"code"] integerValue] == 0) {
               for (NSDictionary *dic in tmpArray) {
                   [_dataArray addObject:dic];
               }
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           if (_dataArray.count == 0) {//如果没有数据
               [self.mainTableView addSubview:self.defaultView];
           }else{
               if (self.defaultView) {
                   [self.defaultView  removeFromSuperview];
               }
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
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [self.mainTableView.mj_footer endRefreshing];
           [self.mainTableView.mj_header endRefreshing];
       }];
    
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

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = _dataArray[indexPath.section];
    if ([dic[@"type"] isEqualToString:@"买卖"]) {
        ContractDealTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"dealCell" forIndexPath:indexPath];
        [cell setDic:dic];//有数据来的时候打开
        return cell;
    }else{
        ContactRentTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"rentCell" forIndexPath:indexPath];
        [cell setDic:dic];//有数据来的时候打开
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = _dataArray[indexPath.section];
    
    if ([dic[@"type"] isEqualToString:@"买卖"]) {
        return 239; //买卖的239
    }else{
        return 271; //租赁的271
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入详情
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.section];
    
    if ([dic[@"type"] isEqualToString:@"买卖"]) {
        NSDictionary *dic = _dataArray[indexPath.section];
        ContractDealDetailViewController *cddvc = [[ContractDealDetailViewController alloc]init];
        cddvc.hidesBottomBarWhenPushed = YES;
        cddvc.deal_id = dic[@"deal_id"];
        cddvc.deal_code = dic[@"contract_code"];
        [self.navigationController pushViewController:cddvc animated:YES];
    }else{
        NSLog(@"进入租赁成交");
        NSDictionary *dic = _dataArray[indexPath.section];
        ContractRentDetailViewController *cddvc = [[ContractRentDetailViewController alloc]init];
        cddvc.hidesBottomBarWhenPushed = YES;
        cddvc.deal_id = dic[@"deal_id"];
        cddvc.deal_code = dic[@"contract_code"];
        [self.navigationController pushViewController:cddvc animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 15)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 8; //这里是我的headerView和footerView的高度
    if (_mainTableView.contentOffset.y<=sectionHeaderHeight&&_mainTableView.contentOffset.y>=0) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-_mainTableView.contentOffset.y, 0, 0, 0);
    } else if (_mainTableView.contentOffset.y>=sectionHeaderHeight) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.searchBar;
    if (@available(iOS 11.0, *)) {
        [[self.searchBar.heightAnchor constraintEqualToConstant:44.0] setActive:YES];
    }
    _dataArray = [NSMutableArray array];
    
    _search = @"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
    startDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentDateStr]];//开启日
    endDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentDateStr]+(24*60*60-1)];//结束日期
    
    contract_type = @"";
    
    [self.view addSubview:self.mainTableView];
    
    
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    
    [self refreshHeader];
    [self footerLoading];
    
    [self.mainTableView registerClass:[ContractDealTableViewCell class] forCellReuseIdentifier:@"dealCell"];
    [self.mainTableView registerClass:[ContactRentTableViewCell class] forCellReuseIdentifier:@"rentCell"];
    
    [self beaverStatistics:@"DealBargain"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -- UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //开始编辑
    [_mainTableView addSubview:self.backgroundView];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    //结束编辑
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
    }
    [_searchBar resignFirstResponder];
    _search = searchBar.text;
    [self refreshHeader];//刷新头部
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //    contract_code = searchBar.text;//将数据负责
}

- (void)btnClick:(UIButton *)btn{
    
    switch (btn.tag) {
        case 0: case 1:
            [self addDatePickerView:btn];
            break;
        case 2:
            [self addPickerViewForState:btn];
            break;
        default:
            break;
    }
}

//日期选择控制器
- (void)addDatePickerView:(UIButton *)btn{
    if (btn.tag == 0) {
        [self.datePicker1 show];
        _btn1 = btn;
    }else{
        [self.datePicker2 show];
        _btn2 = btn;
    }
}

//确认情况
- (void)addPickerViewForState:(UIButton *)btn{
    self.pickerView.dataSource = @[@"买卖",@"租赁"];
    self.pickerView.pickerTitle = @"请选择成交类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [btn setTitle:result forState:UIControlStateNormal];
        if ([result isEqualToString:@"待确认"]) {
            contract_type = @"已审核";
        }else{
            contract_type = result;
        }
        NSLog(@"result=%@",result);
        [weakSelf refreshHeader];
    };
    [self.pickerView show];
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
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    NSLog(@"currentOlderOneDateStr=%@",currentOlderOneDateStr);
    
    if ([date compare:[NSDate date]] > 0) {
        [EBAlert alertError:@"请选择小于本月的月份" length:2.0 ];
        return;
    }
    
    
    if (dataPicker == _datePicker1) {
        NSString * tmpStr = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentOlderOneDateStr]];
        //与结束日期比较
        if ([tmpStr integerValue] > [endDate integerValue]) {
            [EBAlert alertError:@"开始日期小于结束日期" length:2.0 ];
            return;
        }
        [_btn1 setTitle:currentOlderOneDateStr forState:UIControlStateNormal];
        startDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentOlderOneDateStr]];
        _datePicker1.date = date;
    }else{
        [_btn2 setTitle:currentOlderOneDateStr forState:UIControlStateNormal];
        endDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentOlderOneDateStr]+(24*60*60-1)];
        _datePicker2.date = date;
    }
    NSLog(@"startDate=%@",startDate);
    NSLog(@"endDate=%@",endDate);
    //两个都有
    
    if (![endDate isEqualToString:@""] && ![startDate isEqualToString:@""]) {
        [self refreshHeader];
    }
}


@end
