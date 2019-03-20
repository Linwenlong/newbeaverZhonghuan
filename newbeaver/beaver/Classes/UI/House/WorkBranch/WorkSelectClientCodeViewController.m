//
//  WorkSelectClientCodeViewController.m
//  beaver
//
//  Created by mac on 18/1/19.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkSelectClientCodeViewController.h"
#import "HttpTool.h"
#import "MJRefresh.h"
#import "WorkClientCodeTableViewCell.h"

@interface WorkSelectClientCodeViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loadingHeader;
}

@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据

@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, copy) NSString *search;  //搜索字段

@property (nonatomic, strong)DefaultView *defaultView;


@end

@implementation WorkSelectClientCodeViewController


- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
        _searchBar.placeholder = @"请输入需求编号、客户姓名、电话";
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
        _defaultView.placeText.text = @"暂未获取到任何合客源信息";
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
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64)];
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
    self.navigationItem.titleView = self.searchBar;
    
    _dataArray = [NSMutableArray array];
    
    _search = @"";
    
    [self.view addSubview:self.mainTableView];
    
    [self refreshHeader];
    [self footerLoading];
    
    [self.mainTableView registerNib:[UINib nibWithNibName:@"WorkClientCodeTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

#pragma mark -- UITableViewDelegate
#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.dataArray[indexPath.row];
    WorkClientCodeTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDic:dic];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.dataArray[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 self.returnBlock(dic[@"client_code"],dic[@"customer_name"]);
    [self.navigationController popViewControllerAnimated:YES];
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
    _search = searchBar.text;//将数据负责
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
    
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
   
    [parm setObject:[NSNumber numberWithInt:pageindex] forKey:@"page"];
    [parm setObject:[NSNumber numberWithInt:12] forKey:@"page_size"];
    [parm setObject:_search forKey:@"search"];
    
    NSLog(@"dic = %@",parm);
    NSString *urlStr = @"jobsummary/jobClientList";//公司收入分账
    NSLog(@"urlStr = %@",urlStr);

    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:[parm mutableCopy] success:^(id responseObject) {
        [EBAlert hideLoading];
        //           [_dataArray removeAllObjects]; //移除所有
        //是否启用占位图
        if (loadingHeader ==  YES) {
            [self.dataArray removeAllObjects];
        }
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([currentDic[@"code"] integerValue] != 0) {
            [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            [self.mainTableView.mj_footer endRefreshing];
            [self.mainTableView.mj_header endRefreshing];
            return ;
        }
        NSArray *tmpArray = currentDic[@"data"][@"data"];
        for (NSDictionary *dic in tmpArray) {
            [self.dataArray addObject:dic];
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
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        [self.mainTableView.mj_header endRefreshing];
        [self.mainTableView.mj_footer endRefreshing];
    }];
    
}





@end
