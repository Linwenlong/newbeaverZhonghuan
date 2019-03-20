//
//  SearchViewController.m
//  beaver
//
//  Created by mac on 17/5/2.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchView.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "EBAlert.h"
#import "HotModel.h"
#import "ZHDCNewHouseDetailViewController.h"
#import "NewHouseListModel.h"
#import "NewHouseListTableViewCell.h"
#import "UITableView+PlaceHolderView.h"
#import "DefaultView.h"

@interface SearchViewController ()<SearchViewDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)SearchView *hotSearchView;

@property (nonatomic, strong)NSMutableArray  *hotArray;
@property (nonatomic, strong)NSMutableArray  *hotArrayLables;
@property (nonatomic, strong)UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *homeResoureTableView;
@property (nonatomic, strong)  NSMutableArray *dataArray;

@end

@implementation SearchViewController

//request
- (void)requestData:(NSString *)typeString withPgae:(int)pageindex{
    NSLog(@"SearchList=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/NewHouse/getList?token=%@&page=1&page_size=12&title=%@",[EBPreferences sharedInstance].token,typeString]);
    // 16c05409aa5f079b872ecbba6c522ee3
    //    [MBProgressHUD showMessage:@"数据加载中"];
    [HttpTool post:@"NewHouse/getList" parameters:@{@"token":[EBPreferences sharedInstance].token,@"page":[NSNumber numberWithInt:pageindex],
        @" page_size":[NSNumber numberWithInt:100],
            @"title":typeString
        } success:^(id responseObject) {
            
            //是否启用占位图
            _homeResoureTableView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_homeResoureTableView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
            defaultView.placeText.text = @"暂无详情数据";
            
            //每次搜索都得清空接口
            [_dataArray removeAllObjects];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray *tmpDic = currentDic[@"data"][@"data"];
            for (NSDictionary *dic in tmpDic) {
                NewHouseListModel *model = [[NewHouseListModel alloc]initWithDict:dic];
                [_dataArray addObject:model];
            }
             [self.homeResoureTableView reloadData];
            if (tmpDic.count == 0) {
                NSLog(@"处理逻辑");
                return ;
            }

        } failure:^(NSError *error) {
            //是否启用占位图
            _homeResoureTableView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_homeResoureTableView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
            defaultView.placeText.text = @"数据获取失败";
            [self.homeResoureTableView reloadData];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
    
}



- (UITableView *)homeResoureTableView{
    if (!_homeResoureTableView) {
        _homeResoureTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
        _homeResoureTableView.delegate = self;
        _homeResoureTableView.dataSource = self;
        _homeResoureTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_homeResoureTableView setSeparatorInset:UIEdgeInsetsZero];
        [_homeResoureTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _homeResoureTableView;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.frame = CGRectMake(0, 120, 300, 44);
        _searchBar.delegate = self;
        _searchBar.placeholder = @"请输入新房名称";
        _searchBar.backgroundImage = [UIImage new];
        [_searchBar setImage:[UIImage imageNamed:@"放大镜"]
                     forSearchBarIcon:UISearchBarIconSearch
                                state:UIControlStateNormal];
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
             [searchField setBackgroundColor:[UIColor lightTextColor]];
            searchField.textColor  = [UIColor whiteColor];
            [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            searchField.layer.cornerRadius = 14.0f;
            searchField.layer.borderColor = UIColorFromRGB(0xEF0000).CGColor;
            searchField.layer.borderWidth = 1;
            searchField.layer.masksToBounds = YES;
        }
    }
    return _searchBar;
}

- (void)backFirst:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    
    //为10000时候不显示返回键
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.searchBar;
 
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [self.navigationItem.rightBarButtonItem setImage:[UIImage new]];
    
    [self createData];
    [self.view addSubview:self.homeResoureTableView];
    [self.homeResoureTableView registerClass:[NewHouseListTableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)createData{
    _hotArray = [NSMutableArray array];
    _hotArrayLables = [NSMutableArray array];
     [EBAlert showLoading:@"加载中..."];
    NSLog(@"recomend=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/NewHouse/hotRecomend?token=%@",[EBPreferences sharedInstance].token]);
    [HttpTool post:@"NewHouse/hotRecommend"  parameters:@{@"token":[EBPreferences sharedInstance].token} success:^(id responseObject) {
         [EBAlert hideLoading];
        NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dataDic = dic[@"data"];
        NSDictionary *statistic = dataDic[@"statistic"];
        if ([statistic[@"count"] integerValue] <= 0) {
            [EBAlert alertError:@"暂无热门推荐"];
        }
        NSArray *data = dataDic[@"data"];
        for (NSDictionary *dic in  data) {
            HotModel *model = [[HotModel alloc]initWithDict:dic];
            [_hotArray addObject:model];
            [_hotArrayLables addObject:model.house_title];
        }
        _hotSearchView = [[SearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH) arrayLables:_hotArrayLables lableBackGroundColor:UIColorFromRGB(0xF5F5F5) withTitle:@"热门搜索"];
        _hotSearchView.searchViewDelegate = self;
        [self.view addSubview:_hotSearchView];
    } failure:^(NSError *error) {
         [EBAlert hideLoading];
         [EBAlert alertError:@"请检查网络" length:2.0f];
    }];
}

#pragma mark -- SearchViewDelegate
-(void)didSelected:(UIButton *)lable{
    HotModel *model = _hotArray[lable.tag];
    ZHDCNewHouseDetailViewController *dc = [[ZHDCNewHouseDetailViewController alloc]init];
    dc.house_id = model.house_id;
    dc.house_title = model.house_title;
    dc.sale_status = @"认筹";
    [self.navigationController pushViewController:dc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewHouseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NewHouseListModel *model  = _dataArray[indexPath.row];
    [cell setModel:model];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
    [UIView animateWithDuration:1 animations:^{
        cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewHouseListModel *model = _dataArray[indexPath.row];
    //进入详情控制器
    ZHDCNewHouseDetailViewController *detailVC = [[ZHDCNewHouseDetailViewController alloc]init];
    detailVC.house_id =  model.house_id;
    detailVC.house_title = model.house_name;
    detailVC.sale_status = model.sale_status;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark -- UISearchBar delegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}                      // called when text ends editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
  
    if (searchBar.text.length == 0) {
        _hotSearchView.hidden = NO;
        _homeResoureTableView.hidden = YES;
    }else{
        _homeResoureTableView.hidden = NO;
        //隐藏热门搜索
        _hotSearchView.hidden = YES;
//        [self requestData:_searchBar.text withPgae:1];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    [self requestData:_searchBar.text withPgae:1];
    
    [_searchBar resignFirstResponder];
}


@end
