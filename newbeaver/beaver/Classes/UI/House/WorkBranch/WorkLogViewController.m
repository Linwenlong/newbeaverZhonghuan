//
//  WorkLogViewController.m
//  beaver
//
//  Created by mac on 17/12/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "WorkLogViewController.h"
#import "HttpTool.h"
#import "MJRefresh.h"
#import "WorkLogModel.h"
#import "WorkLogTableViewCell.h"

@interface WorkLogViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loadingHeader;
}

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation WorkLogViewController

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];//需要更换
        _defaultView.placeText.text = @"暂无日志信息...";
    }
    return _defaultView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64-40)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
    [self refreshHeader];
    [self footerLoading];
    [self.mainTableView registerClass:[WorkLogTableViewCell class] forCellReuseIdentifier:@"cell"];
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

- (void)requestData:(int)pageindex{
    
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealLog?token=%@&deal_id=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_id]);
    if (_deal_id == nil) {
        [EBAlert alertError:@"合同id为空" length:2.0f];
        return;
    }

    NSString *urlStr = @"zhpay/NewDealLog";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           
           if (  loadingHeader ==  YES) {
               [self.dataArray removeAllObjects];
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSArray *tmpArray = currentDic[@"data"][@"data"];//公告列表
           NSLog(@"tmpArray=%@",tmpArray);
           
           if ([currentDic[@"code"] integerValue] == 0) {
               for (NSDictionary *dic in tmpArray) {
                   WorkLogModel *model = [[WorkLogModel alloc]initWithDict:dic];
                   [_dataArray addObject:model];
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



#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorkLogModel *model = _dataArray[indexPath.section];
    WorkLogTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setModel:model];//有数据来的时候打开
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorkLogModel *model = _dataArray[indexPath.section];
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[WorkLogTableViewCell class] contentViewWidth:kScreenW];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [view addSubview:line2];
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

@end
