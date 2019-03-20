//
//  ToolViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ToolViewController.h"
#import "QRScannerViewController.h"
#import "CalculatorViewController.h"
#import "ContactsViewController.h"
#import "SettingViewController.h"
#import "EBUpdater.h"
#import "EBHousePhotoUploader.h"
#import "HousePhotoUploadingViewController.h"
#import "NewHouseWebViewController.h"
#import "NewHouseFollowViewController.h"
#import "EBCache.h"
#import "EBCompanyInfo.h"
#import "EBPreferences.h"
#import "GatherAndPublishViewController.h"
#import "CustomBadge.h"
#import "EBHttpClient.h"
#import "EBVideoUtil.h"

@interface ToolViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>  //, UICollectionViewDelegateFlowLayout
{
    NSMutableArray *_toolsArray;
    UICollectionView *_collectionView;
    NSString *_unreadCountStr;
}
@end

@implementation ToolViewController

#define TOOL_START_Y 0.0
#define CELL_IDENTIFIER @"ccell"
#define CELL_IMAGE_Y_START 18.f
#define CELL_IMAGE_HEIGHT 26.f
#define CELL_TAG_IMAGE 99
#define CELL_TAG_LABEL 100
#define CELL_TAG_RIGHT_LINE 101
#define CELL_IMAGE_TITLE_GAP 10.f
#define CELL_LABEL_HEIGHT 20.f
#define CELL_TAG_LABEL_FAILURE 108
#define CELL_TAG_BADGE 109

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"tool", nil);
	// Do any additional setup after loading the view.

    NSString *reminder = [EBUpdater hasUpdate] ? @"1" : nil;
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_setting"] target:self action:@selector(toSetting:) badge:reminder];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, TOOL_START_Y,
            self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];

    _collectionView.alwaysBounceVertical = YES;

    [EBController observeNotification:NOTIFICATION_VERSION_NO_UPDATE from:self selector:@selector(updateInfoChanged:)];
    [EBController observeNotification:NOTIFICATION_VERSION_UPDATE from:self selector:@selector(updateInfoChanged:)];
    [EBController observeNotification:NOTIFICATION_VERSION_FORCE_UPDATE from:self selector:@selector(updateInfoChanged:)];
}

- (void)updateInfoChanged:(NSNotification *)notification
{
    [self setRightNavigationButtonBadge:[EBUpdater hasUpdate] ? @"1" : nil  atIndex:0];
}

-(void)toSetting:(id)btn
{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingViewController animated:YES];
}

#define CELL_WIDTH 106.f
#define CELL_HEIGHT 90.f
#define CELL_COL_NUM 3

#pragma mark - collection view datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *fixed = @[
            @{@"title":NSLocalizedString(@"scan_qrcode", nil),
              @"image":[UIImage imageNamed:@"tool_qr_scan"],
              @"viewController": [QRScannerViewController class]},
            @{@"title":NSLocalizedString(@"loan_calculator", nil),
              @"image":[UIImage imageNamed:@"tool_calculator"],
              @"viewController": [CalculatorViewController class]},
            @{@"title":NSLocalizedString(@"workmate_contacts", nil),
              @"image":[UIImage imageNamed:@"tool_contacts"],
              @"viewController": [ContactsViewController class]},
            @{@"title":NSLocalizedString(@"new_house", nil),
              @"image":[UIImage imageNamed:@"tool_new_house"],
              @"viewController": [NewHouseWebViewController class]},
            @{@"title":NSLocalizedString(@"new_house_client_follow", nil),
              @"image":[UIImage imageNamed:@"tool_client_follow"],
              @"viewController": [NewHouseFollowViewController class]},
            @{@"title":NSLocalizedString(@"tool_gather_publish_house", nil),
              @"image":[UIImage imageNamed:@"tool_gather_house"],
              @"viewController": [GatherAndPublishViewController class]},
    ];

    _toolsArray = [NSMutableArray arrayWithArray:fixed];

    if ([[EBHousePhotoUploader sharedInstance] isUploading] || [EBVideoUtil isUploading])
    {
        [_toolsArray addObject:@{@"title":NSLocalizedString(@"photo_uploading", nil),
                                 @"image":[UIImage imageNamed:@"upload_green"],
                                 @"viewController": [HousePhotoUploadingViewController class]}];
    }


    return _toolsArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
    }

    NSUInteger itemIndex = [indexPath row];
    NSDictionary *itemConfig = [_toolsArray objectAtIndex:itemIndex];

    [self updateCellView:cell withImage:[itemConfig objectForKey:@"image"]
                   title:[itemConfig objectForKey:@"title"] rightBorder:((itemIndex + 1) % CELL_COL_NUM) > 0];

    if ([[EBHousePhotoUploader sharedInstance] isUploading] && itemIndex == _toolsArray.count - 1)
    {
        [self updateCellForUpload:cell];
    }
    if (([[EBHousePhotoUploader sharedInstance] isUploading] && itemIndex == _toolsArray.count - 2)
             || (![[EBHousePhotoUploader sharedInstance] isUploading] && itemIndex == _toolsArray.count - 1))
    {
        [self updateCellForGather:cell];
    }
    else
    {
        CustomBadge *badge = (CustomBadge *)[cell.contentView viewWithTag:CELL_TAG_BADGE];
        if (badge)
        {
            badge.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemConfig = [_toolsArray objectAtIndex:[indexPath row]];
    Class cls = [itemConfig objectForKey:@"viewController"];

    UIViewController *controller = [[cls alloc] init];
    if ([controller isKindOfClass:[CalculatorViewController class]])
    {
        [EBTrack event:EVENT_CLICK_LOAN_CALCULATOR];
        [[EBController sharedInstance] openURL:[NSURL URLWithString:BEAVER_Calculator]];
        return;
//        CalculatorViewController *temp = (CalculatorViewController*)controller;
//        temp.isOpenByTool = YES;
    }
    else if ([controller isKindOfClass:[NewHouseWebViewController class]])
    {
        NewHouseWebViewController *temp = (NewHouseWebViewController*)controller;
        EBCompanyInfo *companyInfo = [EBCache sharedInstance].companyInfo;
        EBPreferences *pref = [EBPreferences sharedInstance];
        NSString *URLString = [NSString stringWithFormat:NSLocalizedString(@"new_house_url_format", nil),companyInfo.cityNamePinYin, companyInfo.version, companyInfo.companyId, pref.companyCode];
        temp.requestURL = URLString;
        [EBTrack event:EVENT_CLICK_NEW_HOUSE];
    }
    else if ([controller isKindOfClass:[NewHouseFollowViewController class]])
    {
        [EBTrack event:EVENT_CLICK_NEW_HOUSE_FOLLOW];
    }
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];

    controller.title = itemConfig[@"title"];

    switch ([indexPath row])
    {
        case 0:
            [EBTrack event:EVENT_CLICK_QRCODE_SCANNER];
            break;
        case 1:
            [EBTrack event:EVENT_CLICK_LOAN_CALCULATOR];
            break;
        case 2:
            [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK];
            break;
        case 5:
            [EBTrack event:EVENT_CLICK_COLLECT_POST];
            break;
        default:
            break;
    }
}

#define CELL_LINE_WIDTH 1.f

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] % CELL_COL_NUM == CELL_COL_NUM - 1)
    {
        return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
    }
    return CGSizeMake(CELL_WIDTH  + CELL_LINE_WIDTH, CELL_HEIGHT);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCellView:(UICollectionViewCell *)cell withImage:(UIImage *)image title:(NSString *)title rightBorder:(BOOL)yes
{
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:CELL_TAG_IMAGE];
    UILabel *titleView = (UILabel *)[cell.contentView viewWithTag:CELL_TAG_LABEL];
    UIView *rightLine = (UILabel *)[cell.contentView viewWithTag:CELL_TAG_RIGHT_LINE];
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CELL_IMAGE_Y_START, CELL_WIDTH, CELL_IMAGE_HEIGHT)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.tag = CELL_TAG_IMAGE;
        [cell.contentView addSubview:imageView];

        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CELL_IMAGE_Y_START + CELL_IMAGE_HEIGHT +
                CELL_IMAGE_TITLE_GAP, CELL_WIDTH, CELL_LABEL_HEIGHT)];
        titleView.font = [UIFont systemFontOfSize:14.0];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = [UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1.0];
        titleView.tag = CELL_TAG_LABEL;
        [cell.contentView addSubview:titleView];

        // border
        UIColor *borderColor = AppMainColor(1);
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(-1.0, CELL_HEIGHT - CELL_LINE_WIDTH, CELL_WIDTH + 1, CELL_LINE_WIDTH)];
        bottomLine.backgroundColor = borderColor;
        [cell.contentView addSubview:bottomLine];

        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(-1.0, -1, CELL_WIDTH + 1, CELL_LINE_WIDTH)];
        topLine.backgroundColor = borderColor;
        [cell.contentView addSubview:topLine];

        rightLine = [[UIView alloc] initWithFrame:CGRectMake(CELL_WIDTH - CELL_LINE_WIDTH, -1.0, CELL_LINE_WIDTH, CELL_HEIGHT + 1)];
        rightLine.backgroundColor = borderColor;
        rightLine.tag = CELL_TAG_RIGHT_LINE;
        [cell.contentView addSubview:rightLine];
    }

    imageView.image = image;
    imageView.frame = CGRectMake(0.0, CELL_IMAGE_Y_START, CELL_WIDTH, CELL_IMAGE_HEIGHT);
    titleView.text = title;
    titleView.textColor = [UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1.0];
    rightLine.hidden = !yes;
    [cell.contentView viewWithTag:CELL_TAG_LABEL_FAILURE].hidden = YES;

}

- (void)updateCellForUpload:(UICollectionViewCell *)cell
{
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:CELL_TAG_IMAGE];
    UILabel *titleView = (UILabel *)[cell.contentView viewWithTag:CELL_TAG_LABEL];
    UILabel *titleFailure = (UILabel *)[cell.contentView viewWithTag:CELL_TAG_LABEL_FAILURE];

    NSInteger failureCount = [[EBHousePhotoUploader sharedInstance] failureCount];
    if (failureCount > 0)
    {
       if (!titleFailure)
       {
           titleFailure = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CELL_WIDTH, 19.0)];
           titleFailure.font = [UIFont systemFontOfSize:10.0];
           titleFailure.textAlignment = NSTextAlignmentCenter;
           titleFailure.textColor = [EBStyle darkRedTextColor];
           titleFailure.tag = CELL_TAG_LABEL_FAILURE;
           [cell.contentView addSubview:titleFailure];
       }

       imageView.frame = CGRectMake(0.0, CELL_IMAGE_Y_START + 5, CELL_WIDTH, CELL_IMAGE_HEIGHT);
       NSString *fFormat = NSLocalizedString(@"photo_failure_count", nil);
       titleFailure.text = [NSString stringWithFormat:fFormat, failureCount];

       imageView.image = [UIImage imageNamed:@"upload_red"];
       titleView.textColor = [EBStyle darkRedTextColor];
       titleFailure.hidden = NO;
    }
    else
    {
        imageView.frame = CGRectMake(0.0, CELL_IMAGE_Y_START, CELL_WIDTH, CELL_IMAGE_HEIGHT);
        titleView.textColor = [EBStyle lightGreenTextColor];
        titleFailure.hidden = YES;
        imageView.image = [UIImage imageNamed:@"upload_green"];
    }
}

- (void)updateCellForGather:(UICollectionViewCell *)cell
{
    CustomBadge *badge = (CustomBadge *)[cell.contentView viewWithTag:CELL_TAG_BADGE];
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
        badge.tag = CELL_TAG_BADGE;
        badge.frame = CGRectOffset(badgeFrame, btnFrame.size.width - badgeFrame.size.width - 22.0, 5.0);
        [cell.contentView addSubview:badge];
    }
    if (_unreadCountStr && _unreadCountStr.length > 0)
    {
        [badge autoBadgeSizeWithString:_unreadCountStr];
        if (_unreadCountStr.length >= 2)
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO_FINISHED from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_GATHER_UNREADCOUNT_CHANGED from:self selector:@selector(getUnreadCount)];
    [EBController observeNotification:NOTIFICATION_GATHER_READ from:self selector:@selector(getUnreadCount)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_VIDEO from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_VIDEO_FINISHED from:self selector:@selector(uploadingPhotoNotify:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUnreadCount];
    if (self.toolViewWillShow)
    {
        self.toolViewWillShow();
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)uploadingPhotoNotify:(NSNotification *)notification
{
    [_collectionView reloadData];
}

#pragma mark -Private Method

- (void)getUnreadCount
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getUnreadCount:^(BOOL success, id result)
     {
         if (success)
         {
             NSInteger unreadCount1 = [result[@"subscription"] integerValue];
             NSInteger unreadCount2 = [result[@"publish_failure"] integerValue];
             if (unreadCount1 + unreadCount2 > 99)
             {
                 _unreadCountStr = NSLocalizedString(@"gp_max_unread_count", nil);
             }
             else if(unreadCount1 + unreadCount2 == 0)
             {
                 _unreadCountStr = nil;
             }
             else
             {
                 _unreadCountStr = [NSString stringWithFormat:@"%ld", unreadCount1 + unreadCount2];
             }
             NSInteger row = [[EBHousePhotoUploader sharedInstance] isUploading] ? _toolsArray.count - 2 : _toolsArray.count - 1;
             [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil]];
         }
     }];
}

@end
