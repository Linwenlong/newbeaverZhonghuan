//
//  GroupsViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GroupsViewController.h"
#import "EBViewFactory.h"
#import "RTLabel.h"
#import "EBIMManager.h"
#import "EBIMGroup.h"
#import "EBController.h"

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_groups;
    UITableView *_tableView;
    BOOL _hasMore;
    BOOL _isEmpty;
}

@end

#define GROUP_PAGE_SIZE 10

@implementation GroupsViewController

- (void)loadView
{
    [super loadView];

//    self.title = self.groupSelected ? NSLocalizedString(@"share_to_group", nil) : NSLocalizedString(@"saved_groups", nil);
    self.title = NSLocalizedString(@"saved_groups", nil);

    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionIndexColor = [EBStyle grayTextColor];

    [self.view addSubview:_tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _groups = [[EBIMManager sharedInstance] getSavedGroups:1 pageSize:GROUP_PAGE_SIZE];

    _isEmpty = _groups.count == 0;
    _hasMore = _groups.count == GROUP_PAGE_SIZE;

    [_tableView reloadData];
}

#pragma -mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEmpty)
    {
        return _tableView.frame.size.height;
    }
    return  68.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isEmpty)
    {
        return 1;
    }
    return  _groups.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _groups.count)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        EBIMGroup *group = _groups[[indexPath row]];
        
        if (self.groupSelected)
        {
            self.groupSelected(group);
        }
        else
        {
            [[EBController sharedInstance] openGroupChat:group popToConversation:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasMore && [indexPath row] == _groups.count - 1)
    {
        NSArray *moreGroups = [[EBIMManager sharedInstance] getSavedGroups:1 pageSize:GROUP_PAGE_SIZE];
        _hasMore = _groups.count == GROUP_PAGE_SIZE;
        if (moreGroups.count > 0)
        {
            [_groups addObjectsFromArray:moreGroups];
            [_tableView reloadData];
        }
    }
}

#pragma -mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEmpty)
    {
        static NSString *identifierEmpty = @"ebListViewEmptyCell";
        UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:identifierEmpty];
        if (emptyCell == nil)
        {
            emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierEmpty];
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [emptyCell.contentView addSubview:[self emptyView]];
        }
        
        return emptyCell;
    }
    NSInteger row = [indexPath row];

    EBIMGroup *group = _groups[row];

    static NSString *cellIdentifier = @"cellSection0";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        UIImageView *avatarView = [EBViewFactory avatarImageView:48];
        avatarView.tag = 88;
        avatarView.frame = CGRectOffset(avatarView.frame, 15, 10);
        avatarView.image = [UIImage imageNamed:@"avatar_group"];
        avatarView.contentMode = UIViewContentModeCenter;
        avatarView.layer.borderWidth = 1.0;
        avatarView.layer.borderColor = [UIColor colorWithRed:81/255.0 green:182.0/255.0f blue:210.0/255.09 alpha:1.0].CGColor;
        [cell.contentView addSubview:avatarView];

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 15, 237, 18)];
        nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        nameLabel.textColor = [EBStyle blackTextColor];
        nameLabel.tag = 90;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:nameLabel];

        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 35, 237, 18)];
        countLabel.font = [UIFont systemFontOfSize:12.0];
        countLabel.textColor = [EBStyle blackTextColor];
        countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        countLabel.tag = 93;
        [cell.contentView addSubview:countLabel];

        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:68 leftMargin:72]];
    }

//    UIImageView *avatarView = (UIImageView *)[cell.contentView viewWithTag:88];

    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:90];
    UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:93];

    nameLabel.text = group.groupTitle;
    countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"group_member_number", nil), group.members.count];
//
//    RTLabel *label  = (RTLabel *)[cell.contentView viewWithTag:99];
//    label.text = [NSString stringWithFormat:@"<font size=14 color='#5a5a5a'>%@</font>\r\n<font size=12 color='#b7b7b8'>%d人</font>",
//                    group.groupTitle, group.members.count];


    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)emptyView
{
    UIImage *image = [UIImage imageNamed:@"loading_empty"];
    UIView *transitionView = [[UIView alloc] initWithFrame:_tableView.bounds];
    transitionView.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(0, [EBStyle emptyOffsetYInListView], _tableView.bounds.size.width, image.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    [transitionView addSubview:imageView];
    
    frame = CGRectOffset(frame, 0, frame.size.height + 5.0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[EBStyle grayTextColor]];
    [label setText:NSLocalizedString(@"empty_saved_group", nil)];
    [label setFont:[UIFont systemFontOfSize:14.f]];
    [transitionView addSubview:label];
    
    return transitionView;
}

@end
