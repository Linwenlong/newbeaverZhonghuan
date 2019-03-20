//
//  HouseViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseViewController.h"
#import "EBViewFactory.h"
#import "EBViewPager.h"
#import "EBFilterView.h"
#import "EBSearch.h"
#import "EBListView.h"
#import "CategoryDataSource.h"
#import "HouseDataSource.h"
#import "HouseCollectionDataSource.h"
#import "EBController.h"
#import "EBHttpClient.h"
#import "EBCompatibility.h"
#import "EBCrypt.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
//#import "HouseAddViewController.h"
#import "HouseAddFirstStepViewController.h"
#import "EBAssociateViewController.h"
#import "SDImageCache.h"

//lwl
#import "HouseCollectionViewController.h"
#import "LWLScrollView.h"

@interface HouseViewController () <FilterViewDelegate, EBViewPagerDelegate>
{
    EBListView *_specialView;
    EBListView *_recentView;
    EBListView *_collectView;
    
    HouseCollectionViewController *collectVC;
    
    BOOL _showRightAdd;
}
@end

@implementation HouseViewController

- (void)loadView
{
    [super loadView];
    
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_search"]target:self action:@selector(showSearchHouseView:)];
    
    if ([EBCache sharedInstance].businessConfig.houseConfig.allowAdd) {
        [self showRightAdd];
    }
    
    //    [self setupLogoTitleView];
    
    [self setupPagingScrollView];
    
    [EBController observeNotification:NOTIFICATION_CONDITION_DELETE from:self selector:@selector(conditionChanged)];
    [EBController observeNotification:NOTIFICATION_CONDITION_UPDATE from:self selector:@selector(conditionChanged)];
    
    [EBController observeNotification:NOTIFICATION_BUSINESS_CONFIG from:self selector:@selector(showRightAdd)];
    
    _searchHelper = [[EBSearch alloc] init];
    _searchHelper.hidesTabBarWhenSearch = YES;
    //    [_searchHelper setupSearchBarForController:self];
    [self beaverStatistics:@"CheckHouse"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)conditionChanged
{
    [_specialView refreshList:YES];
}

#define LT_WIDTH 150.f
#define LT_HEIGHT 23.f
#define LT_LOGO_SIZE 20.f
#define LT_LOGO_Y 1.5
#define LT_LABEL_Y 0
#define LT_GAP 5.f

- (void)setupLogoTitleView
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, LT_WIDTH, LT_HEIGHT)];
    
    CGFloat ltXStart = [EBCompatibility isIOS7Higher] ? -6.f : 0;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]];
    logoView.frame = CGRectMake(ltXStart, LT_LOGO_Y, LT_LOGO_SIZE, LT_LOGO_SIZE);
    [customView addSubview:logoView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ltXStart + LT_GAP + LT_LOGO_SIZE, LT_LABEL_Y,
                                                                    LT_WIDTH - ltXStart - LT_GAP, LT_HEIGHT)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"product_title", nil);
    [customView addSubview:titleLabel];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    UIButton *titleBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    //    titleBt.backgroundColor = [UIColor greenColor];
    titleBt.backgroundColor = [UIColor clearColor];
    [titleBt addTarget:self action:@selector(scrollToTop:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titleBt];
    self.navigationItem.titleView = titleView;
}

- (void)scrollToTop:(UIButton*) btn
{
    [UIView animateWithDuration:0.5 animations:^
     {
         
     }];
}

#define HOUSE_SCROLL_VIEW_TAG 111
#define HOUSE_LISTVIEW_BASE_TAG 888


- (void)setupPagingScrollView
{
    #pragma mark -- 房源收藏打开
    LWLScrollView *scrollView = (LWLScrollView *)[EBViewFactory pagerScrollView:YES];
    NSLog(@"scrollView = %@",scrollView);

    scrollView.scrollsToTop = NO;

    scrollView.tag = HOUSE_SCROLL_VIEW_TAG;
    [self.view addSubview:scrollView];
    CGRect frame =scrollView.frame;
    frame.size.height +=49;
    scrollView.frame = frame;
    CGRect contentFrame = scrollView.bounds;

    EBFilterView *filterView = [[EBFilterView alloc] initWithFrame:contentFrame custom:YES withIsHouseView:YES];
    [filterView buildTableFooterViewForHouseView];
    filterView.delegate = self;
    filterView.tag = HOUSE_LISTVIEW_BASE_TAG + 1;
    [scrollView addSubview:filterView];
    contentFrame.origin.x += contentFrame.size.width;

    _specialView = [[EBListView alloc] initWithFrame:contentFrame];
    _specialView.tableView.scrollsToTop = YES;
    _specialView.withoutLoadMore = YES;
    CategoryDataSource *dataSource = [[CategoryDataSource alloc] init];
    dataSource.categoryType = ECategoryDataSourceTypeHouse;
    _specialView.dataSource = [[CategoryDataSource alloc] init];
    _specialView.tag = HOUSE_LISTVIEW_BASE_TAG + 2;//4
    _specialView.hideSeparator = YES;
    [scrollView addSubview:_specialView];


    contentFrame.origin.x += contentFrame.size.width;


    _recentView = [[EBListView alloc] initWithFrame:contentFrame];
    _recentView.tableView.scrollsToTop = NO;
    HouseDataSource *ds = [[HouseDataSource alloc] init];
    ds.pageSize = 30;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] houseRequest:params recentViewed:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _recentView.emptyText = NSLocalizedString(@"empty_recent_house", nil);
    _recentView.dataSource = ds;
    _recentView.tag = HOUSE_LISTVIEW_BASE_TAG + 3;
    [scrollView addSubview:_recentView];

    contentFrame.origin.x += contentFrame.size.width;

    collectVC = [[HouseCollectionViewController alloc]init];

    collectVC.view.frame = contentFrame;
    collectVC.view.tag = HOUSE_LISTVIEW_BASE_TAG + 4;//

    [scrollView addSubview:collectVC.view];


    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 4, contentFrame.size.height);

    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame]
                                                    pagerTitles:@[NSLocalizedString(@"filter", nil),NSLocalizedString(@"special", nil),NSLocalizedString(@"recent_view", nil),NSLocalizedString(@"collected", nil), ] defaultPage:0];
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.scrollView = scrollView;
    scrollView.delegate = viewPager;
    
//房源收藏关闭
//    UIScrollView *scrollView = [EBViewFactory pagerScrollView:YES];
//    scrollView.scrollsToTop = NO;
//    scrollView.tag = HOUSE_SCROLL_VIEW_TAG;
//    [self.view addSubview:scrollView];
//    CGRect frame =scrollView.frame;
//    frame.size.height +=49;
//    scrollView.frame = frame;
//    CGRect contentFrame = scrollView.bounds;
//
//    EBFilterView *filterView = [[EBFilterView alloc] initWithFrame:contentFrame custom:YES withIsHouseView:YES];
//    [filterView buildTableFooterViewForHouseView];
//    filterView.delegate = self;
//    filterView.tag = HOUSE_LISTVIEW_BASE_TAG + 1;
//    [scrollView addSubview:filterView];
//    contentFrame.origin.x += contentFrame.size.width;
//
//    //    HouseCategoryView *specialHouseView = [[HouseCategoryView alloc] initWithFrame:contentFrame];
//    //    [scrollView addSubview:specialHouseView];
//    //    contentFrame.origin.x += contentFrame.size.width;
//
//    _recentView = [[EBListView alloc] initWithFrame:contentFrame];
//    _recentView.tableView.scrollsToTop = NO;
//    HouseDataSource *ds = [[HouseDataSource alloc] init];
//    ds.pageSize = 30;
//    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
//    {
//        [[EBHttpClient sharedInstance] houseRequest:params recentViewed:^(BOOL success, id result)
//         {
//             done(success, result);
//         }];
//    };
//    _recentView.emptyText = NSLocalizedString(@"empty_recent_house", nil);
//    _recentView.dataSource = ds;
//    _recentView.tag = HOUSE_LISTVIEW_BASE_TAG + 2;
//    [scrollView addSubview:_recentView];
//
//    contentFrame.origin.x += contentFrame.size.width;
//
//    _collectView = [[EBListView alloc] initWithFrame:contentFrame];
//    _collectView.tableView.scrollsToTop = NO;
//    HouseCollectionDataSource *dsCollect = [[HouseCollectionDataSource alloc] init];
//    dsCollect.pageSize = 30;
//    dsCollect.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
//    {
//        [[EBHttpClient sharedInstance] houseRequest:@{@"collect":@(1)} collect:^(BOOL success, id result)
//         {
//             done(success, result);
//         }];
//    };
//    _collectView.dataSource = dsCollect;
//    _collectView.tag = HOUSE_LISTVIEW_BASE_TAG + 3;
//    [scrollView addSubview:_collectView];
//    contentFrame.origin.x += contentFrame.size.width;
//
//    _specialView = [[EBListView alloc] initWithFrame:contentFrame];
//    _specialView.tableView.scrollsToTop = YES;
//    _specialView.withoutLoadMore = YES;
//    CategoryDataSource *dataSource = [[CategoryDataSource alloc] init];
//    dataSource.categoryType = ECategoryDataSourceTypeHouse;
//    _specialView.dataSource = [[CategoryDataSource alloc] init];
//    _specialView.tag = HOUSE_LISTVIEW_BASE_TAG + 4;
//    _specialView.hideSeparator = YES;
//    [scrollView addSubview:_specialView];
//
//    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 4, contentFrame.size.height);
//    //Add view pager.
//    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame]
//                                                    pagerTitles:@[NSLocalizedString(@"filter", nil),NSLocalizedString(@"recent_view", nil),NSLocalizedString(@"collected", nil),NSLocalizedString(@"special", nil), ] defaultPage:0];
//    [self.view addSubview:viewPager];
//    viewPager.delegate = self;
//    viewPager.scrollView = scrollView;
//    scrollView.delegate = viewPager;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_specialView startLoading];
    if (_recentView.loadInitialed)
    {
        [_recentView refreshList:NO];
    }
    if(_collectView.loadInitialed)
    {
        [_collectView refreshList:NO];
    }
    //    for (UIView *view in self.view.subviews) {
    //        if ([view isKindOfClass:EBViewPager.class]) {
    //            if ([(EBViewPager *)view currentPage] == 1 && _recentView.loadInitialed) {
    //                [self reloadRecentView:YES];
    //            } else if ([(EBViewPager *)view currentPage] == 2 && _collectView.loadInitialed) {
    //                [self reloadCollectionView:YES];
    //            }
    //            break;
    //        }
    //    }
    //    [_recentView startLoading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self reloadRecentView:NO];
    //    [self reloadCollectionView:NO];
    
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)setNavigationBackTitle
{
    [self setNavigationBackTitle:@" "];
}

#pragma ViewPagerDelegate
- (void) switchToPageIndex:(NSInteger) page
{
    //    EBListView *listView = (EBListView *)[[self.view viewWithTag:HOUSE_SCROLL_VIEW_TAG] viewWithTag:page + 1 + HOUSE_LISTVIEW_BASE_TAG];
    //    if (page == 0) {
    //        if (!listView.loadInitialed)
    //        {
    //            [listView startLoading];
    //        }
    //        [self reloadRecentView:NO];
    //        [self reloadCollectionView:NO];
    //    } else if (page == 1) {
    //        if (!listView.loadInitialed)
    //        {
    //            [(HouseDataSource *)_recentView.dataSource setShowImage:YES];
    //            [listView startLoading];
    //        } else {
    //            [self reloadRecentView:YES];
    //        }
    //        [self reloadCollectionView:NO];
    //    } else if (page == 2) {
    //        if (!listView.loadInitialed)
    //        {
    //            [(HouseCollectionDataSource *)_collectView.dataSource setShowImage:YES];
    //            [listView startLoading];
    //        } else {
    //            [self reloadCollectionView:YES];
    //        }
    //        [self reloadRecentView:NO];
    //    }
    //    [[SDImageCache sharedImageCache] clearMemory];
    
    if (page != 3 && page)
    {
        EBListView *listView = (EBListView *)[[self.view viewWithTag:HOUSE_SCROLL_VIEW_TAG] viewWithTag:page + 1 + HOUSE_LISTVIEW_BASE_TAG];
        if (!listView.loadInitialed)
        {
            [listView startLoading];
        }
    }
    _specialView.tableView.scrollsToTop = page == 3;
    _recentView.tableView.scrollsToTop = page == 1;
    #pragma mark -- 房源收藏隐藏
//    _collectView.tableView.scrollsToTop = page == 2;//房源收藏隐藏
    
    //    [scrollView setContentOffset:CGPointMake(page * scrollView.bounds.size.width,0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSearchHouseView:(id)btn
{
    //    [[EBController sharedInstance].mainTabViewController.tabBar setHidden:YES];
    //    _searchBar.hidden = NO;
    //    [_displayController setActive:YES animated:YES];
    //    [_searchBar becomeFirstResponder];
    
    [EBTrack event:EVENT_CLICK_HOUSE_SEARCH];
    [_searchHelper searchHouse];
}

- (void)showMoreFunctionList:(id)sender
{
    NSArray *purposes = [[EBCache sharedInstance] businessConfig].houseConfig.purposes;
    [[EBController sharedInstance] showPopOverListView:sender choices:purposes block:^(NSInteger selectedIndex) {
        //        HouseAddViewController *controller = [HouseAddViewController new];
        //        controller.hidesBottomBarWhenPushed = YES;
        //        controller.purpose = purposes[selectedIndex];
        HouseAddFirstStepViewController *controller = [HouseAddFirstStepViewController new];
        controller.inputDisks = self.inputDisks;
        controller.actionType = EBEditTypeAdd;
        controller.purpose = purposes[selectedIndex];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }];
    [EBTrack event:EVENT_CLICK_HOUSE_ADD];
}

#pragma mark - filterViewDelegate
-(void)filterView:(EBFilterView*)filterView filter:(EBFilter *)filter
{
    [[EBController sharedInstance] showHouseListWithType:EHouseListTypeFilter filter:filter title:NSLocalizedString(@"filter_house", nil) client:nil];
}

- (void)reloadRecentView:(BOOL)showImage
{
    if (_recentView.loadInitialed) {
        [(HouseDataSource *)_recentView.dataSource setShowImage:showImage];
        [_recentView refreshList:NO];
    }
}

- (void)reloadCollectionView:(BOOL)showImage
{
    if (_collectView.loadInitialed) {
        [(HouseCollectionDataSource *)_collectView.dataSource setShowImage:showImage];
        [_collectView refreshList:NO];
    }
}

- (void)showRightAdd
{
    if (!_showRightAdd && [EBCache sharedInstance].businessConfig.houseConfig.allowAdd) {
        [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_more"]target:self action:@selector(showMoreFunctionList:)];
        _showRightAdd = YES;
    }
}
@end
