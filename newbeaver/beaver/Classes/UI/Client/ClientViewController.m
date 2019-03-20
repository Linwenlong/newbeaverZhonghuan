//
//  ClientViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientViewController.h"
#import "EBViewPager.h"
#import "EBViewFactory.h"
#import "EBFilterView.h"
#import "EBListView.h"
#import "ClientDataSource.h"
#import "ClientDataSourceInvite.h"
#import "ClientDataSourceCollection.h"
#import "EBSearch.h"
#import "ClientListViewController.h"
#import "EBController.h"
#import "EBHttpClient.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "ClientAddFirstStepViewController.h"

@interface ClientViewController () <EBViewPagerDelegate, FilterViewDelegate>
{
    EBListView *_recentView;
    EBListView *_invitedView;
    EBListView *_collectedView;
    EBViewPager *_viewPager;
    
    BOOL _showRightAdd;
}

@end

@implementation ClientViewController

#define CLIENT_SCROLL_VIEW_TAG 99
#define SCROLL_SUBVIEW_BASE 77

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"client", nil);
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_search"]target:self action:@selector(showSearchClientView:)];
    
    if ([EBCache sharedInstance].businessConfig.clientConfig.allowAdd) {
        [self showRightAdd];
    }
	// Do any additional setup after loading the view.

    UIScrollView *scrollView = [EBViewFactory pagerScrollView:YES];
    scrollView.scrollsToTop = NO;
    scrollView.tag = CLIENT_SCROLL_VIEW_TAG;
    [self.view addSubview:scrollView];

    CGRect contentFrame = scrollView.bounds;
    
    EBFilterView *filterView = [[EBFilterView alloc] initWithFrame:contentFrame];
    filterView.tag = SCROLL_SUBVIEW_BASE + 1;
    filterView.delegate = self;
    filterView.filterType = EFilterTypeClient;
    [scrollView addSubview:filterView];
    contentFrame.origin.x += contentFrame.size.width;
    
    _recentView = [[EBListView alloc] initWithFrame:contentFrame];
    _recentView.tableView.scrollsToTop = YES;
    [scrollView addSubview:_recentView];
    ClientDataSource *ds = [[ClientDataSource alloc] init];
    ds.pageSize = 30;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] clientRequest:params recentViewed:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _recentView.emptyText = NSLocalizedString(@"empty_recent_client", nil);
    _recentView.dataSource = ds;
    _recentView.tag = SCROLL_SUBVIEW_BASE + 2;
    contentFrame.origin.x += contentFrame.size.width;
    
    
    _invitedView = [[EBListView alloc] initWithFrame:contentFrame];
    _invitedView.tableView.scrollsToTop = NO;
    [scrollView addSubview:_invitedView];
    ClientDataSourceInvite *dsEx = [[ClientDataSourceInvite alloc] init];
    dsEx.pageSize = 30;
    dsEx.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] clientRequest:params listAppointment:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _invitedView.emptyText = NSLocalizedString(@"empty_recent_client", nil);
    _invitedView.dataSource = dsEx;
    _invitedView.tag = SCROLL_SUBVIEW_BASE + 3;
    contentFrame.origin.x += contentFrame.size.width;
    
    _collectedView = [[EBListView alloc] initWithFrame:contentFrame];
    _collectedView.tableView.scrollsToTop = NO;
    [scrollView addSubview:_collectedView];
    ClientDataSourceCollection *dsCollection = [[ClientDataSourceCollection alloc] init];
    dsCollection.pageSize = 30;
    dsCollection.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] clientRequest:@{@"collect":@(1)} collect:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _collectedView.emptyText = NSLocalizedString(@"empty_recent_client", nil);
    _collectedView.dataSource = dsCollection;
    _collectedView.tag = SCROLL_SUBVIEW_BASE + 4;
    contentFrame.origin.x += contentFrame.size.width;
    



    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 4, contentFrame.size.height);
    //Add view pager.
    _viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame]
                                        pagerTitles:@[NSLocalizedString(@"filter", nil),
                                                      NSLocalizedString(@"recent_view", nil)
                                                      , NSLocalizedString(@"client_invited",nil),
                                                      NSLocalizedString(@"client_collected", nil)
                                                      ] defaultPage:0];
    [self.view addSubview:_viewPager];
    _viewPager.delegate = self;
    _viewPager.scrollView = scrollView;
    scrollView.delegate = _viewPager;

    _searchHelper = [[EBSearch alloc] init];
    _searchHelper.hidesTabBarWhenSearch = YES;
//    [_searchHelper setupSearchBarForController:self];

    [EBController observeNotification:NOTIFICATION_INVITE_ADDED from:self selector:@selector(inviteAdded)];
    [EBController observeNotification:NOTIFICATION_SHOW_INVITE from:self selector:@selector(showInvite)];
    
    [EBController observeNotification:NOTIFICATION_BUSINESS_CONFIG from:self selector:@selector(showRightAdd)];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self hiddenleftNVItem];
    
    [self beaverStatistics:@"CheckClient"];
}

//隐藏左箭头
- (void)hiddenleftNVItem
{
    self.navigationItem.leftBarButtonItem=nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_INVITE_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SHOW_INVITE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_BUSINESS_CONFIG object:nil];
}

- (void)showInvite
{
    _viewPager.currentPage = 2;
}

- (void)inviteAdded
{
   if (!_invitedView.loadInitialed)
   {
       [_invitedView startLoading];
   }
   else
   {
       [_invitedView refreshList:YES];
   }
}

-(void)showSearchClientView:(id)btn
{
    [EBTrack event:EVENT_CLICK_CLIENT_SEARCH];
    [_searchHelper searchClient];
}

- (void)showMoreFunctionList:(id)sender
{
    
    NSArray *purposes = [[EBCache sharedInstance] businessConfig].clientConfig.purposes;
    [[EBController sharedInstance] showPopOverListView:sender choices:purposes block:^(NSInteger selectedIndex) {
        ClientAddFirstStepViewController *controller = [ClientAddFirstStepViewController new];
        controller.actionType = EBEditTypeAdd;
        controller.purpose = purposes[selectedIndex];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }];
    [EBTrack event:EVENT_CLICK_CLIENT_ADD];
}

#pragma ViewPagerDelegate
- (void) switchToPageIndex:(NSInteger) page
{
    if (page)
    {
        UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:CLIENT_SCROLL_VIEW_TAG];
        EBListView *listView = (EBListView *)[scrollView viewWithTag:page + 1 + SCROLL_SUBVIEW_BASE];
        if (!listView.loadInitialed)
        {
            [listView startLoading];
        }
    }
    _recentView.tableView.scrollsToTop = page == 1;
    _invitedView.tableView.scrollsToTop = page == 2;
    _collectedView.tableView.scrollsToTop = page == 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_recentView.loadInitialed)
    {
        [_recentView refreshList:NO];
    }
    if(_collectedView.loadInitialed)
    {
        [_collectedView refreshList:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - filterViewDelegate
-(void)filterView:(EBFilterView*)filterView filter:(EBFilter *)filter
{
  [[EBController sharedInstance] showClientListWithType:EClientListTypeFilter filter:filter
                                                  title:NSLocalizedString(@"filter_client", nil) house:nil];
}

- (void)showRightAdd
{
    if (!_showRightAdd && [EBCache sharedInstance].businessConfig.clientConfig.allowAdd) {
        [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_more"]target:self action:@selector(showMoreFunctionList:)];
        _showRightAdd = YES;
    }
}

@end
