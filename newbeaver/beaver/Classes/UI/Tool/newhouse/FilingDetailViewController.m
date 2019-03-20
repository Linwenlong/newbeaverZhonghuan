//
//  FilingDetailViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "FilingDetailViewController.h"
#import "EBViewFactory.h"
#import "EBStyle.h"

@interface FilingDetailViewController ()
{
    UIView *_headerView;
}

@end

@implementation FilingDetailViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = @"陈光奇";
    [self buildHeaderView];
    UITableView *_tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = _headerView;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;//dummy
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGFloat yOffset = 10.0;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 160.0, 17.0)];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.tag = 1000;
        [cell.contentView addSubview:textLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.0, yOffset, 120.0, 17.0)];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.text = @"2014-08-05 14:22";
        textLabel.tag = 1001;
        [cell.contentView addSubview:textLabel];
        
        yOffset += 17.0 + 2.0;
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 17.0)];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.tag = 1002;
        [cell.contentView addSubview:textLabel];
        yOffset += 17.0 + 10.0;
        
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:yOffset leftMargin:[EBStyle separatorLeftMargin]]];
    }
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:1000];
    textLabel.text = @"报备待确认";//dummy
    textLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    textLabel.text = @"2014-08-05 14:28";//dummy
    textLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    textLabel.text = @"备注:XXXX";//dummy
    
    return cell;
}

#pragma mark -Private Method

- (void)buildHeaderView
{
    if (_headerView)
    {
        for (UIView *view in _headerView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    CGSize nameSize = [EBViewFactory textSize:@"陈光奇" font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(160.0, 17.0)];//dummy
    CGFloat yOffset = 15.0;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, nameSize.width, 17.0)];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textColor = [EBStyle blackTextColor];
    textLabel.text = @"陈光奇";
    [_headerView addSubview:textLabel];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameSize.width + 15.0 + 10.0, yOffset, 290.0 - nameSize.width - 10.0, 17.0)];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textColor = [EBStyle blackTextColor];
    textLabel.text = @"13366123031";
    [_headerView addSubview:textLabel];
    
    yOffset += nameSize.height + 8.0;
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 17.0)];
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textColor = [EBStyle blackTextColor];
    textLabel.text = @"项目名称";
    [_headerView addSubview:textLabel];
    yOffset += 17.0 + 10.0;
    [_headerView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:yOffset leftMargin:0]];
    _headerView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset);
}

@end
