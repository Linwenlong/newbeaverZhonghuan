//
//  HouseInviteViewController.m
//  beaver
//
//  Created by wangyuliang on 14-5-26.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseVisitLogViewController.h"
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

#import "ClientDataSource.h"
#import "HouseVisitLogDataSource.h"

@interface HouseVisitLogViewController (){
    EBListView *_listView;
}

@end

@implementation HouseVisitLogViewController

- (void)loadView
{
    [super loadView];
    NSString *title = [NSString stringWithFormat:@"%@-%@",NSLocalizedString(@"btn_view_record", nil) , _houseDetail.contractCode];
    self.navigationItem.title = title;
    
    
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];

    HouseVisitLogDataSource *ds = [[HouseVisitLogDataSource alloc] init];
    EBFilter *filter = [[EBFilter alloc] init];
    [filter parseFromHouse:_houseDetail withDetail:NO];
    ds.filter = filter;

    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] houseRequest:params visitLogs:^(BOOL success, NSArray *result)
        {
            done(success, result);
        }];
    };
    _listView.dataSource = ds;
    _listView.emptyText = NSLocalizedString(@"empty_visit_log", nil);
    [self.view addSubview:_listView];
    [_listView startLoading];
}

@end
