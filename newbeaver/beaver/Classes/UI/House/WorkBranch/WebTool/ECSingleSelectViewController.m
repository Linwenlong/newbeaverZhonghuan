//
//  ECTaxFeeSelectViewController.m
//  chow
//
//  Created by kevin on 15/4/15.
//  Copyright (c) 2015年 eallcn. All rights reserved.
//

#import "ECSingleSelectViewController.h"
#import "EBUtil.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "EBAlert.h"

@interface ECSingleSelectViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation ECSingleSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
//    [self.tableView scrollWithEggacheView:self.navigationBar fixedHeight:0 ctlView:self.view];
}

- (void)dealloc
{
//    [self.tableView removeObserver];
}

- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0, self.view.width, self.view.height)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"taxFeeSelect";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        [cell.contentView addSubview:[EBViewFactory lineWithHeight:cell.height - 0.5f left:10 right:0.f]];
        cell.tintColor = [EBStyle blueTextColor];
    }
    if (indexPath.row == self.currentValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [EBStyle blackTextColor];
    cell.textLabel.text = self.options[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *lCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentValue inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    lCell.accessoryType = UITableViewCellAccessoryNone;
    self.currentValue = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(singleSelectViewController:didSelectValue:forIndexPath:)]) {
        [self.delegate singleSelectViewController:self didSelectValue:indexPath.row forIndexPath:self.indexPath];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
