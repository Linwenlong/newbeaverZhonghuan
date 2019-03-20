//
//  ChangePasswordViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "ProfileViewController.h"
#import "EBViewFactory.h"
#import "EBAlert.h"
#import "EBContact.h"
#import "UIImage+Alpha.h"
#import "EBController.h"
#import "EBPreferences.h"
#import "ShareManager.h"

@interface ProfileViewController() <UITableViewDataSource, UITableViewDelegate, ABNewPersonViewControllerDelegate>
{
    UITableView *_tableView;
}

@end

@implementation ProfileViewController

- (void)loadView
{
    [super loadView];

    self.navigationItem.title = _contact.name;
    UITableView *tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];

    tableView.tableHeaderView = [self buildAvatarView];
    tableView.tableFooterView = [self buildFooterView];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
    _tableView = nil;
}

- (UIView *)buildAvatarView
{
    UIImageView *avatar = [EBViewFactory avatarImageView:110];

    //通讯录 图片
    avatar.image = [EBViewFactory imageFromGender:_contact.gender big:YES];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 160)];
    avatar.frame = CGRectOffset(avatar.frame, 105, 25);
    avatar.centerX = view.centerX;
    [view addSubview:avatar];

    return view;
}

- (UIView *)buildFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
    CGFloat yOffset = 25;
    if (![_contact.userId isEqualToString:[EBPreferences sharedInstance].userId])
    {
        [view addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(15, yOffset, [EBStyle screenWidth] -30, 36)
                                                      title:NSLocalizedString(@"profile_btn_send_im", nil)
                                                     target:self action:@selector(sendIM)]];
        yOffset += 36 + 15;
    }
    if (!_contact.special)
    {
        [view addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(15, yOffset, [EBStyle screenWidth] -30, 36)
                                                      title:NSLocalizedString(@"profile_btn_save_contact", nil)
                                                     target:self action:@selector(saveToContacts)]];
    }
    return view;
}

- (void)sendIM
{
    [[EBController sharedInstance] startChattingWith:@[_contact] popToConversation:YES];

    [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_DETAIL_SEND_MESSAGE];
}

- (void)saveToContacts
{
    NSString *name = _contact.name;

    ABNewPersonViewController *personViewController = [[ABNewPersonViewController alloc] init];
    personViewController.newPersonViewDelegate = self;
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error;
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFStringRef)[name substringFromIndex:1], &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFStringRef)[name substringToIndex:1], &error);
    ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (__bridge CFStringRef)[EBPreferences sharedInstance].companyName, &error);
    ABRecordSetValue(newPerson, kABPersonDepartmentProperty, (__bridge CFStringRef)_contact.department, &error);

    //phone number
    if (_contact.phone)
    {
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)_contact.phone, kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, &error);
        CFRelease(multiPhone);
    }
    personViewController.displayedPerson = newPerson;

    [self.navigationController pushViewController:personViewController animated:YES];

    [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_DETAIL_SAVE];
}

- (void)sms
{
    
    
     [[ShareManager sharedInstance] shareContent:@{@"to":_contact.phone} withType:EShareTypeMessage handler:^(BOOL success, NSDictionary *info)
     {

     }];

    [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_DETAIL_SEND_SMS];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath row] == 1)
    {
        if (_contact.phone.length)
        {
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:@"iPhone"] ) {
                
                [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), _contact.phone]
                                      yes:NSLocalizedString(@"confirm_ok", nil) action:^
                 {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _contact.phone]]];
                 }];
            }
            else
            {
                [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_DETAIL_CALL];
        }
        else if (_contact.deptTel.length)
        {
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:@"iPhone"] ) {
                
                [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), _contact.deptTel]
                                      yes:NSLocalizedString(@"confirm_ok", nil) action:^
                 {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _contact.deptTel]]];
                 }];
            }
            else
            {
                [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_DETAIL_CALL];
        }
    }
    
    if ([indexPath row] == 2)
    {
        if (_contact.phone.length && _contact.deptTel.length)
        {
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:@"iPhone"] ) {
                
                [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), _contact.deptTel]
                                      yes:NSLocalizedString(@"confirm_ok", nil) action:^
                 {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _contact.deptTel]]];
                 }];
            }
            else
            {
                [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_DETAIL_CALL];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_contact.special)
    {
        return 0;
    }
    else
    {
        NSInteger count = 1;
        if (_contact.phone.length)
        {
            count++;
        }
        if (_contact.deptTel.length)
        {
            count++;
        }
        return count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier= @"contactCell";

    NSInteger row = [indexPath row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [EBStyle blackTextColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:50 leftMargin:[EBStyle separatorLeftMargin]]];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];

        if (row == 1 && _contact.phone)
        {
            UIImage *smsImage = [UIImage imageNamed:@"icon_sms"];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake( [EBStyle screenWidth] -50, 0, 50, 50)];
            [btn setImage:smsImage forState:UIControlStateNormal];
            [btn setImage:[smsImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(sms) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }

    if (row == 0)
    {
        cell.textLabel.text = _contact.department; //通讯录这里加入职务
        cell.imageView.image = [UIImage imageNamed:@"contact_dept"];
    }
    else if (row == 1 && _contact.phone)
    {
        cell.textLabel.text = _contact.phone;
        cell.imageView.image = [UIImage imageNamed:@"contact_phone"];
    }
    else if ((row == 1 && _contact.deptTel) || row == 2)
    {
        cell.textLabel.text = _contact.deptTel;
        cell.imageView.image = [UIImage imageNamed:@"contact_tel"];
    }

    return cell;
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
