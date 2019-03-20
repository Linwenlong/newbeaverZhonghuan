//
//  LWLTableViewController.m
//  dev-beaver
//
//  Created by 林文龙 on 2018/11/27.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "LWLTableViewController.h"

@interface LWLTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView * mainTableView;

@end

@implementation LWLTableViewController


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
//        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 15,  75);
        _mainTableView.separatorColor = [UIColor redColor];
//        _mainTableView.contentInset = UIEdgeInsetsMake(50, 50, 50, 0);
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"房源收藏";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainTableView];
}

#pragma mark -- UITableViewDataSource

/**
 返回几段

 @param tableView 视图本身
 @return 返回多少段
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


/**
 每段返回几行

 @param tableView 视图本身
 @param section 当前的段
 @return 返回多少行
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    cell.separatorInset
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.text = [NSString stringWithFormat:@"index = %ld",indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setSeparatorInset:UIEdgeInsetsMake(0,15, 0, 15)];
//    [tableView setContentInset:UIEdgeInsetsMake(50, 50, 50, 0)];
}

@end
