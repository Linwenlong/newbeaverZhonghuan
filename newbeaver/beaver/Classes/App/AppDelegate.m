//
//  AppDelegate.m
//  qrcode
//
//  Created by 何 义 on 13-10-19.
//  Copyright (c) 2013年 crazyant. All rights reserved.
//

#import "DDTTYLogger.h"
#import "AppDelegate.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
#import "MainTabViewController.h"
#import "LoginViewController.h"
#import "EBPreferences.h"
#import "EBHttpClient.h"
#import "EBCache.h"
#import "EBAlert.h"
#import "EBController.h"
#import "EBXMPP.h"
#import "ShareManager.h"
#import "EBNavigationController.h"
#import "EBCompatibility.h"
#import "EBUpdater.h"
#import "EBContactManager.h"
#import "ADemoViewController.h"
#import "EBContact.h"
#import "EBIMGroup.h"
#import "EBIMManager.h"
#import "EBSearchViewController.h"
#import "EBHousePhotoUploader.h"
#import "EBPublishPhotoUploader.h"
#import "EBHouse.h"
#import "HouseDetailViewController.h"
#import "EBFilter.h"
#import "EBVideoUtil.h"
#import "EBFollowLogAddView.h"
#import "ERPWebViewController.h"
#import "IQKeyboardManager.h"
#import <UMSocialCore/UMSocialCore.h>
#import "JPUSHService.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

#import <UserNotifications/UserNotifications.h>

#endif


@interface AppDelegate ()<JPUSHRegisterDelegate>



@end


static NSString *kJupshappKey = @"2068e1c64325c1bf7e38084b";
static NSString *channel = @"Publish";
static BOOL isProduction = FALSE;

@implementation AppDelegate

//#define kSinaAppKey         @"3408221922"
//#define kSinaRedirectURI    @"http://"
//
//#define kWeChatAppId        @"wx3ded07dec6ec3f12"
#define kWeChatAppSecret       @"d81eb9c2b472fcaf32cd918d3f5b4054"

//#define kQQAppId            @"1105272855"

- (void)configUSharePlatforms
{
    /* 打开调试日志 */
//    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:MobClickappKey];
    
    //微信分享
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWeChatAppId appSecret:kWeChatAppSecret redirectURL:@"http://mobile.umeng.com/social"];
    //qq
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kQQAppId/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    //新浪微博
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3408221922"  appSecret:@"772b6a5cf84cc49acb4700ae3ba784d3" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
}

- (void)jPush:(NSDictionary *)launchOptions{
    
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc]init];
    
    entity.types = JPAuthorizationOptionAlert | JPAuthorizationOptionBadge | JPAuthorizationOptionSound;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
    }
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // 如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:kJupshappKey
                          channel:channel
                 apsForProduction:isProduction];
}


/**
 统计接口

 @param modular 统计类型
 */
- (void)statistics:(NSString *)modular{
    NSString *urlStr = @"http://218.65.86.92:8003/Customer/addCount";
    NSLog(@"userAccount=%@",[EBPreferences sharedInstance].userAccount);
    NSLog(@"city=%@",[EBPreferences sharedInstance].city);
    
    if ([EBPreferences sharedInstance].userAccount == nil || [[EBPreferences sharedInstance].userAccount isEqual:[NSNull null]]) {

        return;
    }
    if ([EBPreferences sharedInstance].city == nil || [[EBPreferences sharedInstance].city isEqual:[NSNull null]]) {

        return;
    }
   
    
    NSDictionary *dic = @{
                          @"user_id":[EBPreferences sharedInstance].userAccount,
                          @"city":[EBPreferences sharedInstance].city,
                          @"platform":@"iOS",
                          @"modular":modular,
                          @"type":@"beaver",
                          @"c_v":@"2.6",
                          @"c_p":@"android",
                          @"c_u":@"ad07c5df-9473-38b3-89a5-e6039c963237",
                          @"c_s":@"5c5356d8"
                          };
    NSLog(@"statisticsDic=%@",dic);
    [HttpTool get:urlStr parameters:dic success:^(id responseObject) {
        NSLog(@"responseObject=%@",responseObject);
        NSLog(@"modular - %@",modular);
    } failure:^(NSError *error) {
        NSLog(@"error=%@",error);
        
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [self startDemoUI];
//    return YES;
    [self initBaseURL];
    //键盘时间处理设置
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
//    [Fabric with:@[[Crashlytics class]]];
    
    [self jPush:launchOptions];
    //开启友盟统计
    [EBTrack start];
    
    //公司统计
//    [self statistics:@"StartTimes"];

    //友盟分享
    [self configUSharePlatforms];
    
    //设置日志打印
    [self setupDDLogger];
    //单例设置app的一些熟悉
    EBPreferences *pref = [EBPreferences sharedInstance];
    //网络监控
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_NETWORK_STATUS_CHANGED object:nil]];

        if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            if (!pref.rememberNoneImageChoice){
                [[EBController sharedInstance] promptNoneImageMode:^
                {
                     if (!pref.allowImageDownloadViaWan){
                         [EBAlert alertSuccess:NSLocalizedString(@"none_image_mode_switched", nil) length:1.0];
                     }
                }];
            }
            else{
                if (!pref.allowImageDownloadViaWan){
                    [EBAlert alertSuccess:NSLocalizedString(@"none_image_mode_switched", nil) length:1.0];
                }
            }
        }
        if ([AFNetworkReachabilityManager sharedManager].reachable && [pref isTokenValid])
        {
           [self startAndCheck];
        }
    }];
    [reachabilityManager startMonitoring];
    //监测登录的通知
    [EBController observeNotification:NOTIFICATION_LOGIN from:self selector:@selector(loggedIn)];
    //监测登出的通知
    [EBController observeNotification:NOTIFICATION_LOGOUT from:self selector:@selector(logout)];
    //强制更新版本
    [EBController observeNotification:NOTIFICATION_VERSION_FORCE_UPDATE from:self selector:@selector(doForceUpgrade)];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.window makeKeyAndVisible];
    [EBCompatibility setupGlobalAppearance];
//    [self startLoginUI];
    if ([pref isTokenValid]){
        [self startMainUI];
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (userInfo)
        {
            [self handlePushNotification:userInfo fromLaunch:YES];
        }
    }else{
        [self startLoginUI];
    }
    return YES;
}

#pragma mark -- 初始化请求的url的ip跟端口，h5中获取url,

- (void)initBaseURL{
    //一段时候后闪退
//    // 登录授权对应公司编码匹配文件地址（Kevin）
//#define BEAVER_AUTHORIZE_JSON_URL @"http://ncimgcdn.zhdclink.com/api/mse/zhmse.json?arc_time=%ld"
    NSString *jsonUrl = [NSString stringWithFormat:BEAVER_AUTHORIZE_JSON_URL,(long)arc4random()/1000000];
    NSLog(@"jsonUrl=%@",jsonUrl);
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonUrl]];
     NSLog(@"data=%@",data);
    if (data == nil) {
        NSLog(@"未获取到服务器地址");
       [EBAlert alertError:@"未获取到服务器地址"];
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    NSString *baseUrl = dict[@"url"];
    if ([baseUrl hasPrefix:@"http"]) {
        [EBPreferences sharedInstance].baseUrl = baseUrl;//上线
        if (PORT == 1) {
            [EBPreferences sharedInstance].baseUrl = baseUrl;//上线
        }else{
            [EBPreferences sharedInstance].baseUrl = @"http://192.168.2.140:8010/";//测试
            
            
//            [EBPreferences sharedInstance].baseUrl = @"http://117.40.248.135:8010/";//测试
//            [EBPreferences sharedInstance].baseUrl = @"http://218.65.86.80:8010/";//测试
        }
        [[EBPreferences sharedInstance] writePreferences];
    }else{
        [EBAlert alertError:@"未获取到服务器地址"];
        return;
    }
}


#pragma mark -- 登录接口
- (void)loggedIn
{
    
    //同步数据 toast_sync_data
    [EBAlert showLoading:NSLocalizedString(@"toast_sync_data", nil)];
    [[EBCache sharedInstance] synchronizeCompanyData:^(BOOL success)
    {
        if (success){
            
            [EBController broadcastNotification:[NSNotification notificationWithName:@"refreshAnimation" object:nil]];
            
            CATransition * anim = [CATransition animation];
            anim.type = @"rippleEffect";
            anim.duration = 0.5;
            [self.loginView.view.layer addAnimation:anim forKey:@"animation"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startMainUI];
            });
            
//            [self startMainUI];
        
            //XMPP登录
            [[EBXMPP sharedInstance] login];
        }
       [EBAlert hideLoading];
    }];
}

- (void)logout
{
    [EBController sharedInstance].mainTabViewController = nil;
    [self startLoginUI];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    if ([[EBPreferences sharedInstance] isTokenValid])
    {
        [[EBXMPP sharedInstance] logout];
        [[EBHousePhotoUploader sharedInstance] pauseUploading];
        [[EBPublishPhotoUploader sharedInstance] pauseUploading];
        
        [EBVideoUtil stop];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([[EBPreferences sharedInstance] isTokenValid])
    {
        [self startAndCheck];
        
        [EBVideoUtil resume];
    }
    else
    {
        if ([self.window.rootViewController isKindOfClass:[MainTabViewController class]])
        {
            [self startLoginUI];
        }
    }

    [[EBCache sharedInstance] clearExpiredCache];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ERPWebViewController sharedInstance] cleanCache];
}

- (void)startDemoUI
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    EBSearchViewController *demoViewController = [[EBSearchViewController alloc] init];
    self.window.rootViewController = [[EBNavigationController alloc] initWithRootViewController:demoViewController];
}

- (void)startLoginUI
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    self.loginView = loginViewController;
    self.window.rootViewController = [[EBNavigationController alloc] initWithRootViewController:loginViewController];
}

//进入主页
- (void)startMainUI
{
    MainTabViewController *mainTab = [[MainTabViewController alloc] init];
    [mainTab newSetupTabs];
    self.window.rootViewController = mainTab;

    // 启动wap页面
    ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
    NSLog(@"erpVc=%@",[EBPreferences sharedInstance].wapToken);
    erpVc.token = [EBPreferences sharedInstance].wapToken;
    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        [self registNotificationFor8];
    } else {
        // use registerForRemoteNotifications
        [self registNotificationForUnder8];
    }
#else
    // use registerForRemoteNotifications
    [self registNotificationForUnder8];
#endif
}
#pragma mark -- 打印设置
- (void)setupDDLogger
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
}

#pragma mark -- JPUSHRegisterDelegate

/*
 * @brief handle UserNotifications.framework [willPresentNotification:withCompletionHandler:]
 * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
 * @param notification 前台得到的的通知对象
 * @param completionHandler 该callback中的options 请使用UNNotificationPresentationOptions
 */

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler{
    
    
    NSLog(@"%s",__func__);
    
    NSLog(@"notification=%@",notification);
    
    NSString *body = notification.request.content.body;
    
    [EBAlert alertWithTitle:@"提醒" message:body confirm:^{
        NSLog(@"谢谢");
    }];
    
}

/*
 * @brief handle UserNotifications.framework [didReceiveNotificationResponse:withCompletionHandler:]
 * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
 * @param response 通知响应对象 从后面添加
 * @param completionHandler
 */
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    NSLog(@"%s",__func__);
    
    
    
}

/*
 * @brief handle UserNotifications.framework [openSettingsForNotification:]
 * @param center [UNUserNotificationCenter currentNotificationCenter] 新特性用户通知中心
 * @param notification 当前管理的通知对象
 */
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification NS_AVAILABLE_IOS(12.0){
    NSLog(@"%s",__func__);
}


#pragma mark -- 接收通知
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    
    [JPUSHService registerDeviceToken:deviceToken];
    return;
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *dToken = [NSString stringWithFormat:@"%@", deviceToken];
    if (!pref.deviceTokenGot || ![pref.deviceToken isEqualToString:dToken] )
    {
        [[EBHttpClient sharedInstance] accountRequest:@{@"push_token" : dToken} registerPushToken:
                ^(BOOL success, id result)
                {
                    if (success == NO) {
                        return ;
                    }
                    pref.deviceTokenGot = success;
                    pref.deviceToken = dToken;
                    [pref writePreferences];
                }];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark -- 检查版本更新
- (void)startAndCheck
{
    
    
    if ([EBUpdater hasUpdate] && [EBUpdater isForcedUpdate])
    {
//        [self doForceUpgrade];
    }
    else
    {
        [[EBCache sharedInstance] synchronizeCompanyData:^(BOOL success){}];
        [[EBXMPP sharedInstance] login];
        if ([[EBHousePhotoUploader sharedInstance] checkUploading]) {
            [[EBHousePhotoUploader sharedInstance] resumeUploading];
        }
        if ([[EBPublishPhotoUploader sharedInstance] checkUploading]) {
            [[EBPublishPhotoUploader sharedInstance] resumeUploading];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [EBPreferences sharedInstance].deviceTokenGot = NO;
    [[EBPreferences sharedInstance] writePreferences];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
   return  [[UMSocialManager defaultManager] handleOpenURL:url];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state != UIApplicationStateActive)
    {
        [self handlePushNotification:userInfo fromLaunch:NO];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *chowUrl = [[[url absoluteString] componentsSeparatedByString:@":"] firstObject];
    if ([chowUrl isEqualToString:@"beaverDev"]) {
        EBPreferences *pref = [EBPreferences sharedInstance];
        pref.houseIdForOpen = [[[url absoluteString] componentsSeparatedByString:@":"] lastObject];
        if (pref.token && pref.token.length > 0) {
            [self startMainUI];
//            [[EBHttpClient sharedInstance] houseRequestWithOutWarn:@{@"id":pref.houseIdForOpen,
//                                                          @"type":[EBFilter typeString:EHouseRentalTypeSale]}
//                                                 detail:^(BOOL success, id result)
//             {
//                 if (success) {
//                     EBHouse *house = [[EBHouse alloc] init];
//                     house.id = pref.houseIdForOpen;
//                     house.rentalState = EHouseRentalTypeSale;
//                     HouseDetailViewController *viewController = [[HouseDetailViewController alloc] init];
//                     viewController.houseDetail = house;
//                     viewController.pageOpenType = EHouseDetailOpenTypeCommon;
//                     viewController.hidesBottomBarWhenPushed = YES;
//                     [[[EBController sharedInstance] currentNavigationController] pushViewController:viewController animated:YES];
//                 }
//                 else
//                 {
//                     [EBAlert alertWithTitle:nil message:NSLocalizedString(@"house_open_by_meiliwu_deny_warn", nil) confirm:^{
//                         
//                     }];
//                 }
//                 pref.houseIdForOpen = @"";
//                 [pref writePreferences];
//             }];
        }
        else
        {
            [self startLoginUI];
        }
    }
    return [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark -- 强制更新版本
- (void)doForceUpgrade
{
   static BOOL isUpgrading = NO;
   if (!isUpgrading)
   {
       isUpgrading = YES;
       [EBAlert showLoading:nil];
       [[EBHttpClient wapInstance] wapRequest:nil checkUpdate:^(BOOL success, id result)
       {
           // make sure to get the new download url.
           [EBAlert hideLoading];
           if (success && [EBUpdater isForcedUpdate])
           {
               [EBAlert alertWithTitle:nil message:NSLocalizedString(@"force_update", nil) yes:NSLocalizedString(@"force_update_confirm", nil)
                               confirm:^
                               {
                                   isUpgrading = NO;
                                   [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[EBUpdater newVersionUrl]]];
                               }];
           }
           else
           {
               isUpgrading = NO;
           }
       }];
   }
}

- (void)handlePushNotification:(NSDictionary *)msg fromLaunch:(BOOL)fromLaunch
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if ([self.window.rootViewController isKindOfClass:[MainTabViewController class]])
    {
        id type = msg[@"t"];
        if (type && [type integerValue] == 99)
        {
            [EBController sharedInstance].mainTabViewController.selectedIndex = 1;
            [[EBController sharedInstance].currentNavigationController popToRootViewControllerAnimated:NO];
            dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
            {
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_SHOW_INVITE object:nil]];
            });
        }
        else if (type && [type integerValue] == 95)
        {
            [[EBController sharedInstance] openGatherView:EGatherViewTypeSubscription];
        }
        else if (type && [type integerValue] == 96)
        {
            [[EBController sharedInstance] openPublishRecordView];
        }
        else
        {
            NSString *from = msg[@"u"];

            if (from)
            {
                NSString *gid = msg[@"g"];
                if (gid)
                {
                   EBIMGroup *group = [[EBIMManager sharedInstance] groupFromId:gid];
                   if (group)
                   {
                       [EBController sharedInstance].mainTabViewController.selectedIndex = 2;
                       dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
                       {
                          [[EBController sharedInstance] openGroupChat:group popToConversation:YES];
                       });
                   }
                }
                else
                {
                    EBContact *contact = [[EBContactManager sharedInstance] contactById:from];
                    if (contact && !contact.notFound)
                    {
                        [EBController sharedInstance].mainTabViewController.selectedIndex = 2;
                        dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
                        {
                            [[EBController sharedInstance] startChattingWith:@[contact] popToConversation:YES];
                        });
                    }
                }
            }
        }
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    
}

#pragma mark -- 配置接收通知的类型
- (void)registNotificationForUnder8{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
}

- (void)registNotificationFor8{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

@end
