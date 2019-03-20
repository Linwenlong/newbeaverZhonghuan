//
//  SingleChoiceViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBSortOrderView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBIconLabel.h"

@interface EBSortOrderView () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    UIButton *_dismissButton;
}
@end

@implementation EBSortOrderView

#define HEIGHT_EXTRA 68.0
#define WIDTH_LEFT_TABLE_WIDTH 115.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO] style:UITableViewStyleGrouped];
        _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
        _tableView.backgroundView.alpha = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        [self addSubview:_tableView];

        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        _dismissButton = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:_dismissButton];
        [self sendSubviewToBack:_dismissButton];
        [_dismissButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)setOrders:(NSArray *)orders
{
    _orders = orders;

    NSInteger rows = orders.count * 2;
    CGFloat newHeight = 44.0 * rows;
    if (newHeight > self.frame.size.height - HEIGHT_EXTRA)
    {
        newHeight = self.frame.size.height - HEIGHT_EXTRA;
    }
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, newHeight);

   [_tableView reloadData];
//   [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_sortIndex % 2 inSection:_sortIndex / 2]
//                     atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void) tapped:(UIButton *) btn
{
     self.chooseSort(-1);
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _orders.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _sortIndex = [indexPath section] * 2 + [indexPath row];
    [tableView reloadData];
    self.chooseSort(_sortIndex);
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier =  @"orderCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell addSubview:[EBViewFactory defaultTableViewSeparator]];

        EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectMake(15, 0, 100, 44)];
        iconLabel.tag = 99;
        iconLabel.gap = 3.0;
        iconLabel.label.textColor = [EBStyle blackTextColor];
        iconLabel.label.font = [UIFont systemFontOfSize:16.0];

        [cell.contentView addSubview:iconLabel];
    }

    [self tableView:tableView updateCell:cell atSection:[indexPath section] atRow:[indexPath row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView updateCell:(UITableViewCell *)cell atSection:(NSInteger)section atRow:(NSInteger)row
{
    NSDictionary * item = _orders[section];

    EBIconLabel *iconLabel = (EBIconLabel *)[cell.contentView viewWithTag:99];
    iconLabel.label.text = item[@"title"];
    iconLabel.imageView.image = row % 2 == 0 ? [UIImage imageNamed:@"sort_asc"] : [UIImage imageNamed:@"sort_desc"];

    CGRect frame = iconLabel.currentFrame;
    if (frame.origin.y == 0.0)
    {
        iconLabel.frame = CGRectOffset(frame, 0, (44 - frame.size.height) / 2);
    }

    [iconLabel setNeedsLayout];

    if (section == _sortIndex / 2 && row == _sortIndex % 2)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


@end
