//
//  HouseRoomCodeViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/4/25.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseRoomCodeViewController.h"

@interface HouseRoomCodeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy)UITableView *listTableView;

@end

@implementation HouseRoomCodeViewController
{
    NSArray *_data;
    NSMutableArray *allCitiesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择房间号";
    self.view.backgroundColor = [UIColor whiteColor];
    _data = @[@"选择座栋",@"选择单元",@"选择楼层",@"选择房号"];
    [self createMainView];
}

- (void)createMainView
{
    _listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH - 64)];
    _listTableView.dataSource = self;
    _listTableView.delegate   = self;
    [_listTableView setSeparatorInset:UIEdgeInsetsZero];
    [_listTableView setLayoutMargins:UIEdgeInsetsZero];
    _listTableView.backgroundColor = [UIColor whiteColor];
    _listTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_listTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text =  _data[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *dict = _data[indexPath.row];
//    self.returnBlock(dict[@"name"],dict[@"code"]);
//    [self.navigationController popViewControllerAnimated:YES];
}


@end
