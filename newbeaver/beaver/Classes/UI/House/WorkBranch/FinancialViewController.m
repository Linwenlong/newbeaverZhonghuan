//
//  FinancialViewController.m
//  beaver
//  财物收款
//  Created by mac on 17/11/26.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialViewController.h"
#import "FinancialTableViewCell.h"
#import "FinancialDetailViewController.h"
#import "HttpTool.h"
#import "MJRefresh.h"

@interface FinancialViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISearchBar *_searchBar;
    int page;
    BOOL loadingHeader;
}

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据

@property (nonatomic, strong)UIView *backgroundView;
@property (nonatomic, copy) NSString *dept_id; //部门id
@property (nonatomic, copy) NSString *search;  //搜索字段

@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation FinancialViewController


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
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

- (void)requestData:(int)pageindex{
    if (_dept_id == nil) {
        [EBAlert alertError:@"部门的ID为空,请重新登录" length:2.0f];
        return;
    }
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/houseDealList?token=%@&department_id=%@&search=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_dept_id,_search]);

    NSString *urlStr = @"zhpay/houseDealList";
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
//    _dept_id
    [HttpTool post:urlStr parameters:
            @{@"token":[EBPreferences sharedInstance].token,
              @"page":[NSNumber numberWithInt:pageindex],
              @"page_size":[NSNumber numberWithInt:12],
              @"department_id":_dept_id,
              @"search":_search
    } success:^(id responseObject) {
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
    FinancialTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setDic:dic];//有数据来的时候打开
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 230;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入详情
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     NSDictionary *dic = _dataArray[indexPath.section];
    FinancialDetailViewController *fdvc = [[FinancialDetailViewController alloc]init];
    fdvc.hidesBottomBarWhenPushed = YES;
    fdvc.deal_id = dic[@"deal_id"];
    fdvc.contract_code = dic[@"contract_code"];
    fdvc.dept_id = _dept_id;
    fdvc.deal_type = dic[@"type"];
    [self.navigationController pushViewController:fdvc animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
//    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
//    line1.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
//        [view addSubview:line1];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [view addSubview:line2];
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
    _searchBar.placeholder = @"合同编号/买家姓名/卖家姓名";
    _searchBar.delegate = self;
    _searchBar.tintColor = UIColorFromRGB(0xff3800);
    self.navigationItem.titleView = _searchBar;
    
    _dataArray = [NSMutableArray array];
    
    _dept_id = [[EBPreferences sharedInstance].dept_id componentsSeparatedByString:@"_"].lastObject;//部门id
    _search = @"";
    
    [self.view addSubview:self.mainTableView];
    
    [self refreshHeader];
    [self footerLoading];
    
    [self.mainTableView registerNib:[UINib nibWithNibName:@"FinancialTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
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



@end
