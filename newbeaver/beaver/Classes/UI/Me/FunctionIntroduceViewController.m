//
//  FunctionIntroduceViewController.m
//  beaver
//
//  Created by mac on 17/11/2.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FunctionIntroduceViewController.h"
#import "FunctionIntroduceTableViewCell.h"
#import "FunctionModel.h"
@interface FunctionIntroduceViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong)UITableView *mainTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;//楼盘卖点
@end

@implementation FunctionIntroduceViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]init];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功能介绍";
    _dataArray = [NSMutableArray array];
    NSArray *tmpArr = @[
                        @{
                        @"subtitle":@"2.0.0",
                        @"date":@"2017年12月1日",
                        @"content":@"1.新增财物收款功能模块。\n2.新增按装修类型筛选房源。\n3.优化一些界面问题以及bug"
                        }
                        ,@{
                            @"subtitle":@"2.0.1",
                            @"date":@"2017年12月5日",
                            @"content":@"1.修复公司收入分账点击合同详情闪退问题。\n2.费用统计加载不出来数据。"
                            }
                        ,@{
                            @"subtitle":@"2.0.2",
                            @"date":@"2017年12月8日",
                            @"content":@"1.费用统计适应月,半月,十日,日结统计。\n2.费用统计适应全部城市分公司。"
                            }
                        ,@{
                            @"subtitle":@"2.0.3",
                            @"date":@"2018年1月12日",
                            @"content":@"1.财务收款功能更新。\n2.房源新增增加散盘录入规则。\n3.工作台右上角消息栏去除了通知撤单功能。"
                            }
                        ,@{
                            @"subtitle":@"2.0.4",
                            @"date":@"2018年3月15日",
                            @"content":@"1.工作总结。\n2.部分性能优化"
                            }
                        ,@{
                            @"subtitle":@"2.0.5",
                            @"date":@"2018年4月25日",
                            @"content":@"1.房源详情上传图片同步erp限制。\n2.通讯录erp同步限制。\n3.部分功能优化"
                            }
                        ];
    for (NSDictionary *dic in tmpArr) {
        FunctionModel *model = [[FunctionModel alloc]initWithDict:dic];
        [_dataArray addObject:model];
    }
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.mainTableView];
    [_mainTableView registerClass:[FunctionIntroduceTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FunctionModel *model = _dataArray[indexPath.row];
    FunctionIntroduceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FunctionModel *model = _dataArray[indexPath.row];
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[FunctionIntroduceTableViewCell class] contentViewWidth:kScreenW];
}


#pragma mark -- Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
