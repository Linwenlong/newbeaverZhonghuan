//
//  NewHouseFollowViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "NewHouseFollowViewController.h"
#import "EBListView.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "NewHouseFilingDataSource.h"

#define NEW_HOUSE_FOLLOW_SCROLL_VIEW_TAG 111
#define NEW_HOUSE_FOLLOW_LISTVIEW_BASE_TAG 888

@interface NewHouseFollowViewController ()
{
    EBListView *_filingListView;
    EBListView *_followingListView;
    EBListView *_bargainListView;
}

@end

@implementation NewHouseFollowViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EBViewPagerDelegate

- (void)switchToPageIndex:(NSInteger) page
{
    EBListView *listView = (EBListView *)[[self.view viewWithTag:NEW_HOUSE_FOLLOW_SCROLL_VIEW_TAG] viewWithTag:page + 1 + NEW_HOUSE_FOLLOW_LISTVIEW_BASE_TAG];
    if (!listView.loadInitialed)
    {
        [listView startLoading];
    }
    switch (page) {
        case 0:
            [EBTrack event:EVENT_CLICK_NEW_HOUSE_SUBMIT];
            break;
        case 1:
            [EBTrack event:EVENT_CLICK_NEW_HOUSE_SUBMIT];
            break;
        case 2:
            [EBTrack event:EVENT_CLICK_NEW_HOUSE_SUBMIT];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Method

- (void)setupPagingScrollView
{
    UIScrollView *scrollView = [EBViewFactory pagerScrollView:NO];
    scrollView.tag = NEW_HOUSE_FOLLOW_SCROLL_VIEW_TAG;
    [self.view addSubview:scrollView];
    
    CGRect contentFrame = scrollView.bounds;
    
    _filingListView = [[EBListView alloc] initWithFrame:contentFrame];
    NewHouseFilingDataSource *dsFiling = [[NewHouseFilingDataSource alloc] init];
    dsFiling.pageSize = 30;
    dsFiling.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] houseRequest:@{@"status":@"ge:-1"} nhFollowList:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _filingListView.dataSource = dsFiling;
    _filingListView.emptyText = NSLocalizedString(@"empty_new_house_follow", nil);
    _filingListView.tag = NEW_HOUSE_FOLLOW_LISTVIEW_BASE_TAG + 1;
    [scrollView addSubview:_filingListView];
    contentFrame.origin.x += contentFrame.size.width;
    
    _followingListView = [[EBListView alloc] initWithFrame:contentFrame];
    NewHouseFilingDataSource *dsFollow = [[NewHouseFilingDataSource alloc] init];
    dsFollow.pageSize = 30;
    dsFollow.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] houseRequest:@{@"status":@"ge:2"} nhFollowList:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _followingListView.emptyText = NSLocalizedString(@"empty_new_house_follow", nil);
    _followingListView.dataSource = dsFollow;
    _followingListView.tag = NEW_HOUSE_FOLLOW_LISTVIEW_BASE_TAG + 2;
    [scrollView addSubview:_followingListView];
    contentFrame.origin.x += contentFrame.size.width;
    
    _bargainListView = [[EBListView alloc] initWithFrame:contentFrame];
    NewHouseFilingDataSource *dsBargain = [[NewHouseFilingDataSource alloc] init];
    dsBargain.pageSize = 30;
    dsBargain.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] houseRequest:@{@"status":@"ge:3"} nhFollowList:^(BOOL success, id result)
         {
             done(success, result);
        }];
    };
    _bargainListView.dataSource = dsBargain;
    _bargainListView.emptyText = NSLocalizedString(@"empty_new_house_follow", nil);
    _bargainListView.tag = NEW_HOUSE_FOLLOW_LISTVIEW_BASE_TAG + 3;
    [scrollView addSubview:_bargainListView];
    contentFrame.origin.x += contentFrame.size.width;
    
    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 3, contentFrame.size.height);
    //Add view pager.
    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame]
                                                    pagerTitles:@[NSLocalizedString(@"has_filing_title", nil),NSLocalizedString(@"has_follow_title", nil),NSLocalizedString(@"has_bargain_title", nil)] defaultPage:0];
    
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.scrollView = scrollView;
    scrollView.delegate = viewPager;
}

@end
