//
//  GatherAndPublishViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherAndPublishViewController.h"
#import "GatherViewController.h"
#import "PublishPortViewController.h"
#import "GatherHouseDetailViewController.h"
#import "GatherHouseInErpViewController.h"
#import "CustomBadge.h"
#import "EBHttpClient.h"
#import "EBNavigationController.h"
#import "MainTabViewController.h"
#import "PublishHouseRecordViewController.h"
#import "PublishHouseOrderViewController.h"

#define COLLECTION_CELL_IDENTIFIER @"ccell"
#define COLLECTION_CELL_SUPPLEVIEW_IDENTIFIER @"supplementaryView"
#define COLLECTION_CELL_IMAGE_Y_START 16.f
#define COLLECTION_CELL_IMAGE_HEIGHT 57.f
#define COLLECTION_CELL_TAG_IMAGE 99
#define COLLECTION_CELL_TAG_LABEL 100
#define COLLECTION_CELL_TAG_RIGHT_LINE 101
#define COLLECTION_CELL_IMAGE_TITLE_GAP 6.f
#define COLLECTION_CELL_LABEL_HEIGHT 20.f
#define COLLECTION_CELL_TAG_LABEL_FAILURE 108
#define COLLECTION_CELL_LINE_WIDTH 1.f
#define COLLECTION_CELL_WIDTH 106.f
#define COLLECTION_CELL_HEIGHT 108.f
#define COLLECTION_CELL_COL_NUM 3

@interface GatherAndPublishViewController ()
{
    NSDictionary *_toolDic;
    NSString *_subscriptionUnreadCount;
    NSString *_publishFailureCount;
    UICollectionView *_collectionView;
}

@end

@implementation GatherAndPublishViewController

- (void)loadView
{
    [super loadView];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.footerReferenceSize = CGSizeMake([EBStyle screenWidth] -30.0f, 0.5);
    _collectionView = [[UICollectionView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO] collectionViewLayout:layout];
    
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_CELL_IDENTIFIER];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:COLLECTION_CELL_SUPPLEVIEW_IDENTIFIER];
    [self.view addSubview:_collectionView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *section0 = @[
                          @{@"title":NSLocalizedString(@"gp_gather_house", nil),
                            @"image":[UIImage imageNamed:@"gp_gather"],
                            @"viewController": [GatherViewController class]},
                          @{@"title":NSLocalizedString(@"gp_subscription", nil),
                            @"image":[UIImage imageNamed:@"gp_subscription"],
                            @"viewController": [GatherViewController class]},
                          @{@"title":NSLocalizedString(@"gp_bookmark", nil),
                            @"image":[UIImage imageNamed:@"gp_bookmark"],
                            @"viewController": [GatherViewController class]},
                          ];
    NSArray *section1 = @[
                          @{@"title":NSLocalizedString(@"gp_inputed_erp", nil),
                            @"image":[UIImage imageNamed:@"gp_inputed_erp"],
                            @"viewController": [GatherHouseInErpViewController class]},
                          ];
    NSArray *section2 = @[
                          @{@"title":NSLocalizedString(@"gp_published", nil),
                            @"image":[UIImage imageNamed:@"gp_published"],
                            @"viewController": [PublishHouseRecordViewController class]},
                          @{@"title":NSLocalizedString(@"gp_apponitment_publish", nil),
                            @"image":[UIImage imageNamed:@"gp_appointment"],
                            @"viewController": [PublishHouseOrderViewController class]},
                          @{@"title":NSLocalizedString(@"gp_publish_port", nil),
                            @"image":[UIImage imageNamed:@"gp_publish_port"],
                            @"viewController": [PublishPortViewController class]},
                          ];
    _toolDic = @{@"section0":section0, @"section1":section1, @"section2":section2};
    [EBController observeNotification:NOTIFICATION_GATHER_UNREADCOUNT_CHANGED from:self selector:@selector(getUnreadCount)];
    [EBController observeNotification:NOTIFICATION_GATHER_READ from:self selector:@selector(getUnreadCount)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUnreadCount];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _toolDic.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *temp = _toolDic[[NSString stringWithFormat:@"section%ld",section]];
    return temp.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *temp = _toolDic[[NSString stringWithFormat:@"section%ld",indexPath.section]];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_CELL_IDENTIFIER forIndexPath:indexPath];
    NSUInteger itemIndex = [indexPath row];
    NSDictionary *itemConfig = [temp objectAtIndex:itemIndex];
    
    [self updateCellView:cell withImage:[itemConfig objectForKey:@"image"]
                   title:[itemConfig objectForKey:@"title"] rightBorder:((itemIndex + 1) % COLLECTION_CELL_COL_NUM) > 0];
    if ((indexPath.section == 0 && indexPath.row == 1)
        || (indexPath.section == 2 && indexPath.row == 0))
    {
        [self updateCellForUnreadCount:cell indexPath:indexPath];
    }
    else
    {
        CustomBadge *badge = (CustomBadge *)[cell.contentView viewWithTag:88];
        if (badge)
        {
            badge.hidden = YES;
        }
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *footerLine = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:COLLECTION_CELL_SUPPLEVIEW_IDENTIFIER forIndexPath:indexPath];
    footerLine.backgroundColor = [EBStyle grayUnClickLineColor];
    CGRect frame = footerLine.frame;
    frame.origin.x = 15.0;
    frame.size.width = indexPath.section == _toolDic.count - 1 ? 0 : [EBStyle screenWidth]-30.0f;
    footerLine.frame = frame;
    return footerLine;
}
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *temp = _toolDic[[NSString stringWithFormat:@"section%ld",indexPath.section]];
    NSDictionary *itemConfig = [temp objectAtIndex:[indexPath row]];
    Class cls = [itemConfig objectForKey:@"viewController"];
    UIViewController *controller = [[cls alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    if ([controller isKindOfClass:[GatherViewController class]])
    {
        GatherViewController *gatherViewController = (GatherViewController *)controller;
        NSInteger row = indexPath.row;
        gatherViewController.viewType = row;
        EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:gatherViewController];
        [[EBController sharedInstance].mainTabViewController presentViewController:naviController animated:YES completion:nil];
    }
    else
    {
        [self.navigationController pushViewController:controller animated:YES];
    }
    controller.title = itemConfig[@"title"];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT];
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_SUBSCRIBE];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_BOOKMARK];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_ADDED_ERP];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_POSTED];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_BOOKING];
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_POST_PORT];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] % COLLECTION_CELL_COL_NUM == COLLECTION_CELL_COL_NUM - 1)
    {
        return CGSizeMake(COLLECTION_CELL_WIDTH, COLLECTION_CELL_HEIGHT);
    }
    return CGSizeMake( COLLECTION_CELL_WIDTH  + COLLECTION_CELL_LINE_WIDTH, COLLECTION_CELL_HEIGHT);
}

#pragma mark - Private Method

- (void)updateCellView:(UICollectionViewCell *)cell withImage:(UIImage *)image title:(NSString *)title rightBorder:(BOOL)yes
{
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:COLLECTION_CELL_TAG_IMAGE];
    UILabel *titleView = (UILabel *)[cell.contentView viewWithTag:COLLECTION_CELL_TAG_LABEL];
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, COLLECTION_CELL_IMAGE_Y_START, COLLECTION_CELL_WIDTH, COLLECTION_CELL_IMAGE_HEIGHT)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.tag = COLLECTION_CELL_TAG_IMAGE;
        [cell.contentView addSubview:imageView];
        
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, COLLECTION_CELL_IMAGE_Y_START + COLLECTION_CELL_IMAGE_HEIGHT +
                                                              COLLECTION_CELL_IMAGE_TITLE_GAP, COLLECTION_CELL_WIDTH, COLLECTION_CELL_LABEL_HEIGHT)];
        titleView.font = [UIFont systemFontOfSize:14.0];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = [UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1.0];
        titleView.tag = COLLECTION_CELL_TAG_LABEL;
        [cell.contentView addSubview:titleView];
    }
    
    imageView.image = image;
    imageView.frame = CGRectMake(0.0, COLLECTION_CELL_IMAGE_Y_START, COLLECTION_CELL_WIDTH, COLLECTION_CELL_IMAGE_HEIGHT);
    titleView.text = title;
    titleView.textColor = [UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1.0];
    [cell.contentView viewWithTag:COLLECTION_CELL_TAG_LABEL_FAILURE].hidden = YES;
//    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.1*(arc4random()%10) alpha:1];
    
}

- (void)updateCellForUnreadCount:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    CustomBadge *badge = (CustomBadge *)[cell.contentView viewWithTag:88];
    if (badge == nil)
    {
        badge = [CustomBadge customBadgeWithString:nil
                                   withStringColor:[UIColor whiteColor]
                                    withInsetColor:[EBStyle redTextColor]
                                    withBadgeFrame:NO
                               withBadgeFrameColor:[UIColor whiteColor]
                                         withScale:1.0
                                       withShining:NO];
        CGRect badgeFrame = badge.frame;
        CGRect btnFrame = cell.contentView.bounds;
        badge.tag = 88;
        badge.frame = CGRectOffset(badgeFrame, btnFrame.size.width - badgeFrame.size.width - 22.0, 5.0);
        [cell.contentView addSubview:badge];
    }
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        if (_subscriptionUnreadCount && _subscriptionUnreadCount.length > 0)
        {
            [badge autoBadgeSizeWithString:_subscriptionUnreadCount];
            if (_subscriptionUnreadCount.length >= 2)
            {
                badge.frame = CGRectMake(badge.frame.origin.x, badge.frame.origin.y, badge.frame.size.width - 10, badge.frame.size.height);
            }
            badge.hidden = NO;
        }
        else
        {
            badge.hidden = YES;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        if (_publishFailureCount && _publishFailureCount.length > 0)
        {
            [badge autoBadgeSizeWithString:_publishFailureCount];
            if (_publishFailureCount.length >= 2)
            {
                badge.frame = CGRectMake(badge.frame.origin.x, badge.frame.origin.y, badge.frame.size.width - 10, badge.frame.size.height);
            }
            badge.hidden = NO;
        }
        else
        {
            badge.hidden = YES;
        }
    }
    else
    {
        badge.hidden = YES;
    }
}

- (void)getUnreadCount
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getUnreadCount:^(BOOL success, id result)
     {
         if (success)
         {
             NSInteger unreadCount1 = [result[@"subscription"] integerValue];
             NSInteger unreadCount2 = [result[@"publish_failure"] integerValue];
             if (unreadCount1 > 99)
             {
                 _subscriptionUnreadCount = NSLocalizedString(@"gp_max_unread_count", nil);
             }
             else if(unreadCount1 == 0)
             {
                 _subscriptionUnreadCount = nil;
             }
             else
             {
                 _subscriptionUnreadCount = [NSString stringWithFormat:@"%ld", unreadCount1];
             }
             
             if (unreadCount2 > 99)
             {
                 _publishFailureCount = NSLocalizedString(@"gp_max_unread_count", nil);
             }
             else if(unreadCount2 == 0)
             {
                 _publishFailureCount = nil;
             }
             else
             {
                 _publishFailureCount = [NSString stringWithFormat:@"%ld", unreadCount2];
             }
             [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:0 inSection:2], nil]];
         }
     }];
}

@end
