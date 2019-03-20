//
//  HouseListViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientListViewController.h"
#import "EBListView.h"
#import "ClientDataSource.h"
#import "EBFilter.h"
#import "EBController.h"
#import "EBClient.h"
#import "EBHttpClient.h"
#import "EBHouse.h"
#import "InputOrScanViewController.h"
#import "EBAlert.h"
#import "ClientTelListViewController.h"
#import "EBShare.h"

@interface ClientListViewController ()
{
    EBListView *_listView;
}

@property (nonatomic, strong) UIButton *sortButton;

@end

@implementation ClientListViewController

- (void)loadView
{
    [super loadView];

    NSLog(@"appParam=%@",_appParam);
    
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    ClientDataSource *ds = [[ClientDataSource alloc] init];
//    ds.marking = YES;
    ds.filter = _filter;

    _listView.withFilter = YES;

    if (_listType != EClientListTypeCollected && _listType != EClientListTypeRecent)
    {
        _sortButton = [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_sort"]
                                                    target:self
                                                    action:@selector(showSort:)];
        _sortButton.enabled = NO;
    }
    if (_listType == EClientListTypeMarkedClientsForHouse || _listType == EClientListTypeMatchClientsForHouse
            || _listType == EClientListTypeRecommendClientsForHouse || _listType == EClientListTypeForShare)
    {
        ds.marking = YES;
        ds.changeMarkedStausBlock = ^(BOOL marked)
        {
            EBHouse *house = [_houses firstObject];
            house.marked = marked;
        };
        _listView.isSelecting = YES;
        [_listView enableFooterButton:NSLocalizedString(@"recommend_via_sms", nil) target:self action:@selector(shareToClients:)];
        if (_listType == EClientListTypeMarkedClientsForHouse)
        {
            _listView.emptyText = NSLocalizedString(@"empty_mark_client", nil);
            _listView.withFilter = NO;
            [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addClient:)];
            ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                [[EBHttpClient sharedInstance] houseRequest:params markedClients:^(BOOL success, id result)
                {
                    done(success, result);
                }];
            };
        }
        else if (_listType == EClientListTypeMatchClientsForHouse)
        {
            _listView.emptyText = NSLocalizedString(@"empty_match_client", nil);
            [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addClient:)];
            ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                [[EBHttpClient sharedInstance] houseRequest:params matchClients:^(BOOL success, id result)
                {
                    done(success, result);
                }];
            };
        }
        else if (_listType == EClientListTypeRecommendClientsForHouse)
        {
            _listView.emptyText = NSLocalizedString(@"empty_recommend_client", nil);
            _listView.withFilter = NO;
            ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                [[EBHttpClient sharedInstance] houseRequest:params recommendedClients:^(BOOL success, id result)
                {
                    done(success, result);
                }];
            };
        }
        else if (_listType == EClientListTypeForShare)
        {
            _listView.emptyText = NSLocalizedString(@"empty_share_client", nil);
            [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addClient:)];

            if (_filter.houseId)
            {
                ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
                {
                    [[EBHttpClient sharedInstance] houseRequest:params matchClients:^(BOOL success, id result)
                    {
                        done(success, result);
                    }];
                };
            }
            else
            {
                ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
                {
                    [[EBHttpClient sharedInstance] clientRequest:params filter:^(BOOL success, id result)
                    {
                        done(success, result);
                    }];
                };
            }
        }

        ds.clickBlock = ^(EBClient *client)
        {

           [[EBController sharedInstance] recommendHouses:self.houses toClient:client
                                               completion:^(BOOL success, NSDictionary *info){
               if (success)
               {
                   [EBAlert alertSuccess:nil];
               }
               else
               {
                   [EBAlert alertError:NSLocalizedString(info[@"desc"], nil)];
               }
           }];
        };
    }
    else
    {
        ds.requestBlock =  ^(NSDictionary *params, void(^done)(BOOL, id))
        {
            NSMutableDictionary *temp = [params mutableCopy];
            if (self.appParam) {
                [temp addEntriesFromDictionary:self.appParam];
                params = [temp copy];
            }
            [[EBHttpClient sharedInstance] clientRequest:params filter:^(BOOL success, id result)
            {
                done(success, result);
            }];
        };

        if (_listType == EClientListTypeSearch)
        {
            _listView.emptyText = NSLocalizedString(@"empty_search_client", nil);
            _listView.withFilter = NO;
            _listView.isSearch = YES;
            if (self.handleSelections)
            {
                _listView.isSelecting = YES;
                [_listView enableFooterButton:NSLocalizedString(@"finish_selection", nil) target:self action:@selector(finishSelection:)];
            }
        }
        else if (_listType == EClientListTypeRecent)
        {
            _listView.withFilter = NO;
            _listView.emptyText = NSLocalizedString(@"empty_recent_client", nil);
            if (self.handleSelections)
            {
                _listView.isSelecting = YES;
                [_listView enableFooterButton:NSLocalizedString(@"finish_selection", nil) target:self action:@selector(finishSelection:)];
            }
            ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                NSMutableDictionary *temp = [params mutableCopy];
                if (self.appParam) {
                    [temp addEntriesFromDictionary:self.appParam];
                    params = [temp copy];
                }
//                [[EBHttpClient sharedInstance] clientRequest:params recentViewed:^(BOOL success, id result)
//                 {
//                     done(success, result);
//                 }];
                [[EBHttpClient sharedInstance] clientRequest:params filter:^(BOOL success, id result) {
                    done(success, result);
                }];
            };
        }
        else if (_listType == EClientListTypeCollected)
        {
            _listView.withFilter = NO;
            _listView.emptyText = NSLocalizedString(@"empty_collected_client", nil);
            if (self.handleSelections)
            {
                _listView.isSelecting = YES;
                [_listView enableFooterButton:NSLocalizedString(@"finish_selection", nil) target:self action:@selector(finishSelection:)];
            }
            ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
            {
                NSMutableDictionary *temp = [params mutableCopy];
                temp[@"collect"] = @1;
                params = [temp copy];
                [[EBHttpClient sharedInstance] clientRequest:params collect:^(BOOL success, id result)
                 {
                     done(success, result);
                 }];
            };
        }
        else
        {
            _listView.emptyText = NSLocalizedString(@"empty_filter_client", nil);
        }
    }

    __block ClientListViewController *cl = self;
    __block EBListView *hlList = _listView;
    _listView.listStateListener = ^(EEBListViewState state)
    {
        if (state == EEBListViewStateInit
                || state == EEBListViewStateLoadingError
                || state == EEBListViewStateReloading)
        {
            cl.sortButton.enabled = NO;
        }
        else if (state == EEBListViewStateLoadingSuccess)
        {
            cl.sortButton.enabled = hlList.dataSource.dataArray.count >= 2;
//            cl.rightButtonsHidden = hlList.dataSource.dataArray.count < 2;
        }
    };
    _listView.dataSource = ds;
    [self.view addSubview:_listView];
    [_listView startLoading];

    [EBController observeNotification:NOTIFICATION_RECEIVE_REMINDER from:self selector:@selector(didReceiveReminder:)];
}

- (void)addClient:(UIButton *)btn
{
    EBHouse *house = [_houses firstObject];
    NSArray *filter = @[@"client", [EBFilter typeString:house.rentalState]];
    InputOrScanViewController * inputOrScanViewController =
    [[EBController sharedInstance] showInputWithFilter:filter completion:^(NSDictionary *result)
    {
        EBClient *client = result[@"data"];
        client.marked = YES;
        house.marked = YES;

        if (![_listView addAndSelectItem:client])
        {
            [EBAlert alertSuccess:NSLocalizedString(@"qr_client_added_already", nil)];
        }
        else
        {
            if (self.listType == EClientListTypeMarkedClientsForHouse)
            {
                [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":client.id,
                        @"house_id":_filter.houseId, @"type": [EBFilter typeString:client.rentalState]}
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RECEIVE_REMINDER object:nil];
}

- (void)shareToClients:(UIButton *)btn
{
    NSArray *clients = [_listView.dataSource.selectedSet allObjects];
    NSMutableArray *clientIds = [[NSMutableArray alloc] init];

    [clients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        EBClient *client = obj;
        [clientIds addObject:client.id];
    }];

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"type"] = [EBFilter typeString:[_filter requireOrRentalType]];
    parameters[@"ids"] = [clientIds componentsJoinedByString:@";"];

    [EBAlert showLoading:nil];
    [[EBHttpClient sharedInstance] clientRequest:parameters telList:^(BOOL success, id result)
    {
        [EBAlert hideLoading];
         if (success)
         {
             ClientTelListViewController *viewController = [[ClientTelListViewController alloc] init];

             if (self.userInfo)
             {
                 viewController.userInfo = self.userInfo;
             }
             else
             {
                 NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
                 content[@"key"] = [EBShare contentShareKey];
                 content[@"text"] = [EBShare smsContentForHouses:self.houses];
                 content[@"url"] = [EBShare contentShareUrl:content[@"key"]];
                 viewController.userInfo = content;

                 [EBShare setShareHouses:self.houses forKey:content[@"key"]];
             }

             viewController.clientList = result;
             [self.navigationController pushViewController:viewController animated:YES];
             viewController.finishBlock = ^(BOOL success, NSDictionary *info)
             {
                if (success)
                {
//                    [self.navigationController popViewControllerAnimated:YES];
                    [EBAlert alertSuccess:nil];

                    EBHouse *firstHouse = [self.houses firstObject];
                    NSMutableArray *houseIds = [[NSMutableArray alloc] init];
                    [self.houses enumerateObjectsUsingBlock:^(EBHouse * house, NSUInteger idx, BOOL *stop)
                    {
                        [houseIds addObject:house.id];
                    }];

                    [[EBHttpClient sharedInstance] clientRequest:@{@"house_ids":[houseIds componentsJoinedByString:@";"],
                            @"client_id":parameters[@"ids"],
                            @"type": [EBFilter typeString:firstHouse.rentalState]}
                                                       recommend:^(BOOL success, id result)
                                                       {
                                                           EBHouse *house = [_houses firstObject];
                                                           house.recommended = YES;
                                                       }];
                }
                else
                {
                    if ([info[@"desc"] rangeOfString:@"canceled"].location == NSNotFound)
                    {
                        [EBAlert alertError:NSLocalizedString(info[@"desc"], nil)];
                        
                    }
                }
             };
         }
    }];
}

- (void)showSort:(UIButton *)btn
{
    [_listView toggleSortView];
}

- (void)finishSelection:(UIButton *)btn
{
    self.handleSelections([_listView.dataSource.selectedSet sortedArrayUsingDescriptors:nil]);
}

- (BOOL)shouldPopOnBack
{
    return ![_listView dismissPopUpView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveReminder:(NSNotification *)notification
{
    [_listView showReminder:notification.object];
}

@end
