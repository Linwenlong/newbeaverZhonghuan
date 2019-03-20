//
//  ClientFollowLogViewController.m
//  beaver
//
//  Created by wangyuliang on 14-6-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientFollowLogViewController.h"
#import "EBListView.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "HouseListViewController.h"
#import "EBListView.h"
#import "HouseDataSource.h"
#import "EBFilter.h"
#import "EBHttpClient.h"
#import "CustomConditionViewController.h"
#import "EBCondition.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "InputOrScanViewController.h"
#import "EBAlert.h"
#import "SnsViewController.h"
#import "ClientFollowLogDataSource.h"
#import "EBClientFollowLog.h"
#import "EBAudioPlayer.h"
#import "CustomIOS7AlertView.h"
#import "AddFollowLogViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface ClientFollowLogViewController () <UITextViewDelegate>
{
    EBListView *_listView;
    UITextView *_note;
    UITextView *_noteAbnormal;
    UILabel *_placeholder;
    UILabel *_placeholderAbnormal;
    CustomIOS7AlertView *_alertView;
    CustomIOS7AlertView *_alertViewAbnormal;
}

@end

@implementation ClientFollowLogViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"btn_track_record", nil);
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _listView.isSelecting = NO;
    
    ClientFollowLogDataSource *ds = [[ClientFollowLogDataSource alloc] init];
    ds.curPlayingRow = -1;
    ds.pageSize = 30;
    __weak ClientFollowLogViewController *weakSelf = self;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        ClientFollowLogViewController *strongSelf = weakSelf;
        [[EBHttpClient sharedInstance] clientRequest:@{@"type": [EBFilter typeString:strongSelf.clientDetail.rentalState],@"client_id":strongSelf.clientDetail.id} follow:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _listView.dataSource = ds;
    _listView.emptyText = NSLocalizedString(@"empty_follow_client", nil);
    [self.view addSubview:_listView];
    [_listView startLoading];
    if (_clientDetail.follow)
    {
        [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addFollowLog:)];
    }
}

- (void)addFollowLog:(UIButton*)btn
{
    [EBTrack event:EVENT_CLICK_CLIENT_VIEW_GJ_LIST_ADD];
    AddFollowLogViewController *viewController = [[AddFollowLogViewController alloc] init];
    viewController.complete = ^(){
        [_listView refreshList:YES];
    };
    viewController.isHouse = NO;
    viewController.client = _clientDetail;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[EBAudioPlayer sharedInstance] stopPlaying];
    [_listView refreshList:YES];
}

//-(void)dealloc
//{
//    
//}

@end
