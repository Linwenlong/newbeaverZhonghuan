//
//  GatherHouseViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseViewController.h"
#import "EBListView.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "GatherHouseDataSource.h"

#define GATHER_HOUSE_SCROLL_VIEW_TAG 111
#define GATHER_HOUSE_LISTVIEW_BASE_TAG 888

@interface GatherHouseViewController ()
{
    EBListView *_saleListView;
    EBListView *_rentListView;
}

@end

@implementation GatherHouseViewController

- (void)loadView
{
    [super loadView];
    [self setupPagingScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_saleListView.loadInitialed)
    {
//        [_saleListView refreshList:YES];
        [_saleListView.tableView reloadData];
    }
    if (_rentListView.loadInitialed)
    {
//        [_rentListView refreshList:YES];
        [_rentListView.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDelegate

- (void)switchToPageIndex:(NSInteger) page
{
    EBListView *listView = (EBListView *)[[self.view viewWithTag:GATHER_HOUSE_SCROLL_VIEW_TAG] viewWithTag:page + 1 + GATHER_HOUSE_LISTVIEW_BASE_TAG];
    if (!listView.loadInitialed)
    {
        [listView startLoading];
    }
    _saleListView.tableView.scrollsToTop = page == 0;
    _rentListView.tableView.scrollsToTop = page == 1;
}

#pragma mark - Private Method

- (void)setupPagingScrollView
{
    UIScrollView *scrollView = [EBViewFactory pagerScrollView:NO];
    scrollView.scrollsToTop = NO;
    scrollView.tag = GATHER_HOUSE_SCROLL_VIEW_TAG;
    [self.view addSubview:scrollView];
    
    CGRect contentFrame = scrollView.bounds;
    
    _saleListView = [[EBListView alloc] initWithFrame:contentFrame];
    _saleListView.tableView.scrollsToTop = YES;
    GatherHouseDataSource *dsSale = [[GatherHouseDataSource alloc] init];
    dsSale.pageSize = 20;
    dsSale.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:params];
        temp[@"type"] = @"sale";
        [[EBHttpClient sharedInstance] gatherPublishRequest:temp houseList:^(BOOL success, id result)
        {
            done(success, result);
        }];
    };
    _saleListView.dataSource = dsSale;
    _saleListView.emptyText = NSLocalizedString(@"empty_gather_house", nil);
    _saleListView.tag = GATHER_HOUSE_LISTVIEW_BASE_TAG + 1;
    [scrollView addSubview:_saleListView];
    contentFrame.origin.x += contentFrame.size.width;
    
    _rentListView = [[EBListView alloc] initWithFrame:contentFrame];
    _rentListView.tableView.scrollsToTop = NO;
    GatherHouseDataSource *dsRent = [[GatherHouseDataSource alloc] init];
    dsRent.pageSize = 20;
    dsRent.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:params];
        temp[@"type"] = @"rent";
        [[EBHttpClient sharedInstance] gatherPublishRequest:temp houseList:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _rentListView.dataSource = dsRent;
    _rentListView.emptyText = NSLocalizedString(@"empty_gather_house", nil);
    _rentListView.tag = GATHER_HOUSE_LISTVIEW_BASE_TAG + 2;
    [scrollView addSubview:_rentListView];
   
    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 2, contentFrame.size.height);
    //Add view pager.
    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame]
                                                    pagerTitles:@[NSLocalizedString(@"rental_house_state_2", nil),NSLocalizedString(@"rental_house_state_1", nil)] defaultPage:0];
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.scrollView = scrollView;
    scrollView.delegate = viewPager;
}

- (void)refreshGatherHouse
{
    if (_saleListView.loadInitialed)
    {
        [_saleListView refreshList:YES];
    }
    if (_rentListView.loadInitialed)
    {
        [_rentListView refreshList:YES];
    }
}

@end
