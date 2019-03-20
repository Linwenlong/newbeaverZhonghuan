//
//  FollowupRemindViewController.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FollowupRemindViewController.h"
#import "FollowupRemindTableViewCell.h"
#import "MJRefresh.h"
#import "AddFollowupRemindViewController.h"
#import "HouseListViewController.h"
#import "ClientListViewController.h"

@interface FollowupRemindViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;

//按钮
@property (nonatomic, strong)UIButton *add_button;//新增报备


@end

@implementation FollowupRemindViewController

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"添加跟进提醒" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [_add_button addTarget:self action:@selector(addNewFollowupRemind:) forControlEvents:UIControlEventTouchUpInside];
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
    self.title = @"跟进提醒";
    
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.add_button];
    [self refreshHeader];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"FollowupRemindTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
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
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/follow/follow?token=%@",[EBPreferences sharedInstance].token]);
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:@"follow/follow" parameters:
     @{@"token":[EBPreferences sharedInstance].token,}
           success:^(id responseObject) {
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"noFollow.png"];
               defaultView.placeText.text = @"您还没有添加跟进提醒哦";

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
    FollowupRemindTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setDic:_dataArray[indexPath.row]];
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
    NSDictionary *dic = _dataArray[indexPath.row];
    NSLog(@"dic = %@",dic);
    //进入买卖房源列表
    NSDictionary *parm = nil;
    if ([dic[@"type"] isEqualToString:@"出售"] || [dic[@"type"] isEqualToString:@"出租"]) {
         HouseListViewController *list = [[HouseListViewController alloc]init];
        NSString *type = @"sale";
        
        if ([dic[@"type"] isEqualToString:@"出租"]) {
            type = @"rent";
        }
        parm = @{
                 @"type" : type,
                 @"last_follow":[NSString stringWithFormat:@"le:%@",dic[@"last_follow"]],
                 @"rank":[NSString stringWithFormat:@"%@房源",dic[@"rank"]],
                 @"status":@"有效"
                 };
        list.title = @"跟进提醒";
        list.listType = EHouseListTypeFilter;
        list.appParam = parm;
        list.isLWL = YES;
        list.is_hidden_sort_btn = YES;
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }else{
        ClientListViewController *list = [[ClientListViewController alloc]init];
        NSString *type = @"sale";
        if ([dic[@"type"] isEqualToString:@"求租"]) {
            type = @"rent";
        }
        parm = @{
                 @"type" : type,
                 @"last_follow":[NSString stringWithFormat:@"le:%@",dic[@"last_follow"]],
                 @"rank":[NSString stringWithFormat:@"%@客源",dic[@"rank"]],
                 @"status":@"有效"
                 };
        list.title = @"跟进提醒";
        list.listType = EClientListTypeFilter;
        list.appParam = parm;
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }
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
        NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/follow/followDel?token=%@&document_id=%@",[EBPreferences sharedInstance].token,dic[@"document_id"]]);
        [EBAlert showLoading:@"删除中..."];
        [HttpTool post:@"follow/followDel" parameters:
         @{@"token":[EBPreferences sharedInstance].token,
           @"document_id":dic[@"document_id"]                                                                             }success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                   [EBAlert alertSuccess:@"删除成功" allowUserInteraction:1.0f];
                   [_dataArray removeObjectAtIndex:indexPath.row];
               }else{
                    [EBAlert alertError:@"删除失败" length:1.0f];
              
               }
               [self.mainTableView reloadData];
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
           }];
    }
}


- (void)addNewFollowupRemind:(UIButton *)btn{
    //进入添加添加跟进提醒
    AddFollowupRemindViewController *afrc = [[AddFollowupRemindViewController alloc]initWithNibName:@"AddFollowupRemindViewController" bundle:nil];
    afrc.textBlock = ^{
        [self refreshHeader];
    };
    afrc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:afrc animated:YES];
}


@end
