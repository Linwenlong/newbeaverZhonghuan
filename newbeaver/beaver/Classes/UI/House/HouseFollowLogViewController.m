//
//  HouseFollowLogViewController.m
//  beaver
//
//  Created by wangyuliang on 14-6-23.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseFollowLogViewController.h"
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
#import "HouseFollowLogDataSource.h"
#import "EBHouseFollowLog.h"
#import "EBAudioPlayer.h"
#import "CustomIOS7AlertView.h"
#import "AddFollowLogViewController.h"
#import "EBFollowLogAddView.h"
#import "HousePhotoPreUploadViewController.h"

@interface HouseFollowLogViewController () <UITextViewDelegate>
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

@implementation HouseFollowLogViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"btn_track_record", nil);
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _listView.isSelecting = NO;
    
    HouseFollowLogDataSource *ds = [[HouseFollowLogDataSource alloc] init];
    ds.curPlayingRow = -1;
    ds.pageSize = 30;
    __weak HouseFollowLogViewController *weakSelf = self;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        HouseFollowLogViewController *strongSelf = weakSelf;
        [[EBHttpClient sharedInstance] houseRequest:@{@"type": [EBFilter typeString:strongSelf.houseDetail.rentalState],@"house_id":strongSelf.houseDetail.id} follow:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _listView.dataSource = ds;
    _listView.emptyText = NSLocalizedString(@"empty_follow_house", nil);
    [self.view addSubview:_listView];
    [_listView startLoading];
    if (_houseDetail.follow)
    {
        [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addFollowLog:)];
    }
}

- (void)addFollowLog:(UIButton*)btn
{
    [EBTrack event:EVENT_CLICK_HOUSE_MARKED_GJ_LIST_ADD];
    AddFollowLogViewController *viewController = [[AddFollowLogViewController alloc] init];
    viewController.isHouse = YES;
    viewController.house = _houseDetail;
    viewController.complete = ^(){
        [_listView refreshList:YES];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[EBAudioPlayer sharedInstance] stopPlaying];
    [_listView refreshList:YES];
}


@end
