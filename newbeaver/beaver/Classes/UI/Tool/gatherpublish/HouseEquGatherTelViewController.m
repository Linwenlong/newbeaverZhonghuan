//
//  HouseEquGatherTelViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseEquGatherTelViewController.h"
#import "EBListView.h"
#import "HouseDataSource.h"
#import "EBHttpClient.h"
#import "EBGatherHouse.h"

@interface HouseEquGatherTelViewController ()
{
    EBListView *_listView;
}

@end

@implementation HouseEquGatherTelViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"gather_house_tel_repeat_list_title", nil);
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [self.view addSubview:_listView];
    HouseDataSource *ds = [[HouseDataSource alloc] init];
    ds.pageSize = 30;
    __weak HouseEquGatherTelViewController *weakSelf = self;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *paraNew = [[NSMutableDictionary alloc] init];
        [paraNew setDictionary:params];
        paraNew[@"keyword_type"] = @"tel";
        paraNew[@"keyword"] = weakSelf.house.owner_tel;
        paraNew[@"type"] = weakSelf.house.type == EGatherHouseRentalTypeSale ? @"sale" : @"rent";
        [[EBHttpClient sharedInstance] houseRequest:paraNew filter:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _listView.dataSource = ds;
    _listView.emptyText = @"没有重复电话号码的房源";
    [_listView startLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
