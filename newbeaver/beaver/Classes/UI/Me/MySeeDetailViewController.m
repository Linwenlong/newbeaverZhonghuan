//
//  MySeeDetailViewController.m
//  beaver
//
//  Created by mac on 17/8/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySeeDetailViewController.h"
#import "MySeeDetailTableViewCell.h"
#import "MJRefresh.h"
#import "MySeeDetailModel.h"
#import "ClientListViewController.h"
#import "HouseListViewController.h"
#import "EBController.h"
#import "EBFilter.h"

@interface MySeeDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)UIView * footerView;
@property (nonatomic, strong)UIView * headerView;
@property (nonatomic, assign)BOOL hiddenHeaderAndfooterView;

@end

@implementation MySeeDetailViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-60) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title  = @"我的带看";
    _dataArray = [NSMutableArray array];
    _hiddenHeaderAndfooterView = YES;
    [self.view addSubview:self.mainTableView];
     [self refreshHeader];
     [_mainTableView registerNib:[UINib nibWithNibName:@"MySeeDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark -- RequestData
- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Visit/visitHouseDetil?token=%@&month=%@",[EBPreferences sharedInstance].token,_currentDate]);
    NSString *urlStr = @"Visit/visitHouseDetil";
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
          @"month":_currentDate}
           success:^(id responseObject) {
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
               defaultView.placeText.text = @"暂无详情数据";
               [_dataArray removeAllObjects];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               NSDictionary *dic = currentDic[@"data"];
               NSLog(@"dic = %@",dic);
               if ([currentDic[@"code"] integerValue] == 0) {
                   NSArray *tmpArr = dic[@"data"];
                   if (tmpArr.count ==0) {
                         self.hiddenHeaderAndfooterView = YES;         
                   }else{
                       self.hiddenHeaderAndfooterView = NO;
                       for (NSDictionary *dic in tmpArr) {
                           MySeeDetailModel *model = [[MySeeDetailModel alloc]initWithDict:dic];
                           [_dataArray addObject:model];
                    }
                }
                    [self.mainTableView reloadData];
                    [self.mainTableView.mj_header endRefreshing];
               }else{
                   [EBAlert alertError:@"请求失败" length:2.0f];
               }
           } failure:^(NSError *error) {
               if (_dataArray.count == 0){
                   //是否启用占位图
                   _mainTableView.enablePlaceHolderView = YES;
                   DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
                   defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
                   defaultView.placeText.text = @"数据获取失败";
                   [self.mainTableView reloadData];
               }
               [EBAlert alertError:@"请检查网络" length:2.0f];
              [self.mainTableView.mj_header endRefreshing];
           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MySeeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MySeeDetailModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MySeeDetailModel *model = _dataArray[indexPath.row];
    
    if ([self.type isEqualToString:@"house"] ) {
    
     HouseListViewController *list = [[HouseListViewController alloc]init];
        NSString *tmpStr = [model.house_ids stringByReplacingOccurrencesOfString:@"," withString:@";"];
        NSDictionary *   parm = @{
                     @"page" : @1,
                     @"type" : @"sale",
                     @"page_size" : @10,
                     @"idlist":[tmpStr substringToIndex:tmpStr.length-1]
                     };
        list.title = @"带看房";
        list.listType = EHouseListTypeFilter;
        list.appParam = parm;
        list.isLWL = YES;
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }else{
    EBFilter *filter = [[EBFilter alloc] init];
    filter.keyword = model.client_code;
    filter.keywordType = @"code";
    ClientListViewController *listViewController = [[EBController sharedInstance] showClientListWithType:EClientListTypeSearch filter:filter title:model.client_code house:nil];
    NSLog(@"listViewController=%@",listViewController);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_hiddenHeaderAndfooterView == YES) {
        self.headerView.hidden = YES;
    }else{
        self.headerView.hidden = NO;
    }
    return self.headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_hiddenHeaderAndfooterView == YES) {
        self.footerView.hidden = YES;
    }else{
         self.footerView.hidden = NO;
    }
    return self.footerView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 30)];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (UIView *)footerView{
    if (!_footerView) {
       _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 30)];
        _footerView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 0, 14, 14)];
        imageView.image = [UIImage imageNamed:@"yuan"];
        [_footerView addSubview:imageView];
    }
    return _footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


@end
