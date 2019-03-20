//
//  CalcResultViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "CalcResultViewController.h"
#import "EBViewFactory.h"

@interface CalcResultViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation CalcResultViewController

@synthesize resultArray;

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    id data = self.resultArray[row];

    if ([data isKindOfClass:[NSDictionary class]])
    {
        id value = data[@"value"];
        if ([value isKindOfClass:[NSArray class]])
        {
            CalcResultViewController *controller = [[CalcResultViewController alloc] init];
            controller.resultArray = value;
            controller.title = data[@"title"];
            [self.navigationController pushViewController:controller animated:YES];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
        cell.textLabel.textColor = [EBStyle blackTextColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }

    NSInteger row = [indexPath row];
    id data = self.resultArray[row];

    UILabel *valueView = [EBViewFactory valueViewFromCell:cell accessory:NO];

    id value = nil;
    if ([data isKindOfClass:[NSDictionary class]])
    {
        cell.textLabel.text = data[@"title"];
        value = data[@"value"];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"md_result_period_fmt", nil), row + 1] ;
        value = [EBStyle formatMoney:[data floatValue]];
    }

    if ([value isKindOfClass:[NSString class]])
    {
        valueView.text = value;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        valueView.text = nil;
    }

    return cell;
}

- (void)loadView
{
    [super loadView];

    if (self.title == nil)
    {
        self.title = NSLocalizedString(@"md_result", nil);
    }

    UITableView *tableView = [[UITableView alloc]initWithFrame:[EBStyle fullScrTableFrame:NO]];
    tableView.backgroundView.alpha = 0;
    tableView.dataSource = self;
    tableView.delegate = self;

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    CGFloat leftMargin = [EBStyle separatorLeftMargin];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, 10.0,
            self.view.frame.size.width - leftMargin, 25)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [EBStyle grayTextColor];
    label.text = NSLocalizedString(@"md_result_hint", nil);
    [footerView addSubview:label];

    tableView.tableFooterView = footerView;

//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
