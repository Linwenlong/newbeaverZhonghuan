//
//  MeViewController.m
//  beaver
//  我
//  Created by zhaoyao on 15/12/16.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "MeViewController.h"
#import "ChangePasswordViewController.h"
#import "EBViewFactory.h"
#import "EBAlert.h"
#import "EBController.h"
#import "RTLabel.h"
#import "EBPreferences.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBCache.h"
#import "EBUpdater.h"
#import "EBHttpClient.h"
#import "CustomBadge.h"
#import "AnonymousCallViewController.h"
#import "UITabBar+badge.h"
#import "MapTrackViewController.h"

@interface MeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_settingArray;//cell的一些参数
    UITableView *_tableView;
    UITextField *_inputField;
    BOOL _anonymousCellEnable;
    BOOL _anonymousEnable;
    BOOL _subscriptionNotifyEnable;
    
     NSArray * sectionArray;
}


@end

@implementation MeViewController

#define SETTING_ROW_HEIGHT 60.0f

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = @"设置";
    _anonymousCellEnable = YES;
    _anonymousEnable = YES;
    [self setupSettingArray];
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}


- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkAnonymousTelStatus:nil];
    [self getSubscriptionNotifyState];
    [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
}
//隐藏左箭头
- (void)hiddenleftNVItem
{
    self.navigationItem.leftBarButtonItem=nil;
}

#pragma mark - UITableViewDelegate
#define KEY_UPDATE_FORCE @"EB_FORCED_UPDATE"//强制更新
#define KEY_NEW_VERSION @"EB_ONLINE_VERSION"//线上版本
#define KEY_CURRECT_VERSION @"EB_CURRECT_VERSION"//当前版本
#define KEY_NEW_VERSION_URL @"EB_ONLINE_VERSION_URL"//线上版本url

//点击cell事件

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    if (section == 0 && row == 0)
    {
        ChangePasswordViewController *controller = [[ChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        //友盟统计改密码的次数
        [EBTrack event:EVENT_CLICK_SETTINGS_CHANGE_PASSWORD];
    }
    else if (section == 1 && row == 0)
    {
//        "toast_sync_data" = "正在同步数据...";
        [EBAlert showLoading:NSLocalizedString(@"toast_sync_data", nil)];
        //同步公司数据 （通讯录，小区信息）
        [[EBCache sharedInstance] synchronizeCompanyData:^(BOOL success)
         {
             [EBAlert hideLoading];
             if (success)
             {
                 [EBAlert alertSuccess:NSLocalizedString(@"sync_success", nil)];
             }
         }];
    }
    else if (section == 1 && row == 1)
    {
        //设置引号功能统计
        [EBTrack event:EVENT_CLICK_SETTINGS_ANONYMOUSE_PHONE];
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
        {
            NSString *title = nil;
            if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                if (title == nil) {
                    title = @"";
                }
            }
//            "anonymous_not_readable" = "目前无法连接网络，无法获悉贵公司是否已启用隐号通话功能，也无法读取正在使用的隐号通话电话号码。";
//            "yes_got_it" = "知道了";
            [[[UIAlertView alloc] initWithTitle:title
                                        message:NSLocalizedString(@"anonymous_not_readable", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"yes_got_it", nil) otherButtonTitles:nil] show];
        }
        else
        {
            [self checkAnonymousTelStatus:^(BOOL successful, NSDictionary *response) {
                if (successful)
                {
                    if (!_numStatus.enableAnonymous)
                    {
                        NSString *title = nil;
                        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                            if (title == nil) {
                                title = @"";
                            }
                        }
                        [[[UIAlertView alloc] initWithTitle:title
                                                    message:NSLocalizedString(@"anonymous_enable_propmt", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"yes_got_it", nil) otherButtonTitles:nil] show];
                    }
                    else
                    {
                        [self showAnonymousCallView];
                    }
                }
            }];
        }
    }
    else if (section == 1 && row == 3)
    {
        
        
        //        "prompt_none_image_mode" = "您的手机正在使用蜂窝数据网络（未连接 Wi-Fi），是否切换到无图模式，以节省流量？";
        //        "prompt_none_image_mode_yes" = "是，切换到无图模式";
        //        "prompt_none_image_mode_no" = "否";
        //        "prompt_none_image_mode_remember_choice" = "记住选择";
        //        "none_image_mode_switched" = "已切换到无图模式";
        //        "none_image_mode_setting_title" = "无图模式";
        //        "none_image_mode_setting_hint" = "用蜂窝网络数据时切换至无图模式：";
        //        "none_image_mode_0" = "每次询问";
        //        "none_image_mode_1" = "自动";
        //        "none_image_mode_2" = "不切换";
        //        "none_image_mode_desc" = "切换至无图模式时，不自动下载房源照片，以节省流量。\n\n连接Wi-Fi时，会自动关闭无图模式（恢复自动下载房源照片）。";
        //
        //        "anonymous_call__remember_choice" = "不再提示";
        //        "anonymous_call_nav" = "和普通通话不同，使用隐号通话时，您会先接到呼叫中心的电话，您接听后等候对方接听。隐号通话将会全程录音。";
        
        EBPreferences *pref = [EBPreferences sharedInstance];
        NSInteger choice = 0;
        if (pref.rememberNoneImageChoice)
        {
            choice = pref.allowImageDownloadViaWan ? 2 : 1;
        }
        
        NSArray *choices = @[NSLocalizedString(@"none_image_mode_0", nil),
                             NSLocalizedString(@"none_image_mode_1", nil), NSLocalizedString(@"none_image_mode_2", nil)];
        [[EBController sharedInstance] promptChoices:choices withChoice:choice title:NSLocalizedString(@"none_image_mode_setting_title", nil)
                                              header:NSLocalizedString(@"none_image_mode_setting_hint", nil)
                                              footer:NSLocalizedString(@"none_image_mode_desc", nil) completion:^(NSInteger rightChoice)
         {
             if (rightChoice == 0)
             {
                 pref.rememberNoneImageChoice = NO;
             }
             else
             {
                 pref.rememberNoneImageChoice = YES;
                 pref.allowImageDownloadViaWan = rightChoice == 2;
             }
             [pref writePreferences];
             [_tableView reloadData];
         }];
    }
    else if (section == 1 && row == 4)
    {
        //检查是否可以更新
        
        if ([EBUpdater hasUpdate])
        {
            NSString *url = [EBUpdater newVersionUrl];
//            NSLog(@"url=%@",url);
            //检测到版本后就掉转
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:url]];
            [EBAlert showLoading:nil];
            //gcd里面的多久之后执行方法
            dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC * 20, dispatch_get_main_queue(), ^
                           {
                               [EBAlert hideLoading];
                           });
        }else{
            //更新版本
            [EBAlert showLoading:nil];
            [[EBHttpClient wapInstance] wapRequest:nil checkUpdate:^(BOOL success, id result)
             {
                 [EBAlert hideLoading];
                 if (success){
                     NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//                    NSString *currentVersion = @"1.0.2";
                     NSString *newVersion = result[@"version"];
//                     NSLog(@"newVersion");
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setObject:result[@"version"] forKey:KEY_NEW_VERSION];
                     [defaults setObject:result[@"url"] forKey:KEY_NEW_VERSION_URL];
                     [defaults setBool:[result[@"force"] boolValue] forKey:KEY_UPDATE_FORCE];
                     [defaults synchronize];
                     if (![currentVersion isEqualToString:newVersion]) {
                         if (![result[@"force"] boolValue]) {
                             [EBAlert alertWithTitle:nil message:NSLocalizedString(@"force_update", nil) yes:NSLocalizedString(@"force_update_confirm",nil) no:@"取消" confirm:^{
                                 [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[EBUpdater newVersionUrl]]];
                             }];
                         }else{
                             [EBUpdater newVersionAvailable:result[@"version"] url:result[@"url"] force:[result[@"force"] boolValue]];
                         }
                         [self setupSettingArray];
                         [_tableView reloadData];
                     }else{
                         [EBAlert alertSuccess:NSLocalizedString(@"update_no_new", nil)];
                     }
                 }
             }];
        }
    }else if (section == 1 && row == 5){
        [EBAlert confirmWithTitle:NSLocalizedString(@"logout", nil) message:NSLocalizedString(@"confirm_logout", nil)
                              yes:NSLocalizedString(@"confirm_logout_yes", nil) action:^{
             [EBController accountLoggedOut];
         }];
        [EBTrack event:EVENT_CLICK_SETTINGS_LOG_OUT];
    }else if (section == 1 && row == 2){
        NSLog(@"暂无功能");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_ROW_HEIGHT;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _settingArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tmpArray = _settingArray[section];
    return tmpArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    NSArray *settingtmp = _settingArray [indexPath.section];
    NSArray *sectiontmp = sectionArray[indexPath.section];
    cell.textLabel.text = settingtmp[indexPath.row];
    
    //修改图片尺寸大小
    UIImage *icon = [UIImage imageNamed:sectiontmp[indexPath.row]];
    CGSize itemSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    if (indexPath.section == 0) {
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *accessory = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7, 11)];
        accessory.image = [UIImage imageNamed:@"jiantou"];
        cell.accessoryView = accessory;
    }
    
    //检查更新显示
    if (indexPath.row == 4 && [cell.contentView viewWithTag:99] == nil && [EBUpdater hasUpdate])
    {
        CustomBadge *badge = [CustomBadge customBadgeWithString:@"1"
                                                withStringColor:[UIColor whiteColor]
                                                 withInsetColor:[EBStyle redTextColor]
                                                 withBadgeFrame:NO
                                            withBadgeFrameColor:[UIColor whiteColor]
                                                      withScale:10.0/13.5
                                                    withShining:NO];
        badge.tag = 99;
        badge.frame = CGRectOffset(badge.frame, 120, 22 - badge.frame.size.height / 2);
        
        [cell.contentView addSubview:badge];
    }

    
    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    const static NSString *cellIdentifier= @"cellForSet";
//    
//    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
//    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
//    
//    cell.textLabel.text = [_settingArray objectAtIndex:[indexPath row]];
//    
//    
//    //需要更新
//    if ([indexPath row] == _settingArray.count - 2 && [cell.contentView viewWithTag:99] == nil && [EBUpdater hasUpdate])
//    {
//        CustomBadge *badge = [CustomBadge customBadgeWithString:@"1"
//                                                withStringColor:[UIColor whiteColor]
//                                                 withInsetColor:[EBStyle redTextColor]
//                                                 withBadgeFrame:NO
//                                            withBadgeFrameColor:[UIColor whiteColor]
//                                                      withScale:10.0/13.5
//                                                    withShining:NO];
//        badge.tag = 99;
//        badge.frame = CGRectOffset(badge.frame, 120, 22 - badge.frame.size.height / 2);
//        
//        [cell.contentView addSubview:badge];
//    }
//    
//    if ([indexPath row] == 2)
//    {
//        UILabel *label = (UILabel *)[cell.contentView viewWithTag:77];
//        if (label == nil)
//        {
//            label = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 110, 44)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:12.0];
//            label.textColor = [EBStyle darkBlueTextColor];
//            label.tag = 77;
//        }
//        
//        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
//        {
//            label.text = NSLocalizedString(@"anonymous_unreadable", nil);
//        }
//        else if (_numStatus)
//        {
//            if (!_numStatus.enableAnonymous || [_numStatus.anonymousNumber length] < 1)
//            {
//                label.text = NSLocalizedString(@"anonymous_set_unstart", nil);
//            }
//            else if (_numStatus.canShowNumber)
//            {
//                NSString *showText;
//                NSRange range = [_numStatus.anonymousNumber rangeOfString:@"-"];
//                NSInteger location = range.location;
//                if (location >= 0)
//                {
//                    NSArray *array = [_numStatus.anonymousNumber componentsSeparatedByString:@"-"];
//                    if ([array count] > 1)
//                    {
//                        showText = [NSString stringWithFormat:@"%@%@%@",array[0], NSLocalizedString(@"anonymous_phone_set_fix_show_4", nil), array[1]];
//                    }
//                    else
//                        showText = _numStatus.anonymousNumber;
//                }
//                else
//                    showText = _numStatus.anonymousNumber;
//                label.text = showText;
//            }
//            else
//            {
//                label.text = NSLocalizedString(@"anonymous_set_waitstart", nil);
//            }
//        }
//        
//        [cell.contentView addSubview:label];
//    }
//    else if ([indexPath row] == 3)
//    {
//        UISwitch *uiSwitch = (UISwitch *)[cell.contentView viewWithTag:88];
//        if (uiSwitch == nil)
//        {
//            uiSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
//            CGRect frame = uiSwitch.frame;
//            frame.origin.x = [EBStyle screenWidth] - frame.size.width - 10.0;
//            frame.origin.y = (45.0 - frame.size.height) / 2;
//            uiSwitch.frame = frame;
//            [uiSwitch addTarget:self action:@selector(toggleSubscriptionNotify:) forControlEvents:UIControlEventValueChanged];
//            uiSwitch.tag = 88;
//            [cell.contentView addSubview:uiSwitch];
//        }
//        uiSwitch.on = _subscriptionNotifyEnable;
//    }
//    else if ([indexPath row] == 4)
//    {
//        UILabel *label = (UILabel *)[cell.contentView viewWithTag:77];
//        if (label == nil)
//        {
//            label = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 110, 44)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.textColor = [EBStyle darkBlueTextColor];
//            label.font = [UIFont systemFontOfSize:12.0];
//            label.tag = 77;
//            [cell.contentView addSubview:label];
//        }
//        
//        
//        EBPreferences *pref = [EBPreferences sharedInstance];
//        if (pref.rememberNoneImageChoice)
//        {
//            label.text = pref.allowImageDownloadViaWan ? NSLocalizedString(@"none_image_mode_2", nil) : NSLocalizedString(@"none_image_mode_1", nil);
//        }
//        else
//        {
//            label.text = NSLocalizedString(@"none_image_mode_0", nil);
//        }
//    }
//    
//    return cell;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSettingArray
{
    NSString *checkUpdate;
    if ([EBUpdater hasUpdate])
    {
        checkUpdate = [NSString stringWithFormat:NSLocalizedString(@"update_download", nil), [EBUpdater currentOnlineVersion]];
    }
    else
    {
        checkUpdate = NSLocalizedString(@"update_check", nil);
    }
//    "update_check" = "检查更新";
//    "update_download" = "下载新版v%@";
    //    if (_numStatus.enableAnonymous)
    //    {
    // cell 上面的一些配置参数
    _settingArray = @[@[NSLocalizedString(@"change_pwd", nil)],
                      @[NSLocalizedString(@"sync_company_data", nil),
                      NSLocalizedString(@"anonymous_call_phone", nil),
                      NSLocalizedString(@"gather_subscription_notify", nil),
                      NSLocalizedString(@"none_image_mode_setting_title", nil), checkUpdate,
                      NSLocalizedString(@"logout", nil)]];
    sectionArray = @[@[@"修改密码"],
                      @[@"同步公司数据",
                      @"无图模式", @"检查更新",
                     @"退出登录"]];
}


//检查同步的tel
- (void)checkAnonymousTelStatus:(void(^)(BOOL successful, NSDictionary *response))handler
{
    [[EBHttpClient sharedInstance] accountRequest:nil getNumberStatus:^(BOOL success, id result)
     {
         if (success)
         {
             _numStatus = result;
             if (_numStatus.enableAnonymous)
             {
                 _anonymousEnable = YES;
                 _anonymousCellEnable = YES;
             }
             if (handler) {
                 handler(success,result);
             }
             [self setupSettingArray];
             [_tableView reloadData];
         }
     }];
}

- (void)getSubscriptionNotifyState
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getSetting:^(BOOL success, id result){
         if (success){
             NSDictionary *setting = result[@"setting"];
             if (setting){
                 _subscriptionNotifyEnable = [setting[@"notify"] boolValue];
                 [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
             }
         }
     }];
}

- (void)showAnonymousCallView
{
    if (_anonymousCellEnable)
    {
        AnonymousCallViewController *viewController = [[AnonymousCallViewController alloc] init];
        viewController.anonymousNum = _numStatus.anonymousNumber.length ? _numStatus.anonymousNumber : _numStatus.tel;
        
        if ([_numStatus.anonymousNumber length] < 1){
            viewController.pageType = EAnonymousUnstart;
        }
        else if (_numStatus.canShowNumber){
            viewController.pageType = EAnonymousStart;
        }
        else{
            viewController.pageType = EAnonymousWait;
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

//更新UISwitch的状态
- (void)toggleSubscriptionNotify:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"notify":uiSwitch.isOn ? @1 : @0} updateSetting:^(BOOL success, id result){
     }];
}



@end
