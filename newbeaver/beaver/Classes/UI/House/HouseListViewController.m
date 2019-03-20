//
//  HouseListViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseListViewController.h"
#import "EBListView.h"
#import "HouseDataSource.h"
#import "EBFilter.h"
#import "EBHttpClient.h"
#import "EBCondition.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "InputOrScanViewController.h"
#import "EBAlert.h"
#import "SnsViewController.h"

@interface HouseListViewController ()
{
    EBListView *_listView;
}

@property (nonatomic, strong) UIButton *sortButton;

@end

@implementation HouseListViewController

- (void)loadView
{
   [super loadView];

    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    HouseDataSource *ds = [[HouseDataSource alloc] init];
//    ds.marking = YES;
    ds.filter = _filter;

    _listView.isSelecting = YES;
    if (_listType == EHouseListTypeSpecialCustom || _listType == EHouseListTypeSpecial)
    {
        if (_listType == EHouseListTypeSpecialCustom)
        {
            [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_edit"] target:self action:@selector(editCustomCondition:)];
            [EBController observeNotification:NOTIFICATION_CONDITION_DELETE from:self selector:@selector(conditionDeleted)];
            [EBController observeNotification:NOTIFICATION_CONDITION_UPDATE from:self selector:@selector(conditionUpdated)];
        }
    }
    else if (_listType != EHouseListTypeInvited){ //邀请
        _listView.withFilter = YES;
        #pragma mark -- 最新房源
        if (_listType != EHouseListTypeRecent)
        {
            //排序按钮
            _sortButton = [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_sort"] target:self action:@selector(showSort:)];
            _sortButton.enabled = NO;
        }
        if (_listType == EHouseListTypeMarkedHousesForClient || _listType == EHouseListTypeMatchHousesForClient || _listType == EHouseListTypeRecommendedHousesForClient)
        {
            ds.marking = YES;
            ds.changeMarkedStausBlock = ^(BOOL marked)
            {
                _client.marked = marked;
            };
            if (_listType != EHouseListTypeRecommendedHousesForClient)
            {
                [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addHouse:)];
            }
        }
    }

    // api and button
    if (_listType == EHouseListTypeMarkedHousesForClient || _listType == EHouseListTypeMatchHousesForClient)
    {
        if (!self.handleSelections)
        {
            [_listView enableFooterButton:NSLocalizedString(@"send_recommend", nil) target:self action:@selector(recommend:)];
        }
        if (_listType == EHouseListTypeMarkedHousesForClient)
        {
            _listView.emptyText = NSLocalizedString(@"empty_mark_house", nil);
            _listView.withFilter = NO;
            ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                [[EBHttpClient sharedInstance] clientRequest:params markedHouses:^(BOOL success, id result)
                {
                    done(success, result);
                }];
            };
        }
        else if (_listType == EHouseListTypeMatchHousesForClient)
        {
            _listView.emptyText = NSLocalizedString(@"empty_match_house", nil);
            ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                [[EBHttpClient sharedInstance] clientRequest:params matchHouses:^(BOOL success, id result)
                {
                    done(success, result);
                }];
            };
        }
    }
    else if (_listType == EHouseListTypeRecommendedHousesForClient)
    {
        _listView.withFilter = NO;
        _listView.emptyText = NSLocalizedString(@"empty_recommend_house", nil);
        if (!self.handleSelections)
        {
            [_listView enableFooterButton:NSLocalizedString(@"send_recommend_again", nil) target:self action:@selector(recommend:)];
        }
        ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
        {
            [[EBHttpClient sharedInstance] clientRequest:params recommendedHouses:^(BOOL success, id result)
            {
                done(success, result);
            }];
        };
    }
    else if (_listType == EHouseListTypeRecent) //最新房源
    {
        _listView.withFilter = NO;
        _listView.emptyText = NSLocalizedString(@"empty_recent_house", nil);
        ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
        {
            //houseRequest 房子请求
            
            [[EBHttpClient sharedInstance] houseRequest:params recentViewed:^(BOOL success, id result)
            {
                NSLog(@"ds = %@",result);
                done(success, result);
            }];
        };
    }
    else if (_listType == EHouseListTypeInvited)
    {
        _listView.withFilter = NO;
        ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
        {
            [[EBHttpClient sharedInstance] houseRequest:params appointmentHouse:^(BOOL success, id result)
            {
                done(success, result);
            }];
        };
        _listView.emptyText = NSLocalizedString(@"empty_invited_house", nil);
    }
    else
    {

        if (_isLWL == YES) {
            _listView.withFilter = NO;
            
        }
        if (_is_hidden_sort_btn == YES) {
            _sortButton.hidden = YES;
        }
        
        if (!self.handleSelections)
        {
            [_listView enableFooterButton:NSLocalizedString(@"spread", nil) target:self action:@selector(share:)];
        }
        __weak typeof(self) weakSelf = self;
        ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
        {
            __strong typeof(weakSelf) safeSelf = weakSelf;
            if (safeSelf.appParam) {
                NSMutableDictionary *temp = [params mutableCopy];
                [temp addEntriesFromDictionary:self.appParam];
                NSLog(@"tmp = %@",temp);
                params = [temp copy];
            }
            
            if (_filter.communitiesIds){
                NSMutableDictionary *tempCommunitied = [params mutableCopy];
                [tempCommunitied addEntriesFromDictionary:self.appParam];
                [tempCommunitied setObject:_filter.communitiesIds forKey:@"community_id"];
                params = [tempCommunitied copy];
            }
            if (_filter.floorMinAndfloorMaxWithhouserType) {
                NSMutableDictionary *dic = [params mutableCopy];
                [dic addEntriesFromDictionary:_filter.floorMinAndfloorMaxWithhouserType];
                params = [dic copy];
            }
   
            if (_filter.block) {
                NSMutableDictionary *block = [params mutableCopy];
                [block addEntriesFromDictionary:self.appParam];
                [block setObject:_filter.block forKey:@"block"];
                params = [block copy];
            }
            
            if (_filter.unit_name) {
                NSMutableDictionary *unit_name = [params mutableCopy];
                [unit_name addEntriesFromDictionary:self.appParam];
                [unit_name setObject:_filter.unit_name forKey:@"unit_name"];
                params = [unit_name copy];
            }
            
            if (_filter.room_code) {
                NSMutableDictionary *room_code = [params mutableCopy];
                [room_code addEntriesFromDictionary:self.appParam];
                [room_code setObject:_filter.room_code forKey:@"room_code"];
                params = [room_code copy];
            }
            
            if (_filter.status == 0) {
                NSMutableDictionary *status = [params mutableCopy];
                [status addEntriesFromDictionary:self.appParam];
                [status setObject:@"有效" forKey:@"house_status"];
                params = [status copy];
            }else if (_filter.status == 1){
                NSMutableDictionary *status = [params mutableCopy];
                if ([status.allKeys containsObject:@"house_status"]) {
                    [status removeObjectForKey:@"house_status"];
                }
                params = [status copy];
            }
            
            [[EBHttpClient sharedInstance] houseRequest:params filter:^(BOOL success, id result)
            {
                done(success, result);
            }];
        };
        if (_listType == EHouseListTypeSearch)
        {
            _listView.withFilter = NO;
            _listView.isSearch = YES;
            _listView.emptyText = NSLocalizedString(@"empty_search_house", nil);
        }
        else
        {
            _listView.emptyText = NSLocalizedString(@"empty_filter_house", nil);
        }
    }

    if (_listType != EHouseListTypeSpecialCustom && _listType != EHouseListTypeInvited)
    {
        __weak __block HouseListViewController *hl = self;
        __weak __block EBListView *hlList = _listView;
        _listView.listStateListener = ^(EEBListViewState state)
        {
            HouseListViewController *strongSelf = hl;
            EBListView *strongList = hlList;
            if (state == EEBListViewStateInit
                    || state == EEBListViewStateLoadingError
                    || state == EEBListViewStateReloading)
            {
                strongSelf.sortButton.enabled = NO;
            }
            else if (state == EEBListViewStateLoadingSuccess)
            {
                strongSelf.sortButton.enabled = strongList.dataSource.dataArray.count >= 2;
            }
        };
    }

    if (self.handleSelections)
    {
        [_listView enableFooterButton:NSLocalizedString(@"finish_selection", nil) target:self action:@selector(finishSelection:)];
    }

    _listView.dataSource = ds;
//    NSLog(@"ds = %@",ds);
    [self.view addSubview:_listView];
    [_listView startLoading];

    [EBController observeNotification:NOTIFICATION_RECEIVE_REMINDER from:self selector:@selector(didReceiveReminder:)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCondition:(EBCondition *)condition
{
    _condition = condition;
    _filter = _condition.filter;
    _listView.dataSource.filter = _filter;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveReminder:(NSNotification *)notification
{
    [_listView showReminder:notification.object];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldPopOnBack
{
    return ![_listView dismissPopUpView];
}

- (void)share:(UIButton *)btn
{
   NSArray *houses = [_listView.dataSource.selectedSet allObjects];
   SnsViewController *viewController = [[EBController sharedInstance] shareHouses:houses handler:^(BOOL success, NSDictionary *info){
        if (success)
        {
            [EBAlert alertSuccess:nil];
        }
        else
        {
            if ([info[@"desc"] rangeOfString:@"canceled"].location == NSNotFound)
            {
                [EBAlert alertError:NSLocalizedString(info[@"desc"], nil)];
            }

        }
    }];
    viewController.isShowList = YES;

    if (houses.count == 1)
    {
        EBFilter *filter = [[EBFilter alloc] init];
        [filter parseFromHouse:[houses firstObject] withDetail:YES];

        viewController.extraInfo = filter;
    }
    else
    {
        EBFilter *filter = [_filter copy];
        filter.keyword = nil;
        viewController.extraInfo = filter;
    }
}

- (void)recommend:(UIButton *)btn
{
    [[EBController sharedInstance] recommendHouses:[_listView.dataSource.selectedSet sortedArrayUsingDescriptors:nil]
                                          toClient:_client  completion:^(BOOL success, NSDictionary *info)
    {

    }];
}

#pragma mark -- 确定选择
- (void)finishSelection:(UIButton *)btn
{
    self.handleSelections([_listView.dataSource.selectedSet sortedArrayUsingDescriptors:nil]);
}

- (void)addHouse:(UIButton *)btn
{
    NSArray *filter = @[@"house", [EBFilter typeString:_client.rentalState]];
    InputOrScanViewController * inputOrScanViewController =
            [[EBController sharedInstance] showInputWithFilter:filter completion:^(NSDictionary *result)
            {
                EBHouse *house = result[@"data"];
                house.marked = YES;
                _client.marked = YES;
                if (![_listView addAndSelectItem:house])
                {
                    [EBAlert alertSuccess:NSLocalizedString(@"qr_house_added_already", nil)];
                }
                else
                {
                    if (self.listType == EHouseListTypeMarkedHousesForClient)
                    {
                        [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_filter.clientId,
                                @"house_id":house.id, @"type": [EBFilter typeString:house.rentalState]}
                                                           markState:NO toggleMark:^(BOOL success, id result)
                        {
                            if (success)
                            {
                                [_listView.tableView reloadData];
                            }
                        }];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];

    [self.navigationController pushViewController:inputOrScanViewController animated:YES];
}

- (void)showSort:(UIButton *)btn
{
    [_listView toggleSortView];
}

- (void)editCustomCondition:(UIButton *)btn
{
//    [_listView toggleSortView];
    [EBTrack event:EVENT_CLICK_EDIT_FEATURED_HOUSE_FILTER];
    [[EBController sharedInstance] showCustomCondition:_condition customType:ECustomConditionViewTypeHouse];
}

- (void)conditionUpdated
{
    [_listView refreshList:YES];
}

- (void)conditionDeleted
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
