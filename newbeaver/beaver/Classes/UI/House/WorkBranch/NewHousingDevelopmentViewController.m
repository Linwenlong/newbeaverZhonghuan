//
//  NewHousingDevelopmentViewController.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewHousingDevelopmentViewController.h"
#import "NewHousingDevelopmentTableViewCell.h"
#import "AddNewHousingDevelopmentViewController.h"
#import "EBCache.h"
#import "CommuityModel.h"
#import "BMChineseSort.h"
#import "MJRefresh.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "EBAlert.h"
#import "HouseListViewController.h"

@interface NewHousingDevelopmentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;

//按钮
@property (nonatomic, strong)UIButton *add_button;//新增报备

@property (nonatomic, strong)NSMutableArray *allCommuityModel;
@property (nonatomic, strong)NSMutableArray *indexArray;
@property (nonatomic, strong)NSMutableArray *tmpArray;

@end

@implementation NewHousingDevelopmentViewController

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"添加关注小区" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [_add_button addTarget:self action:@selector(addNewHousingDevelopment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-114)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小区新上";
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.add_button];
    [self refreshHeader];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"NewHousingDevelopmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
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
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Newcommunity/communityList?token=%@",[EBPreferences sharedInstance].token]);
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:@"Community/communityList" parameters:
     @{@"token":[EBPreferences sharedInstance].token,}
           success:^(id responseObject) {
               
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"noCommuity"];
               defaultView.placeText.text = @"您还没有关注任何小区哦";
               
               [EBAlert hideLoading];
               [_dataArray removeAllObjects];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                        _dataArray  = currentDic[@"data"];
               }else{
                   [EBAlert alertError:@"加载失败" length:1.0f];
               }
               [self.mainTableView.mj_header endRefreshing];
               [self.mainTableView reloadData];
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
               [self.mainTableView.mj_header endRefreshing];
           }];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewHousingDevelopmentTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dic = _dataArray[indexPath.row];
    [cell setDic:dic];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //小区筛选
    NSDictionary *dic = _dataArray[indexPath.row];
    //进入买卖房源列表
    NSDictionary *parm = nil;
    HouseListViewController *list = [[HouseListViewController alloc]init];
    parm = @{
                 @"page" : @1,
                 @"type" : @"sale",
                 @"page_size" : @10,
                 @"community_id":dic[@"community_id"],
                 @"wap_action":@"48h最新房源"
                 };
    
    list.title = dic[@"community"];
    list.listType = EHouseListTypeFilter;
    list.appParam = parm;
    list.isLWL = YES;
    list.hidesBottomBarWhenPushed = YES;
    NSLog(@"self.navigationController=%@",self.navigationController);
    [self.navigationController pushViewController:list animated:YES];
//    [self presentViewController:list animated:YES completion:nil];
}

//删除
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //调用接口删除
        //小区筛选
        NSDictionary *dic = _dataArray[indexPath.row];
        NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Community/communityDel?token=%@&document_id=%@",[EBPreferences sharedInstance].token,dic[@"document_id"]]);
        [EBAlert showLoading:@"删除中..." allowUserInteraction:NO];
        [HttpTool post:@"Community/communityDel" parameters:
         @{@"token":[EBPreferences sharedInstance].token,
            @"document_id":dic[@"document_id"]                                                                             }success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                   [EBAlert alertSuccess:@"删除成功" allowUserInteraction:1.0f];
                   [_dataArray removeObjectAtIndex:indexPath.row];
               }else{
                   NSLog(@"删除失败");
               }
               [self.mainTableView reloadData];
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
           }];
    }
}

- (void)addNewHousingDevelopment:(UIButton *)btn{
    //进入添加关注小区地方
    AddNewHousingDevelopmentViewController *avc = [[AddNewHousingDevelopmentViewController alloc]init];
    avc.textBlock = ^{
        [self refreshHeader];
    };
    avc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:avc animated:YES];
}

@end
