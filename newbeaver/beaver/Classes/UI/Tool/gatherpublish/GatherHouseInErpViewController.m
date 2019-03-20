//
//  GatherHouseInErpViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-29.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseInErpViewController.h"
#import "EBListView.h"
#import "HouseDataSource.h"
#import "EBHttpClient.h"
#import "EBViewFactory.h"
#import "EBViewPager.h"

@interface GatherHouseInErpViewController () <EBViewPagerDelegate>
{
    EBListView *_saleListView;
    EBListView *_rentListView;
}

@end

@implementation GatherHouseInErpViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"gp_inputed_erp", nil);
    [self setupPagingScrollView];
//    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
//    [self.view addSubview:_listView];
//    HouseDataSource *ds = [[HouseDataSource alloc] init];
//    ds.pageSize = 30;
//    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
//    {
//        NSMutableDictionary *paraNew = [[NSMutableDictionary alloc] init];
//        [paraNew setDictionary:params];
//        paraNew[@"if_media"] = @"1";
//        paraNew[@"type"] = @"sale";
//        [[EBHttpClient sharedInstance] houseRequest:paraNew filter:^(BOOL success, id result)
//         {
//             done(success, result);
//         }];
//    };
//    _listView.dataSource = ds;
//    _listView.emptyText = NSLocalizedString(@"gather_house_erp_list_empty", nil);
//    [_listView startLoading];
}

- (void)setupPagingScrollView
{
    UIScrollView *scrollView = [EBViewFactory pagerScrollView:NO];
    scrollView.scrollsToTop = NO;
    [self.view addSubview:scrollView];
    CGRect contentFrame = scrollView.bounds;
    
    _saleListView = [[EBListView alloc] initWithFrame:contentFrame];
    _saleListView.tableView.scrollsToTop = YES;
    HouseDataSource *dsSale = [[HouseDataSource alloc] init];
    dsSale.pageSize = 30;
    dsSale.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *paraNew = [[NSMutableDictionary alloc] init];
        [paraNew setDictionary:params];
        paraNew[@"if_media"] = @1;
        paraNew[@"type"] = @"sale";
        [[EBHttpClient sharedInstance] houseRequest:paraNew filter:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _saleListView.dataSource = dsSale;
    [scrollView addSubview:_saleListView];
    _saleListView.emptyText = NSLocalizedString(@"gather_house_erp_list_empty", nil);
    contentFrame.origin.x += contentFrame.size.width;
    
    _rentListView = [[EBListView alloc] initWithFrame:contentFrame];
    _rentListView.tableView.scrollsToTop = NO;
    HouseDataSource *dsRent = [[HouseDataSource alloc] init];
    dsRent.pageSize = 30;
    dsRent.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *paraNew = [[NSMutableDictionary alloc] init];
        [paraNew setDictionary:params];
        paraNew[@"if_media"] = @1;
        paraNew[@"type"] = @"rent";
        [[EBHttpClient sharedInstance] houseRequest:paraNew filter:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _rentListView.dataSource = dsRent;
    _rentListView.emptyText = NSLocalizedString(@"gather_house_erp_list_empty", nil);
    [scrollView addSubview:_rentListView];
    
    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 2, contentFrame.size.height);
    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame] pagerTitles:@[NSLocalizedString(@"rental_house_state_2", nil), NSLocalizedString(@"rental_house_state_1", nil)] defaultPage:0];
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.scrollView = scrollView;
    scrollView.delegate = viewPager;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_saleListView startLoading];
    if (_rentListView.loadInitialed)
    {
        [_rentListView refreshList:NO];
    }
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

#pragma mark - ViewPagerDelegate
- (void) switchToPageIndex:(NSInteger) page
{
    if (page == 0)
    {
        if (!_saleListView.loadInitialed)
        {
            [_saleListView startLoading];
        }
    }
    if (page == 1)
    {
        if (!_rentListView.loadInitialed)
        {
            [_rentListView startLoading];
        }
    }
    _saleListView.tableView.scrollsToTop = page == 0;
    _rentListView.tableView.scrollsToTop = page == 1;
}


@end
