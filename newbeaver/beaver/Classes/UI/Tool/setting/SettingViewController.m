//
//  SettingViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "SettingViewController.h"
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

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_settingArray;
    UITableView *_tableView;
    UITextField *_inputField;
    BOOL _anonymousCellEnable;
    BOOL _anonymousEnable;
    BOOL _subscriptionNotifyEnable;
}
@end

@implementation SettingViewController

#define SETTING_ROW_HEIGHT 44.0f

- (void)loadView
{
    [super loadView];
	self.navigationItem.title = NSLocalizedString(@"setting", nil);

    _anonymousCellEnable = YES;
    _anonymousEnable = YES;
    [self setupSettingArray];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 80)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, headerView.width -  2 * 15, 65)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [EBStyle blackTextColor];
    //    label.lineSpacing = 5.0f;
    
    EBPreferences *pref = [EBPreferences sharedInstance];
    EBContact *me = [[EBContactManager sharedInstance] contactById:pref.userId];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@（%@）\r\n%@\r\n%@（%@）", me.name,
                                                                                         pref.userAccount, me.department, pref.companyName, pref.companyCode]] ;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    label.attributedText = text;
    
    [headerView addSubview:label];
    
    _tableView.tableHeaderView = headerView;


    RTLabel *footer = [[RTLabel alloc] initWithFrame:CGRectMake(0, 40, [EBStyle screenWidth], 100)];
    footer.textAlignment = RTTextAlignmentCenter;
    footer.font = [UIFont systemFontOfSize:12.0];
    footer.textColor = [EBStyle grayTextColor];
    footer.lineSpacing = 5.0f;

    footer.text = [NSString stringWithFormat:NSLocalizedString(@"app_version_intro", nil), [EBUpdater localVersion]];

    UIView *viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 200)];
    [viewFooter addSubview:footer];
    _tableView.tableFooterView = viewFooter;
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
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row == 0)
    {
        ChangePasswordViewController *controller = [[ChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [EBTrack event:EVENT_CLICK_SETTINGS_CHANGE_PASSWORD];
    }
    else if (row == 1)
    {
        [EBAlert showLoading:NSLocalizedString(@"toast_sync_data", nil)];
        [[EBCache sharedInstance] synchronizeCompanyData:^(BOOL success)
        {
            [EBAlert hideLoading];
            if (success)
            {
                [EBAlert alertSuccess:NSLocalizedString(@"sync_success", nil)];
            }
        }];
    }
    else if (row == 2)
    {
        [EBTrack event:EVENT_CLICK_SETTINGS_ANONYMOUSE_PHONE];
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
        {
            NSString *title = nil;
            if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                if (title == nil) {
                    title = @"";
                }
            }
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
    else if (row == 4)
    {
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
    else if (row == _settingArray.count - 2)
    {
        if ([EBUpdater hasUpdate])
        {
            NSString *url = [EBUpdater newVersionUrl];
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:url]];
            [EBAlert showLoading:nil];
            dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC * 20, dispatch_get_main_queue(), ^
            {
               [EBAlert hideLoading];
            });
        }
        else
        {
           [EBAlert showLoading:nil];
           [[EBHttpClient sharedInstance] accountRequest:nil checkUpdate:^(BOOL success, id result)
           {
               [EBAlert hideLoading];
               if (success)
               {
                  if ([EBUpdater hasUpdate] && ![EBUpdater isForcedUpdate])
                  {
                      [_tableView reloadData];
                  }
                  else
                  {
                      [EBAlert alertSuccess:NSLocalizedString(@"update_no_new", nil)];
                  }
               }
           }];
        }
    }
    else if (row == _settingArray.count - 1)
    {
        [EBAlert confirmWithTitle:NSLocalizedString(@"logout", nil) message:NSLocalizedString(@"confirm_logout", nil)
                              yes:NSLocalizedString(@"confirm_logout_yes", nil) action:^
        {
            [EBController accountLoggedOut];
        }];

        [EBTrack event:EVENT_CLICK_SETTINGS_LOG_OUT];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_ROW_HEIGHT;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _settingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    const static NSString *cellIdentifier= @"cellForSet";

//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [EBStyle blueTextColor];
    cell.textLabel.text = [_settingArray objectAtIndex:[indexPath row]];

    if ([indexPath row] == _settingArray.count - 2 && [cell.contentView viewWithTag:99] == nil && [EBUpdater hasUpdate])
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
    
    if ([indexPath row] == 2)
    {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:77];
        if (label == nil)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 110, 44)];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = [EBStyle darkBlueTextColor];
            label.tag = 77;
        }

        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
        {
           label.text = NSLocalizedString(@"anonymous_unreadable", nil);
        }
        else if (_numStatus)
        {
            if (!_numStatus.enableAnonymous || [_numStatus.anonymousNumber length] < 1)
            {
                label.text = NSLocalizedString(@"anonymous_set_unstart", nil);
            }
            else if (_numStatus.canShowNumber)
            {
                NSString *showText;
                NSRange range = [_numStatus.anonymousNumber rangeOfString:@"-"];
                NSInteger location = range.location;
                if (location >= 0)
                {
                    NSArray *array = [_numStatus.anonymousNumber componentsSeparatedByString:@"-"];
                    if ([array count] > 1)
                    {
                        showText = [NSString stringWithFormat:@"%@%@%@",array[0], NSLocalizedString(@"anonymous_phone_set_fix_show_4", nil), array[1]];
                    }
                    else
                        showText = _numStatus.anonymousNumber;
                }
                else
                    showText = _numStatus.anonymousNumber;
                label.text = showText;
            }
            else
            {
                label.text = NSLocalizedString(@"anonymous_set_waitstart", nil);
            }
        }

        [cell.contentView addSubview:label];
    }
    else if ([indexPath row] == 3)
    {
        UISwitch *uiSwitch = (UISwitch *)[cell.contentView viewWithTag:88];
        if (uiSwitch == nil)
        {
            uiSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            CGRect frame = uiSwitch.frame;
            frame.origin.x = [EBStyle screenWidth] - frame.size.width - 10.0;
            frame.origin.y = (45.0 - frame.size.height) / 2;
            uiSwitch.frame = frame;
            [uiSwitch addTarget:self action:@selector(toggleSubscriptionNotify:) forControlEvents:UIControlEventValueChanged];
            uiSwitch.tag = 88;
            [cell.contentView addSubview:uiSwitch];
        }
        uiSwitch.on = _subscriptionNotifyEnable;
    }
    else if ([indexPath row] == 4)
    {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:77];
        if (label == nil)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 110, 44)];
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = [EBStyle darkBlueTextColor];
            label.font = [UIFont systemFontOfSize:12.0];
            label.tag = 77;
            [cell.contentView addSubview:label];
        }
        
        EBPreferences *pref = [EBPreferences sharedInstance];
        if (pref.rememberNoneImageChoice)
        {
            label.text = pref.allowImageDownloadViaWan ? NSLocalizedString(@"none_image_mode_2", nil) : NSLocalizedString(@"none_image_mode_1", nil);
        }
        else
        {
            label.text = NSLocalizedString(@"none_image_mode_0", nil);
        }
    }

    return cell;
}

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
    
//    if (_numStatus.enableAnonymous)
//    {
        _settingArray = @[NSLocalizedString(@"change_pwd", nil),
                          NSLocalizedString(@"sync_company_data", nil),
                          NSLocalizedString(@"anonymous_call_phone", nil),
                          NSLocalizedString(@"gather_subscription_notify", nil),
                          NSLocalizedString(@"none_image_mode_setting_title", nil), checkUpdate,
                          NSLocalizedString(@"logout", nil)];
//    }
//    else
//    {
//        _settingArray = @[NSLocalizedString(@"change_pwd", nil), NSLocalizedString(@"sync_company_data", nil),
//                          NSLocalizedString(@"none_image_mode_setting_title", nil), checkUpdate, NSLocalizedString(@"logout", nil)];
//    }
}


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
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getSetting:^(BOOL success, id result)
     {
        if (success)
        {
            NSDictionary *setting = result[@"setting"];
            if (setting)
            {
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

        if ([_numStatus.anonymousNumber length] < 1)
        {
            viewController.pageType = EAnonymousUnstart;
        }
        else if (_numStatus.canShowNumber)
        {
            viewController.pageType = EAnonymousStart;
        }
        else
        {
            viewController.pageType = EAnonymousWait;
        }

        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)toggleSubscriptionNotify:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"notify":uiSwitch.isOn ? @1 : @0} updateSetting:^(BOOL success, id result)
     {
     }];
}



@end
