//
//  GatherHouseListViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseListViewController.h"
#import "EBListView.h"
#import "GatherHouseDataSource.h"
#import "EBHttpClient.h"
#import "EBCondition.h"
#import "EBFilter.h"

@interface GatherHouseListViewController ()
{
    EBListView *_listView;
}

@end

@implementation GatherHouseListViewController

- (void)loadView
{
    [super loadView];
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    GatherHouseDataSource *ds = [[GatherHouseDataSource alloc] init];
    ds.filter = _filter;
    if (_listType == EGatherHouseListTypeSpecial)
    {
        [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_edit"] target:self action:@selector(editSubscription:)];
        [EBController observeNotification:NOTIFICATION_SUBSCRIPTION_DELETE from:self selector:@selector(conditionDeleted)];
        [EBController observeNotification:NOTIFICATION_SUBSCRIPTION_UPDATE from:self selector:@selector(conditionUpdated)];
        _listView.emptyText = NSLocalizedString(@"empty_subscription_house", nil);
        ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
        {
            [[EBHttpClient sharedInstance] gatherPublishRequest:params subscriptionHouseList:^(BOOL success, id result)
            {
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_READ object:nil]];
                done(success, result);
            }];
        };
    }
    _listView.dataSource = ds;
    [self.view addSubview:_listView];
    [_listView startLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_listView.loadInitialed)
    {
//        [_listView refreshList:NO];
        [_listView.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIAction Method

- (void)editSubscription:(UIButton *)btn
{
    [[EBController sharedInstance] showCustomCondition:_condition
                                            customType:ECustomConditionViewTypeGatherHouse];
}

- (void)conditionUpdated
{
    [_listView refreshList:YES];
    
    NSString *key = [NSString stringWithFormat:@"rental_house_state_%ld", _filter.requireOrRentalType];
    self.title = [NSString stringWithFormat:@"[%@] %@", NSLocalizedString(key, nil), _condition.title];
}

- (void)conditionDeleted
{
}


@end
