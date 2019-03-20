//
//  PublicNoticeViewController.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PublicNoticeViewController.h"
#import "PublicNoticeTableViewCell.h"
#import "MJRefresh.h"
#import "EBPreferences.h"
#import "HttpTool.h"
#import "PublicNoticeModel.h"
#import "EBAlert.h"
#import "ERPWebViewController.h"

@interface PublicNoticeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loadingHeader;
}
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)UILabel * headerLable;

@end

@implementation PublicNoticeViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
         _mainTableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        _headerLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40)];
        _headerLable.text = @"共0条公告";
        _headerLable.font = [UIFont systemFontOfSize:14.0f];
        _headerLable.textColor =  UIColorFromRGB(0xa4a4a4);
        _headerLable.textAlignment = NSTextAlignmentCenter;
        _mainTableView.tableHeaderView = _headerLable;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    
    [self.view addSubview:self.mainTableView];
    [self refreshHeader];
    [self footerLoading];
    
    [self.mainTableView registerNib:[UINib nibWithNibName:@"PublicNoticeTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
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

#pragma mark -- RequestData
- (void)requestData:(int)pageindex{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Index/getAnnouncementList?token=%@&page=%d&page_size=12",[EBPreferences sharedInstance].token,pageindex]);
    [HttpTool post:@"Index/getAnnouncementList" parameters:
        @{@"token":[EBPreferences sharedInstance].token,
          @"page":[NSNumber numberWithInt:pageindex],
          @" page_size":[NSNumber numberWithInt:12]
         }success:^(id responseObject) {
               //是否启用占位图
        _mainTableView.enablePlaceHolderView = YES;
        DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
        defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
        defaultView.placeText.text = @"暂无详情数据";

        if (loadingHeader == YES) {
            [self.dataArray removeAllObjects];
        }
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dic = currentDic[@"data"];
        NSNumber *count = dic[@"statistic"][@"count"];
        NSString *countText = [NSString stringWithFormat:@"共%@条公告",count];
        _headerLable.text =countText ;
        NSArray *tmpArray = dic[@"data"];//公告列表
        for (NSDictionary *dic in tmpArray) {
            PublicNoticeModel *model = [[PublicNoticeModel alloc]initWithDict:dic];
            [_dataArray addObject:model];
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
        if (_dataArray.count == 0) {
            //是否启用占位图
            _mainTableView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
            defaultView.placeText.text = @"数据获取失败";
            [self.mainTableView reloadData];
        }
            [EBAlert alertError:@"请检查网络" length:2.0f];
            [self.mainTableView.mj_header endRefreshing];
            [self.mainTableView.mj_footer endRefreshing];
    }];
    
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PublicNoticeTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger current = indexPath.row+1;
    //余数
    NSInteger remainder = current % 3;
    if (remainder == 1) {
        [cell setIConImage:[UIImage imageNamed:@"yellow"]];
    }else if (remainder == 2){
        [cell setIConImage:[UIImage imageNamed:@"green"]];
    }else{
        [cell setIConImage:[UIImage imageNamed:@"blue"]];
    }
    PublicNoticeModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PublicNoticeModel *nm = _dataArray[indexPath.row];
    NSString *detail = [NSString stringWithFormat:@"/index/announcement?document_id=%@",nm.document_id];
    if (detail && detail.length>0) {
        [self openWebPage:detail  title:nm.title date:nm.create_time];
    }
}

# pragma mark - actions

- (void)openWebPage:(NSString *)url title:(NSString *)title date:(NSString *)date
{
    ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
    erpVc.isHiddenRightBarItem = YES;
    
    erpVc.titleDate = date;
    [erpVc openWebPage:@{@"title":title,@"url":url,@"type":@"公告详情"}];
    
    erpVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:erpVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}



@end
