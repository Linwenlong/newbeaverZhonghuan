//
//  GatherHouseViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherViewController.h"
#import "GatherSettingViewController.h"
#import "EBRadioGroup.h"
#import "EBViewFactory.h"
#import "EBListView.h"
#import "EBHttpClient.h"
#import "HouseViewController.h"
#import "GatherHouseViewController.h"
#import "CategoryDataSource.h"
#import "GatherHouseDataSource.h"
#import "EBNavigationController.h"
#import "EBController.h"
#import "MainTabViewController.h"

@interface GatherViewController ()
{
    NSInteger _selectedIndex;
    NSMutableArray *_titleArray;
    EBListView *_subscriptionView;
    EBListView *_bookMarkView;
    UIView *_gatherView;
    NSInteger _unreadCount;
    GatherHouseViewController *_gatherHouseViewController;
}

@end

@implementation GatherViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_setting"] target:self action:@selector(toSetting:)];
    _titleArray = [[NSMutableArray alloc] initWithArray:@[NSLocalizedString(@"gp_gather_house", nil),
                                                         NSLocalizedString(@"gp_subscription", nil),
                                                         NSLocalizedString(@"gp_bookmark", nil)]];
    [self setupTitleView];
    _gatherHouseViewController = [[GatherHouseViewController alloc] init];
    _gatherView = _gatherHouseViewController.view;
    [self.view addSubview:_gatherView];
    [self addChildViewController:_gatherHouseViewController];
    
    _subscriptionView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _subscriptionView.withoutLoadMore = YES;
    CategoryDataSource *dataSource = [[CategoryDataSource alloc] init];
    dataSource.categoryType = ECategoryDataSourceTypeGatherHouse;
    _subscriptionView.dataSource = dataSource;
    _subscriptionView.hideSeparator = YES;
    __weak GatherViewController *weakSelf = self;
    _subscriptionView.listStateListener = ^(EEBListViewState state)
    {
        if (state == EEBListViewStateLoadingSuccess)
        {
            [weakSelf getUnreadCount];
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_READ object:nil]];
        }
    };
    [self.view addSubview:_subscriptionView];
    _subscriptionView.hidden = YES;
    
    _bookMarkView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    GatherHouseDataSource *ds = [[GatherHouseDataSource alloc] init];
    ds.pageSize = 20;
    ds.showHouseType = YES;
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        [[EBHttpClient sharedInstance] gatherPublishRequest:params bookmarkList:^(BOOL success, id result)
        {
            done(success, result);
        }];
    };
    _bookMarkView.emptyText = NSLocalizedString(@"empty_bookmark_house", nil);
    _bookMarkView.dataSource = ds;
    [self.view addSubview:_bookMarkView];
    _bookMarkView.hidden = YES;
    
    [self setSelectedIndex:_viewType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [EBController observeNotification:NOTIFICATION_SUBSCRIPTION_DELETE from:self selector:@selector(conditionChanged)];
    [EBController observeNotification:NOTIFICATION_SUBSCRIPTION_UPDATE from:self selector:@selector(conditionChanged)];
    [EBController observeNotification:NOTIFICATION_GATHER_UNREADCOUNT_CHANGED from:self selector:@selector(conditionChanged)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUnreadCount];
    if (_subscriptionView.loadInitialed)
    {
        [_subscriptionView refreshList:YES];
    }
    if (_bookMarkView.loadInitialed)
    {
        [_bookMarkView refreshList:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIAction Method

-(void)toSetting:(id)btn
{
    [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_SETTING];
    GatherSettingViewController *settingViewController = [[GatherSettingViewController alloc] init];
    settingViewController.settingChanged = ^{
        [_gatherHouseViewController refreshGatherHouse];
    };
    EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:settingViewController];
    [[EBController sharedInstance].currentNavigationController presentViewController:naviController animated:YES completion:nil];
}

- (void)radioChecked:(UIButton *)btn
{
    _selectedIndex = btn.tag - 1;
    [self setRightButton:0 hidden:_selectedIndex != 0];
    for (NSInteger i = 0; i < _titleArray.count; i++)
    {
        UIButton *btn = (UIButton *)[self.navigationItem.titleView viewWithTag:i + 1];
        btn.selected = btn.tag == _selectedIndex + 1 ? YES : NO;
    }
    switch (_selectedIndex) {
        case 0:
            _gatherView.hidden = NO;
            _subscriptionView.hidden = YES;
            _bookMarkView.hidden = YES;
            break;
        case 1:
            if (!_subscriptionView.loadInitialed)
            {
                [_subscriptionView startLoading];
            }
            _subscriptionView.hidden = NO;
            _bookMarkView.hidden = YES;
            _gatherView.hidden = YES;
            break;
        case 2:
            if (!_bookMarkView.loadInitialed)
            {
                [_bookMarkView startLoading];
            }
            _bookMarkView.hidden = NO;
            _subscriptionView.hidden = YES;
            _gatherView.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)conditionChanged
{
    if (_subscriptionView.loadInitialed)
    {
        [_subscriptionView refreshList:YES];
    }
    [self getUnreadCount];
}

#pragma mark -Private Method

- (void)getUnreadCount
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getUnreadCount:^(BOOL success, id result)
     {
         if (success)
         {
             _unreadCount = [result[@"subscription"] integerValue];
             NSString *unreadCountStr = [NSString stringWithFormat:@"%ld", _unreadCount];
             if (_unreadCount > 99)
             {
                 unreadCountStr = NSLocalizedString(@"gp_max_unread_count", nil);
             }
             if (_unreadCount > 0)
             {
                 [_titleArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:NSLocalizedString(@"gp_subscription_unread", nil),unreadCountStr]];
             }
             else
             {
                 [_titleArray replaceObjectAtIndex:1 withObject:NSLocalizedString(@"gp_subscription", nil)];
             }
             [self setupTitleView];
         }
    }];
}

- (void)setupTitleView
{
    UIView *titleView = self.navigationItem.titleView;
    CGFloat xOffset = 0.0;
    if (titleView == nil)
    {
        titleView = [[UIView alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        
        for (int i = 0; i < _titleArray.count; i++)
        {
            CGFloat width = 50.0;
            CGFloat titleWidth = [EBViewFactory textSize:_titleArray[i] font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
            if (titleWidth > 50.0)
            {
                width = titleWidth + 22.0;
            }
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, 9.0, width, 26.0)];
            
            xOffset = btn.frame.origin.x + btn.frame.size.width + 10;
            [btn setBackgroundImage:[[UIImage imageNamed:@"btn_radio_white"] stretchableImageWithLeftCapWidth:13.0 topCapHeight:0.0]
                           forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(radioChecked:) forControlEvents:UIControlEventTouchUpInside];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
            [btn setTitle:_titleArray[i] forState:UIControlStateSelected];
            btn.tag = i + 1;
            [titleView addSubview:btn];
        }
    }
    else
    {
        for (int i = 0; i < _titleArray.count; i++)
        {
            CGFloat width = 50.0;
            CGFloat titleWidth = [EBViewFactory textSize:_titleArray[i] font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
            if (titleWidth > 50.0)
            {
                width = titleWidth + 22.0;
            }
            UIButton *btn = (UIButton *)[self.navigationItem.titleView viewWithTag:i + 1];
            [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
            [btn setTitle:_titleArray[i] forState:UIControlStateSelected];
            btn.frame = CGRectMake(xOffset, 9.0, width, 26.0);
            xOffset = btn.frame.origin.x + btn.frame.size.width + 10;
        }
        
    }
    if (xOffset > 0.0)
    {
        CGRect frame = titleView.frame;
        frame.size.height = 44.0;
        frame.size.width = xOffset - 10;
        titleView.frame = frame;
        self.navigationItem.titleView = titleView;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    UIButton *btn = (UIButton *)[self.navigationItem.titleView viewWithTag:selectedIndex + 1];
    [self radioChecked:btn];
}

@end
