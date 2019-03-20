//
// Created by 何 义 on 14-2-18.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "SDWebImageManager.h"
#import "MainTabViewController.h"
#import "ClientViewController.h"
#import "HouseViewController.h"
#import "ConversationViewController.h"
#import "ToolViewController.h"
#import "HouseListViewController.h"
#import "EBSearch.h"
#import "EBPreferences.h"
#import "EBXMPP.h"
#import "EBIMManager.h"
#import "EBCache.h"
#import "EBNavigationController.h"
#import "EBUpdater.h"
#import "ChatViewController.h"
#import "WTStatusBar.h"
#import "EBContact.h"
#import "EBIMGroup.h"
#import "EBHousePhotoUploader.h"
#import "EBHttpClient.h"
#import "EBHouse.h"
#import "HouseDetailViewController.h"
#import "EBFilter.h"
#import "EBAlert.h"
#import "WorkBenchViewController.h"
#import "MChatViewController.h"
#import "MFindViewController.h"
#import "MeViewController.h"
#import "UITabBar+badge.h"
#import "ZHDCMeViewController.h"

@interface MainTabViewController()
{
    
}
@end

@implementation MainTabViewController

- (void)newSetupTabs{
   
    //需要改动
    WorkBenchViewController *workVc = [[WorkBenchViewController alloc] init];
    UINavigationController *workNav = [self navigationControllerWith:workVc];
    workNav.tabBarItem.title = @"工作台";
    workNav.tabBarItem.image = [UIImage imageNamed:@"工作台灰"];
    workNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"工作台红"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    workNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    
    ClientViewController *clientVc = [[ClientViewController alloc] init];
    UINavigationController *clientNav = [self navigationControllerWith:clientVc];
    clientNav.tabBarItem.title = @"客户";
    clientNav.tabBarItem.image = [UIImage imageNamed:@"客户灰"];
    clientNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"客户红"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    clientNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    
    
    ConversationViewController *mChatVc = [[ConversationViewController alloc] init];
    UINavigationController *chatNav = [self navigationControllerWith:mChatVc];
    chatNav.tabBarItem.title = @"微聊";
    chatNav.tabBarItem.image = [UIImage imageNamed:@"微聊灰"];
    chatNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"微聊红"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    chatNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    
    
    ZHDCMeViewController *meVc = [[ZHDCMeViewController alloc] init];
    UINavigationController *meNav = [self navigationControllerWith:meVc];
    meNav.tabBarItem.title = @"我";
    meNav.tabBarItem.image = [UIImage imageNamed:@"我的灰"];
    meNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"我的红"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    meNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    
    [self setViewControllers:@[workNav,clientNav, chatNav, meNav]];
    
    [self badgeNumberChanged:nil];
    if ([[EBHousePhotoUploader sharedInstance] isUploading])
    {
        if ([[EBHousePhotoUploader sharedInstance] failureCount] > 0)
        {
            [self showUpLoadState:EBPhoneUpLoadingFail];
        }
        else
        {
            [self showUpLoadState:EBPhoneUpLoadingNormal];
        }
    }
    
}


- (void)setupTabs
{
    WorkBenchViewController *workVc = [[WorkBenchViewController alloc] init];
    UINavigationController *workNav = [self navigationControllerWith:workVc];
    workNav.tabBarItem.title = @"工作台";
    workNav.tabBarItem.image = [UIImage imageNamed:@"tab_workbench"];
    workNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_workbench_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    workNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    
    ConversationViewController *mChatVc = [[ConversationViewController alloc] init];
    UINavigationController *chatNav = [self navigationControllerWith:mChatVc];
    chatNav.tabBarItem.title = @"微聊";
    chatNav.tabBarItem.image = [UIImage imageNamed:@"tab_chat"];
    chatNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_chat_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    chatNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);

    
    MFindViewController *mFindVc = [[MFindViewController alloc] init];
    UINavigationController *findNav = [self navigationControllerWith:mFindVc];
    findNav.tabBarItem.title = @"发现";
    findNav.tabBarItem.image = [UIImage imageNamed:@"tab_find"];
    findNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_find_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    findNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);

    
    MeViewController *meVc = [[MeViewController alloc] init];
    UINavigationController *meNav = [self navigationControllerWith:meVc];
    meNav.tabBarItem.title = @"我";
    meNav.tabBarItem.image = [UIImage imageNamed:@"tab_me"];
    meNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_me_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    meNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2.0);

    [self setViewControllers:@[workNav,chatNav, findNav, meNav]];
    
    [self badgeNumberChanged:nil];
    if ([[EBHousePhotoUploader sharedInstance] isUploading])
    {
        if ([[EBHousePhotoUploader sharedInstance] failureCount] > 0)
        {
            [self showUpLoadState:EBPhoneUpLoadingFail];
        }
        else
        {
            [self showUpLoadState:EBPhoneUpLoadingNormal];
        }
    }
}

- (void)showUpLoadState:(EBPhoneUpLoadState)state
{
    UIImageView *imageView = (UIImageView *)[self.tabBar viewWithTag:400];
    if (imageView)
    {
        [imageView removeFromSuperview];
    }
    UIImage *stateImage = nil;
    if (state == EBPhoneUpLoadingFail || state == EBPhoneUpLoadFail)
    {
        stateImage = [UIImage imageNamed:@"upload_state_error"];
    }
    else if (state == EBPhoneUpLoadingNormal)
    {
        stateImage = [UIImage imageNamed:@"upload_state_normal"];
    }
    else if (state == EBPhoneUpLoadSuccess)
    {
        stateImage = nil;
    }
//    UIImage *finalImage = [self scaleImage:stateImage toScale:0.7];
    imageView = [[UIImageView alloc] initWithImage:stateImage];
    imageView.tag = 400;
    CGRect frame = self.tabBar.frame;
    CGFloat toolWidth = 3 * frame.size.width / 4;
    imageView.frame = CGRectOffset(imageView.frame, toolWidth + 50, 6);
    [self.tabBar addSubview:imageView];
}

- (void)viewDidLoad
{
//    [self changeBadgeModeByRemove:YES];

    [super viewDidLoad];

//    [[EBSearch sharedInstance] setupSearchBarForController:self];
    [EBController sharedInstance].mainTabViewController = self;

    [SDWebImageManager sharedManager].delegate = [EBCache sharedInstance];

    if (![[EBCache sharedInstance] systemMessageSent])
    {
        [[EBIMManager sharedInstance] sendSystemEAllMessage];
//        [[EBIMManager sharedInstance] sendSystemCompanyMessage];
        [[EBCache sharedInstance] setSystemMessageSent];
    }
    
//    if (![[EBCache sharedInstance] systemNewHouseMessageSent])
//    {
//        [[EBIMManager sharedInstance] sendSystemNewHouseMessage];
//        [[EBCache sharedInstance] setSystemNewHouseMessageSent];
//    }

    [self badgeNumberChanged:nil];
    //即时通讯
    [EBController observeNotification:NOTIFICATION_MESSAGE_RECEIVE from:self selector:@selector(badgeNumberChanged:)];
    [EBController observeNotification:NOTIFICATION_MESSAGE_READ from:self selector:@selector(badgeNumberChanged:)];
    [EBController observeNotification:NOTIFICATION_VERSION_UPDATE from:self selector:@selector(badgeNumberChanged:)];
    [EBController observeNotification:NOTIFICATION_VERSION_NO_UPDATE from:self selector:@selector(badgeNumberChanged:)];
    [EBController observeNotification:NOTIFICATION_GATHER_UNREADCOUNT_CHANGED from:self selector:@selector(badgeNumberChanged:)];
    [EBController observeNotification:NOTIFICATION_GATHER_READ from:self selector:@selector(badgeNumberChanged:)];
    [EBController observeNotification:NOTIFICATION_GATHER_FIND from:self selector:@selector(findBadgeNumberChanged:)];

    [EBController observeNotification:NOTIFICATION_SYSTEM_MESSAGE_RECEIVE from:self selector:@selector(systemMessageReceived:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO_FINISHED from:self selector:@selector(uploadingPhotoNotify:)];
//    [self changeBadgeModeByRemove:YES];
}

- (void)changeBadgeModeByRemove:(BOOL)remove
{
    Class badgeClass = NSClassFromString(@"_UIBadgeView");
    for (NSInteger i = 0; i < self.tabBar.subviews.count; i++) {
        UIView *view = self.tabBar.subviews[i];
        if (view.subviews.count) {
            for (NSInteger j = 0; j < view.subviews.count; j++) {
                UIView *subview = view.subviews[j];
                if ([subview isKindOfClass:badgeClass]) {
                    NSLog(@"sub = %@",subview);
                    for (UIView *badgeViewBg in subview.subviews) {
                        if ([badgeViewBg isKindOfClass:NSClassFromString(@"_UIBadgeBackground")]) {
                            if (!remove){
                                UIView *badgeBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
                                badgeBg.backgroundColor = [UIColor redColor];
                                badgeBg.clipsToBounds = YES;
                                badgeBg.layer.cornerRadius = 6.f;
                                [subview addSubview:badgeBg];
                            }
                            [badgeViewBg removeFromSuperview];
                        }
                    }

                }
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    EBPreferences *pref = [EBPreferences sharedInstance];
    if (pref.houseIdForOpen && pref.houseIdForOpen.length > 0) {
        [[EBHttpClient sharedInstance] houseRequestWithOutWarn:@{@"id":pref.houseIdForOpen,
                                                      @"type":[EBFilter typeString:EHouseRentalTypeSale]}
                                             detail:^(BOOL success, id result)
         {
             if (success) {
                 EBHouse *house = [[EBHouse alloc] init];
                 house.id = pref.houseIdForOpen;
                 house.rentalState = EHouseRentalTypeSale;
                 HouseDetailViewController *viewController = [[HouseDetailViewController alloc] init];
                 viewController.houseDetail = house;
                 viewController.pageOpenType = EHouseDetailOpenTypeCommon;
                 viewController.hidesBottomBarWhenPushed = YES;
                 [[[EBController sharedInstance] currentNavigationController] pushViewController:viewController animated:YES];
             }
             else
             {
                 [EBAlert alertWithTitle:nil message:NSLocalizedString(@"house_open_by_meiliwu_deny_warn", nil) confirm:^{
                     
                 }];
             }
             pref.houseIdForOpen = @"";
             [pref writePreferences];
         }];
    }
}

- (void)systemMessageReceived:(NSNotification *)notification
{
    if (notification && [notification.object isKindOfClass:[EBIMMessage class]])
    {
        EBIMMessage *msg = notification.object;
        [WTStatusBar setStatusText:[msg subString] timeout:2.0 animated:YES];
    }
}
#pragma mark -- 上传图片的通知
- (void)uploadingPhotoNotify:(NSNotification *)notification
{
    NSString *msg;
    NSTimeInterval timeout = 0;
    EBHousePhotoUploader *uploader = [EBHousePhotoUploader sharedInstance];
//    UIViewController *settingViewController = self.viewControllers[3];
    if ([notification.name isEqualToString:NOTIFICATION_UPLOADING_PHOTO_FINISHED])
    {
         if (uploader.failureCount > 0)
         {
             //几张图片上传成功,几张上传失败
             NSString *format = NSLocalizedString(@"uploading_finished_with_failure", nil);
             msg = [NSString stringWithFormat:format, uploader.uploadingPhotos.count - uploader.failureCount, uploader.failureCount];
//             settingViewController.tabBarItem.badgeValue = @" ";
             [self showUpLoadState:EBPhoneUpLoadingFail];
         }
         else
         {
             msg = NSLocalizedString(@"uploading_finished", nil);
//             settingViewController.tabBarItem.badgeValue = nil;
             [self showUpLoadState:EBPhoneUpLoadSuccess];
         }
        timeout = 1.0;
    }
    else
    {
        NSString *format = NSLocalizedString(@"uploading_photo_progress", nil);
        msg = [NSString stringWithFormat:format, uploader.finishedCount, uploader.uploadingPhotos.count];


//        settingViewController.tabBarItem.badgeValue = @" ";
        [self showUpLoadState:EBPhoneUpLoadingNormal];
    }

    [WTStatusBar setStatusText:msg timeout:timeout animated:YES];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
     UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     return scaledImage;
}
- (void)findBadgeNumberChanged:(NSNotification *)notification
{
    UIViewController *messageViewController = self.viewControllers[2];
    NSDictionary *info = notification.object;
    if ([info[@"show"] integerValue]) {
        [messageViewController.tabBarController.tabBar showBadgeOnItemIndex:2];
    }else{
        [messageViewController.tabBarController.tabBar hideBadgeOnItemIndex:2];
    }
}
- (void)badgeNumberChanged:(NSNotification *)notification
{
    NSInteger count = [[EBIMManager sharedInstance] getUnreadCount];
    UIViewController *messageViewController = self.viewControllers[2];

    if (count > 0)
    {
        [messageViewController.tabBarController.tabBar showBadgeOnItemIndex:2];
    }
    else
    {
        [messageViewController.tabBarController.tabBar hideBadgeOnItemIndex:2];
    }

    UIViewController *mineViewController = self.viewControllers[3];
    if ([EBUpdater hasUpdate])
    {
        [mineViewController.tabBarController.tabBar showBadgeOnItemIndex:3];

    }
    else
    {
        [mineViewController.tabBarController.tabBar hideBadgeOnItemIndex:3];

    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    
    [self getUnreadCount:^(NSInteger unreadCount)
    {
        if (unreadCount > 0)
        {
            unreadCount += [EBUpdater hasUpdate] ? 1 : 0;
            NSString *unreadCountStr = [NSString stringWithFormat:@"%ld",unreadCount];
            if (unreadCount > 99)
            {
                unreadCountStr = NSLocalizedString(@"gp_max_unread_count", nil);
            }
//            mineViewController.tabBarItem.badgeValue = nil;
//            [mineViewController.tabBarController.tabBar showBadgeOnItemIndex:3];

            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count + unreadCount - ([EBUpdater hasUpdate] ? 1 : 0)];
        }
    }];
    if (notification && [notification.object isKindOfClass:[EBIMMessage class]])
    {
       EBIMMessage *msg = notification.object;
       UINavigationController *nav = (UINavigationController *)self.selectedViewController;
       UIViewController *topViewController = nav.topViewController;
       if (self.tabBar.isHidden)
       {
          BOOL showPush = YES;
          if ([topViewController isKindOfClass:[ChatViewController class]])
          {
             ChatViewController *chatViewController = (ChatViewController *)topViewController;
             if (chatViewController.conversation.id == msg.cvsnId)
             {
                showPush = NO;
             }
          }

          if (showPush)
          {
              NSString *subStr = [msg subString];
              [WTStatusBar setStatusText:[NSString stringWithFormat:@"%@%@", msg.sender.name == nil ? @"" : [NSString stringWithFormat:@"%@: ",msg.sender.name], subStr] timeout:2.0 animated:YES];
          }
       }
    }
//    [self changeBadgeModeByRemove:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UINavigationController *)navigationControllerWith:(UIViewController *)viewController
{
    EBNavigationController *nav = [[EBNavigationController alloc] initWithRootViewController:viewController];
    nav.navigationItem.backBarButtonItem.title = @" ";
//    nav.hidesBottomBarWhenPushed = YES;
    return nav;
}



#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController NS_AVAILABLE_IOS(3_0)
{
    return YES;
}

#pragma mark - Private Method

- (void)getUnreadCount:(void (^)(NSInteger))completion
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getUnreadCount:^(BOOL success, id result)
     {
         if (success)
         {
             NSInteger unreadCount1 = [result[@"subscription"] integerValue];
             NSInteger unreadCount2 = [result[@"publish_failure"] integerValue];
             completion(unreadCount1 + unreadCount2);
         }
     }];
}
@end
