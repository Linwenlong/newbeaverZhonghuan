//
//  WorkChooseModelViewController.m
//  beaver
//
//  Created by mac on 18/1/17.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkChooseModelViewController.h"

#import "WorkBrokerModelViewController.h"
#import "WorkTradeStaffViewController.h"
#import "WorkTradeManageViewController.h"
#import "WorkTradeCenterViewController.h"
#import "WorkDeptManagerViewController.h"
#import "WorkDeptInspectorViewController.h"

@interface WorkChooseModelViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSArray *dataArray;//数据

@end

@implementation WorkChooseModelViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = @[@"经纪人",@"店助",@"店长",@"区域经理",@"大区总监",@"交易中心员工",@"交易中心主管",@"交易中心签约岗",@"部门经理"];
    self.title = @"选择职务";
    [self.view addSubview:self.mainTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = LWL_DarkGrayrColor;
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入详情
    NSLog(@"进入工作模版");
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = self.dataArray[indexPath.row];
    if ([str isEqualToString:@"经纪人"]) {
        WorkBrokerModelViewController *wbvc = [[WorkBrokerModelViewController alloc]init];
        wbvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wbvc animated:YES];
    }else if ([str isEqualToString:@"大区总监"]){
        WorkDeptInspectorViewController *wdivc = [[WorkDeptInspectorViewController alloc]init];
        wdivc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wdivc animated:YES];
    }else if ([str isEqualToString:@"交易中心员工"]){
        WorkTradeStaffViewController *wtfvc = [[WorkTradeStaffViewController alloc]init];
        wtfvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtfvc animated:YES];
    }else if ([str isEqualToString:@"交易中心主管"]){
        WorkTradeManageViewController *wtmvc = [[WorkTradeManageViewController alloc]init];
        wtmvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtmvc animated:YES];
    }else if ([str isEqualToString:@"交易中心签约岗"]){
        WorkTradeCenterViewController *wtcvc = [[WorkTradeCenterViewController alloc]init];
        wtcvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtcvc animated:YES];
    }else if ([str isEqualToString:@"部门经理"]){
        WorkDeptManagerViewController *wdmvc = [[WorkDeptManagerViewController alloc]init];
        wdmvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wdmvc animated:YES];
    }
    
    
}


@end
