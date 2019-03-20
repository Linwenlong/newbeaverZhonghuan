//
//  PublishHouseRecordViewController.m
//  beaver
//
//  Created by wangyuliang on 14-9-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PublishHouseRecordViewController.h"
#import "EBListView.h"
#import "EBHttpClient.h"
#import "PublishHouseDataSource.h"
#import "EBViewPager.h"
#import "EBViewFactory.h"

@interface PublishHouseRecordViewController () <EBViewPagerDelegate>
{
    NSMutableArray *_saleArray;
    NSMutableArray *_rentArray;
    
    EBListView *_saleListView;
    EBListView *_rentListView;
}

@end

@implementation PublishHouseRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"gp_published", nil);
    [self setupPagingScrollView];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_saleListView startLoading];
    if (_rentListView.loadInitialed)
    {
        [_rentListView refreshList:NO];
    }
}

- (void)setupPagingScrollView
{
    UIScrollView *scrollView = [EBViewFactory pagerScrollView:NO];
    scrollView.scrollsToTop = NO;
    [self.view addSubview:scrollView];
    CGRect contentFrame = scrollView.bounds;
    
    _saleListView = [[EBListView alloc] initWithFrame:contentFrame];
    _saleListView.tableView.scrollsToTop = YES;
    PublishHouseDataSource *dsSale = [[PublishHouseDataSource alloc] init];
    dsSale.pageSize = 30;
    dsSale.showItemType = EPublishHouseItemRecord;
    __weak PublishHouseDataSource *weakDsSale = dsSale;
    dsSale.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *paraNew = [[NSMutableDictionary alloc] init];
        [paraNew setDictionary:params];
//        paraNew[@"ordered"] = @1;
        paraNew[@"type"] = @"sale";
        [[EBHttpClient sharedInstance] gatherPublishRequest:paraNew publishTaskList:^(BOOL success, id result) {
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_READ object:nil]];
            NSArray *array = result[@"data"];
            done(success, array);
            [weakDsSale createTouchTag];
        }];
    };
    dsSale.refreshBlock = ^(BOOL refresh)
    {
        [_saleListView refreshList:refresh];
    };
    _saleListView.dataSource = dsSale;
    [scrollView addSubview:_saleListView];
    _saleListView.emptyText = NSLocalizedString(@"publish_house_empty", nil);
    contentFrame.origin.x += contentFrame.size.width;
    
    _rentListView = [[EBListView alloc] initWithFrame:contentFrame];
    _rentListView.tableView.scrollsToTop = NO;
    PublishHouseDataSource *dsRent = [[PublishHouseDataSource alloc] init];
    dsRent.pageSize = 30;
    dsRent.showItemType = EPublishHouseItemRecord;
    __weak PublishHouseDataSource *weakDsRent = dsRent;
    dsRent.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *paraNew = [[NSMutableDictionary alloc] init];
        [paraNew setDictionary:params];
//        paraNew[@"ordered"] = @1;
        paraNew[@"type"] = @"rent";
        [[EBHttpClient sharedInstance] gatherPublishRequest:paraNew publishTaskList:^(BOOL success, id result) {
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_READ object:nil]];
            NSArray *array = result[@"data"];
            done(success, array);
            [weakDsRent createTouchTag];
        }];
    };
    dsRent.refreshBlock = ^(BOOL refresh)
    {
        [_rentListView refreshList:refresh];
    };
    _rentListView.dataSource = dsRent;
    _rentListView.emptyText = NSLocalizedString(@"publish_house_empty", nil);
    [scrollView addSubview:_rentListView];
    
    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 2, contentFrame.size.height);
    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame] pagerTitles:@[NSLocalizedString(@"rental_house_state_2", nil), NSLocalizedString(@"rental_house_state_1", nil)] defaultPage:0];
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.scrollView = scrollView;
    scrollView.delegate = viewPager;
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
