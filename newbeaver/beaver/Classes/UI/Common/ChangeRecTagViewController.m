//
//  ChangeRecTagViewController.m
//  beaver
//
//  Created by ChenYing on 14-7-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ChangeRecTagViewController.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBFilter.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"

@interface ChangeRecTagViewController ()
{
    UITableView *_tableView;
    NSArray *_tagsArray;
    NSMutableSet *_selectedSet;
    BOOL _hasChanged;
    UIBarButtonItem *_saveButton;
}

@end

@implementation ChangeRecTagViewController

- (void)loadView
{
    [super loadView];
    NSString *title = NSLocalizedString(@"operation_modify_recommend_tag", nil);
    self.navigationItem.title = title;
    _saveButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(saveRecommendTag:)];
    
    EBBusinessConfig *config = [EBCache sharedInstance].businessConfig;
    if (_isClient)
    {
        _tagsArray = config.clientConfig.recommendTags[[EBFilter typeString:_client.rentalState]];
    }
    else
    {
        _tagsArray = config.houseConfig.recommendTags[[EBFilter typeString:_house.rentalState]];
    }
    _selectedSet = [[NSMutableSet alloc] initWithArray:_isClient ? _client.recommendTags : _house.recommendTags];
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    [_tableView setEditing:YES animated:NO];
    [self.view addSubview:_tableView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _saveButton.enabled = _hasChanged;
}

- (BOOL)shouldPopOnBack
{
    if (_hasChanged)
    {
        NSString *title = nil;
        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
            if (title == nil) {
                title = @"";
            }
        }
        [[[UIAlertView alloc] initWithTitle:title
                                    message:NSLocalizedString(@"alert_save_change_tag", nil)
                           cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil) action:nil]
                           otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"save", nil) action:^{
            [self saveRecommendTag:nil];
        }], [RIButtonItem itemWithLabel:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }], nil] show];
    }
    else
    {
        return YES;
    }
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tagsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:272.0f leftMargin:48.0f]];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 13.0, 237.0, 18.0)];
        nameLabel.font = [UIFont systemFontOfSize:16.0];
        nameLabel.textColor = [EBStyle blackTextColor];
        nameLabel.tag = 90;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        UIView *selectedView = [[UIView alloc] init];
        [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0 leftMargin:48.0]];
        cell.selectedBackgroundView = selectedView;
        [cell.contentView addSubview:nameLabel];
    }
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:90];
    nameLabel.text = _tagsArray[indexPath.row];
    if ([_selectedSet containsObject:_tagsArray[indexPath.row]])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    if (!_isClient && ([_tagsArray[indexPath.row] isEqualToString:NSLocalizedString(@"rec_tag_urgent", nil)] || [_tagsArray[indexPath.row] isEqualToString:NSLocalizedString(@"rec_tag_full_price", nil)]))
    {
        nameLabel.textColor = [EBStyle grayTextColor];
    }
    else
    {
        nameLabel.textColor = [EBStyle blackTextColor];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isClient && ([_tagsArray[indexPath.row] isEqualToString:NSLocalizedString(@"rec_tag_urgent", nil)] || [_tagsArray[indexPath.row] isEqualToString:NSLocalizedString(@"rec_tag_full_price", nil)]))
    {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _hasChanged = YES;
    _saveButton.enabled = _hasChanged;
    [_selectedSet addObject:_tagsArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _hasChanged = YES;
    _saveButton.enabled = _hasChanged;
    [_selectedSet removeObject:_tagsArray[indexPath.row]];
}

#pragma mark - Action Method

- (void)saveRecommendTag:(id)sender
{
    NSMutableString *tags = [[NSMutableString alloc] init];
    [_selectedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
     {
         NSString *tag = (NSString *)obj;
         [tags appendString:tag];
         [tags appendString:@";"];
     }];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"tag"] = tags.length > 0 ? [tags substringToIndex:tags.length - 1] : @"";
    if (_isClient)
    {
        parameters[@"client_id"] = _client.id;
        parameters[@"type"] =  [EBFilter typeString:_client.rentalState];
        [[EBHttpClient sharedInstance] clientRequest:parameters changeRecommendTag:^(BOOL success, id result) {
            if (success)
            {
                [EBAlert alertSuccess:nil length:1.0 allowUserInteraction:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    }
    else
    {
        parameters[@"house_id"] = _house.id;
        parameters[@"type"] =  [EBFilter typeString:_house.rentalState];
        [[EBHttpClient sharedInstance] houseRequest:parameters changeRecommendTag:^(BOOL success, id result) {
            if (success)
            {
                [EBAlert alertSuccess:nil length:1.0 allowUserInteraction:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    }
}

#pragma mark - Private Method

@end
