//
//  HouseListViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientTelListViewController.h"
#import "EBClient.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "EBFilter.h"
#import "ShareManager.h"
#import "EBCache.h"

@interface ClientTelListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    UIButton *_goButton;
    NSMutableSet *_selectedSet;
    NSInteger _timesRemain;
}
@end

@implementation ClientTelListViewController

- (void)loadView
{
    [super loadView];

//    self.title = self.groupSelected ? NSLocalizedString(@"share_to_group", nil) : NSLocalizedString(@"saved_groups", nil);
    self.title = NSLocalizedString(@"recommend_via_sms", nil);

    CGRect tableFrame = [EBStyle fullScrTableFrame:NO];
    tableFrame.size.height -= 56;

    _tableView = [[UITableView alloc] initWithFrame:tableFrame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    _tableView.allowsMultipleSelectionDuringEditing = YES;
    [_tableView setEditing:YES animated:NO];

    [self.view addSubview:_tableView];

    _goButton = [EBViewFactory countButtonWithFrame:CGRectMake(20, tableFrame.origin.y + tableFrame.size.height + 10,
            280, 36) title:NSLocalizedString(@"go_on", nil) target:self action:@selector(shareViaSms:)];

    [self.view addSubview:_goButton];

    _selectedSet = [[NSMutableSet alloc] init];

    [self updateSendButtonState];

    [_clientList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        EBClient *client = obj;
        if (client.timesRemain > 0)
        {
            _timesRemain = client.timesRemain;
            *stop = YES;
        }
    }];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

#pragma -mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  64.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _clientList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBClient *client = [_clientList objectAtIndex:[indexPath row]];
    if (client.phoneNumbers.count > 0)
    {
        [_selectedSet addObject:client];
        [self updateSendButtonState];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBClient *client = [_clientList objectAtIndex:[indexPath row]];
    if (client.phoneNumbers.count > 0)
    {
        [_selectedSet removeObject:client];
        [self updateSendButtonState];
    }
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    EBClient *client = [_clientList objectAtIndex:[indexPath row]];
//
//    return client.phoneNumbers.count > 0;
//}

#pragma -mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];

    static NSString *cellIdentifier = @"clientCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 237, 18)];
        nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        nameLabel.textColor = [EBStyle blackTextColor];
        nameLabel.tag = 90;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:nameLabel];

        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 237, 18)];
        phoneLabel.font = [UIFont systemFontOfSize:12.0];
        phoneLabel.textColor = [EBStyle blackTextColor];
        phoneLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        phoneLabel.tag = 93;
        [cell.contentView addSubview:phoneLabel];

        UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(218, 19.5, 43, 25)
                                                     title:NSLocalizedString(@"view_now", nil)
                                                    target:self action:@selector(viewPhoneNumber:)];
        [cell.contentView addSubview:btn];

        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:64 leftMargin:10]];

        UIView *selectedView = [[UIView alloc] init];
        [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:64.5 leftMargin:48]];
        cell.selectedBackgroundView = selectedView;
    }

    EBClient *client = [_clientList objectAtIndex:row];
    if ([_selectedSet containsObject:client])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }

    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:90];
    UILabel *phoneLabel = (UILabel *)[cell.contentView viewWithTag:93];

    UIButton *btn;
    for (UIView *view in cell.contentView.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            btn = (UIButton *)view;
            break;
        }
    }

    nameLabel.text = client.name;

    btn.hidden = YES;
    btn.tag = row + 1;

    if (client.phoneNumbers.count > 0)
    {
        phoneLabel.text = client.phoneNumbers[0];
    }
    else if (client.timesRemain > 0)
    {
        btn.hidden = NO;
        phoneLabel.text = [NSString stringWithFormat:NSLocalizedString(@"share_phone_format_client", nil), _timesRemain];
    }
    else if (client.timesRemain == 0)
    {
        phoneLabel.text = NSLocalizedString(@"view_phone_no_chance", nil);
    }
    else if (client.timesRemain < 0)
    {
        phoneLabel.text = NSLocalizedString(@"no_access_to_this_phone", nil);
    }

    if (client.phoneNumbers.count > 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)viewPhoneNumber:(UIButton *)btn
{
    EBClient *client = [_clientList objectAtIndex:(btn.tag - 1)];
    [[EBHttpClient sharedInstance] clientRequest:@{@"id":client.id, @"type": [EBFilter typeString:client.rentalState]}
                                 viewPhoneNumber:^(BOOL success, id result)
                                 {
                                     if (success)
                                     {
                                         NSDictionary *detail = result[@"detail"];
                                         client.phoneNumbers = detail[@"phone_numbers"];

                                         [_selectedSet addObject:client];
                                         [_tableView reloadData];
                                         [self updateSendButtonState];

                                         [[EBCache sharedInstance] updateCacheByViewClientDetail:client];
                                     }
                                 }];
}

- (void)shareViaSms:(UIButton *)btn
{
    NSMutableDictionary *content = [[NSMutableDictionary alloc] initWithDictionary:self.userInfo];

    NSMutableArray *toPhones = [[NSMutableArray alloc] init];
    [_selectedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
    {
       EBClient *client = (EBClient *)obj;
       if (client.phoneNumbers.count > 0)
       {
           [toPhones addObject:client.phoneNumbers[0]];
       }
    }];
    content[@"to"] = toPhones;

    [[ShareManager sharedInstance] shareContent:content withType:EShareTypeMessage handler:^(BOOL success, NSDictionary *info)
    {
        if (success)
        {

            [self.navigationController popViewControllerAnimated:NO];
        }
        else
        {
        }

        self.finishBlock(success, info);
    }];
}

- (void)updateSendButtonState
{
    [EBViewFactory updateCountButton:_goButton count:_selectedSet.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
