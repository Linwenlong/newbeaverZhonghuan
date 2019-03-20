//
//  MessageViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ChatInfoViewController.h"
#import "EBIMConversation.h"
#import "EBIMManager.h"
#import "EBViewFactory.h"
#import "EBContact.h"
#import "EBIMGroup.h"
#import "EBPreferences.h"
#import "UIImage+Alpha.h"
#import "EBXMPP.h"
#import "ProfileViewController.h"
#import "ContactsViewController.h"
#import "EBController.h"
#import "EBAlert.h"
#import "EBContactManager.h"
#import "EBCompatibility.h"
#import "UIImageView+WebCache.h"

@interface ChatInfoViewController ()<UITableViewDataSource, UITableViewDelegate,
        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UITableView *_tableView;
    NSMutableArray *_contacts;
    BOOL _allowDeleting;
    BOOL _isDeleting;
    UICollectionView *_collectionView;
}

@end

@implementation ChatInfoViewController


- (void)loadView
{
    [super loadView];
	// Do any additional setup after loading the view.

//    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_new_msg"]target:self action:@selector(startNewChat:)];

	_tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
	_tableView.dataSource = self;
	_tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	[self.view addSubview:_tableView];

    if (_conversation.type == EConversationTypeGroup)
    {
        if (!_conversation.chatGroup.members)
        {
            _conversation.chatGroup.members = [[EBIMManager sharedInstance] groupMembers:_conversation.chatGroup.globalId];
        }

        _contacts = [[NSMutableArray alloc] initWithArray:_conversation.chatGroup.members];
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"group_format", nil), _contacts.count];
        _allowDeleting = [_conversation.chatGroup.adminId isEqualToString:[EBPreferences sharedInstance].userId];
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"chat_info", nil);
        _contacts = [[NSMutableArray alloc] init];
        [_contacts addObject:_conversation.chatContact];
        _allowDeleting = NO;
    }

    _tableView.tableHeaderView = [self buildMembersView];

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [EBController observeNotification:NOTIFICATION_MESSAGE_RECEIVE from:self selector:@selector(messageReceived:)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_RECEIVE object:nil];
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

#pragma mark - Selector

- (void)messageReceived:(NSNotification *)notification
{
    EBIMMessage *message = notification.object;
    
    if ((message.cvsnId == _conversation.id) || (message.conversationType == EConversationTypeGroup && [message.to isEqualToString:_conversation.objId])
        || [message.from isEqualToString:_conversation.objId])
    {
        if (message.type == EMessageContentTypeHint)
        {
            _conversation.chatGroup.members = [[EBIMManager sharedInstance] groupMembers:_conversation.chatGroup.globalId];
            _contacts = [[NSMutableArray alloc] initWithArray:_conversation.chatGroup.members];
            [self reloadMembersView];
        }
    }
}

#pragma mark members

- (UIView *)buildMembersView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;

    NSInteger itemCount = _contacts.count + (_allowDeleting ? 2 : 1);
    if (_contacts.count > 0) {
        EBContact *contact = _contacts[0];
        if (contact.fromOtherPlatform) {
            itemCount = _contacts.count;
        }
    }
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0,
            [EBStyle screenWidth], (itemCount / 4 + (itemCount % 4 ? 1 : 0)) * 90) collectionViewLayout:layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"member"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"member_edit"];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], _collectionView.frame.size.height + 10)];
    [view addSubview:_collectionView];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 1, [EBStyle screenWidth], 0.5)];
    line.tag = 99;
    line.backgroundColor = [EBStyle grayClickLineColor];
    [view addSubview:line];

    return view;
}

#pragma mark - collection view datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return _contacts.count + (_allowDeleting ? 2 : 1);
    NSInteger itemCount = _contacts.count + (_allowDeleting ? 2 : 1);
    if (_contacts.count > 0) {
        EBContact *contact = _contacts[0];
        if (contact.fromOtherPlatform) {
            itemCount = _contacts.count;
        }
    }
    return itemCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];

    NSString *identifier;
    identifier = row >= _contacts.count ? @"member_edit" : @"member";

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 80, 90)];
    }

    [self updateCell:cell forIndexPath:indexPath withIdentifier:identifier];

    return cell;
}

- (void)updateCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifier
{
    if (![cell.contentView viewWithTag:88])
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 90)];
        view.tag = 88;
        [cell.contentView addSubview:view];

        if ([identifier isEqualToString:@"member_edit"])
        {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 80, 48)];
            [btn addTarget:self action:@selector(editMember:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
        }
        else
        {
            UIImageView *avatar = [EBViewFactory avatarImageView:48];
            avatar.center = CGPointMake(40, 39);
            [view addSubview:avatar];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 73, 80, 13)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [EBStyle blackTextColor];
            [view addSubview:label];

            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(54, 15, 21, 21)];
            UIImage *delImage = [UIImage imageNamed:@"red_delete"];
            [btn setImage:delImage forState:UIControlStateNormal];
            [btn setImage:[delImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
            [view addSubview:btn];
            btn.hidden = YES;
            [btn addTarget:self action:@selector(delMember:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    UIView *contentView = [cell.contentView viewWithTag:88];

    NSInteger row = [indexPath row];
    if ([identifier isEqualToString:@"member_edit"])
    {
        UIButton *btn = (UIButton *)contentView.subviews[0];
        btn.tag = row;

        UIImage *image = [UIImage imageNamed:row == _contacts.count + 1 ? @"im_chat_delete" : @"im_chat_add"];

        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:[image imageByApplyingAlpha:0.4]forState:UIControlStateHighlighted];
    }
    else
    {
        EBContact *contact = _contacts[row];

        for (UIView *view in contentView.subviews)
        {
            // avatar
            if ([view isKindOfClass:[UIImageView class]])
            {
                UIImageView *avatar = (UIImageView *)view;
                NSRange range = [contact.userId rangeOfString:@"@"];
                if (range.location == NSNotFound) {
                    avatar.image = [EBViewFactory imageFromGender:contact.gender big:NO];
                }
                else
                {
                    NSString *placeHold = @"avatar_f_big";
                    if (![contact.gender isEqualToString:@"f"] && ![contact.gender isEqualToString:@"F"]) {
                        placeHold = @"avatar_m_big";
                    }
                    [avatar sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:placeHold]];
                }
            }
                    // label
            else if ([view isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)view;
                label.text = contact.name;
            }
                    // delete btn
            else if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *delButton = (UIButton *)view;
                delButton.tag = row;
                delButton.hidden = !_isDeleting || [contact.userId isEqualToString: _conversation.chatGroup.adminId];
            }
        }
    }
}

- (void)editMember:(UIButton *)btn
{
    NSInteger tag = btn.tag;
    if (tag == _contacts.count + 1)
    {
        // delete member
        _isDeleting = !_isDeleting;
        [_collectionView reloadData];
    }
    else
    {

        _isDeleting = NO;
        [_collectionView reloadData];

        // add memeber
        ContactsViewController *controller = [[ContactsViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        if (_conversation.type == EConversationTypeChat)
        {
            NSMutableArray *filterContacts = [[NSMutableArray alloc] initWithArray:_contacts];
            if (![filterContacts containsObject:[[EBContactManager sharedInstance] myContact]])
            {
                [filterContacts insertObject:[[EBContactManager sharedInstance] myContact] atIndex:0];
            }
            controller.filterContacts = filterContacts;
        }
        else
        {
            controller.filterContacts = _contacts;
        }
        
        controller.title = NSLocalizedString(@"group_add_members", nil);
        controller.selectTitleButton = NSLocalizedString(@"group_add", nil);

        controller.contactsSelected = ^(NSArray *contacts)
        {
            if (_conversation.type == EConversationTypeChat)
            {
                [_contacts addObjectsFromArray:contacts];
                [[EBController sharedInstance] startChattingWith:_contacts popToConversation:YES];
            }
            else
            {
                [EBAlert showLoading:NSLocalizedString(@"loading", nil)];
                [[EBIMManager sharedInstance] group:_conversation.chatGroup addMembers:contacts handler:^(BOOL success,
                        NSDictionary *result)
                {
                    [EBAlert hideLoading];
                     if (success && result[@"members"])
                     {
                        NSArray *members = result[@"members"];
                        _contacts = [[NSMutableArray alloc] initWithArray:members];
                        _conversation.chatGroup.members = members;
                        [self reloadMembersView];
                     }
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
//            [controller.navigationController popViewControllerAnimated:YES];
//            [self.navigationController popViewControllerAnimated:YES];
        };

        [self.navigationController pushViewController:controller animated:YES];

        [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO_ADD_MEMBER];
    }
}

- (void)delMember:(UIButton *)btn
{
    [[EBIMManager sharedInstance] group:_conversation.chatGroup deleteMembers:@[_contacts[btn.tag]] handler:^(BOOL success, NSDictionary *result)
    {
        if (success)
        {
            _conversation.chatGroup.members = result[@"members"];
//            [_contacts removeObjectAtIndex:btn.tag];
            _contacts = [[NSMutableArray alloc] initWithArray:_conversation.chatGroup.members];
            [self reloadMembersView];
        }
    }];

    [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO_REMOVE_MEMBER];
}

- (void)reloadMembersView
{
    NSInteger itemCount = _contacts.count + (_allowDeleting ? 2 : 1);
    _collectionView.frame = CGRectMake(0.0f, 0,
                                       [EBStyle screenWidth], (itemCount / 4 + (itemCount % 4 ? 1 : 0)) * 90);
    
    UIView *headerView = _tableView.tableHeaderView;
    headerView.frame = _collectionView.bounds;
    [headerView viewWithTag:99].frame = CGRectMake(0, _collectionView.bounds.size.height - 0.5, [EBStyle screenWidth], 0.5);
    _tableView.tableHeaderView = nil;
    _tableView.tableHeaderView = headerView;
    
    [_collectionView reloadData];
    
    [self updateNavigationTitle];
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_contacts.count > [indexPath row])
    {
        EBContact *contact = _contacts[[indexPath row]];
        NSRange range = [contact.userId rangeOfString:@"@"];
        if (range.location == NSNotFound) {
            ProfileViewController *viewController = [[ProfileViewController alloc] init];
            viewController.contact = contact;
            viewController.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor blackColor];
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor clearColor];
//}

#define CELL_LINE_WIDTH 1.f

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 90);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource + UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:45 leftMargin:[EBStyle separatorLeftMargin]]];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [EBStyle blackTextColor];

        cell.textLabel.backgroundColor = [UIColor clearColor];

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, [EBCompatibility isIOS7Higher] ? 205 : 210, 45)];
        [cell.contentView addSubview:nameLabel];
        nameLabel.tag = 100;
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [EBStyle grayTextColor];
        nameLabel.backgroundColor = [UIColor clearColor];

//        UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(255, 7.5, 50, 30)];
        UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        CGRect frame = uiSwitch.frame;
        frame.origin.x = [EBStyle screenWidth] - frame.size.width - ([EBCompatibility isIOS7Higher] ? 15.0 : 10.0);
        frame.origin.y = (45.0 - frame.size.height) / 2;
        uiSwitch.frame = frame;
        uiSwitch.tag = 99;
        [cell.contentView addSubview:uiSwitch];
        uiSwitch.hidden = YES;
    }

    NSInteger row = [indexPath row];
    UISwitch *uiSwitch = (UISwitch *)[cell.contentView viewWithTag:99];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    nameLabel.text = nil;
    if (_conversation.type == EConversationTypeGroup && row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"im_group_name", nil);
        uiSwitch.hidden = YES;

        nameLabel.text = _conversation.chatGroup.name ? _conversation.chatGroup.name : NSLocalizedString(@"im_group_name_pl", nil);
    }
    else if ((_conversation.type == EConversationTypeGroup && row == 1) || (_conversation.type == EConversationTypeChat && row == 0))
    {
       cell.textLabel.text = NSLocalizedString(@"im_notification", nil);
        uiSwitch.hidden = NO;
       [uiSwitch removeTarget:self action:@selector(toggleNotification:) forControlEvents:UIControlEventValueChanged];
       [uiSwitch addTarget:self action:@selector(toggleNotification:) forControlEvents:UIControlEventValueChanged];
       uiSwitch.on = _conversation.receiveNotify;
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (_conversation.type == EConversationTypeGroup && row == 2)
    {
        cell.textLabel.text = NSLocalizedString(@"im_save_group", nil);
        uiSwitch.hidden = NO;
        uiSwitch.on = _conversation.chatGroup.saved;
        [uiSwitch removeTarget:self action:@selector(toggleSaveGroup:) forControlEvents:UIControlEventValueChanged];
        [uiSwitch addTarget:self action:@selector(toggleSaveGroup:) forControlEvents:UIControlEventValueChanged];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if ((_conversation.type == EConversationTypeGroup && row == 3) || (_conversation.type == EConversationTypeChat && row == 1))
    {
        cell.textLabel.text = NSLocalizedString(@"im_clear_msg", nil);
        uiSwitch.hidden = YES;
    }
    else if (row == 4)
    {
        cell.textLabel.text = NSLocalizedString(@"im_quit_group", nil);
        uiSwitch.hidden = YES;
    }

    return cell;
}

- (void)toggleNotification:(UISwitch *)uiSwitch
{
//   [EBAlert showLoading:nil];
   [[EBXMPP sharedInstance] configPushNotification:_conversation.objId block:!uiSwitch.on
                                           isGroup:_conversation.type == EConversationTypeGroup handler:^(BOOL success, NSDictionary *result)
   {
//       [EBAlert hideLoading];
       if (success)
       {
           [[EBIMManager sharedInstance] setNotifyState:_conversation.objId notify:uiSwitch.on];
           _conversation.receiveNotify = uiSwitch.on;
       }
   }];

    [EBTrack event:uiSwitch.on ? EVENT_CLICK_IM_CONVERSATION_INFO_NOTIFICATION_OFF : EVENT_CLICK_IM_CONVERSATION_INFO_NOTIFICATION_ON];
}

- (void)toggleSaveGroup:(UISwitch *)uiSwitch
{
   [[EBIMManager sharedInstance] group:_conversation.chatGroup setSaveState:uiSwitch.on];
    _conversation.chatGroup.saved = uiSwitch.on;

    if (uiSwitch.on)
    {
        [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO_SAVE_GROUP];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _conversation.type == EConversationTypeGroup ? 5 : 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];

    if (row == 4)
    {
        // quit group
        [EBAlert confirmWithTitle:@"" message:NSLocalizedString(@"confirm_quit_group", nil) yes:NSLocalizedString(@"confirm_logout_yes", nil) action:^
        {
            [[EBIMManager sharedInstance] quitGroup:_conversation.chatGroup handler:^(BOOL success, NSDictionary *result)
            {
                if (success)
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];

                    [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO_QUIT];
                }
            }];
        }];
    }
    else if ((_conversation.type == EConversationTypeGroup && row == 3) ||
            (_conversation.type == EConversationTypeChat && row == 1))
    {
        [EBAlert confirmWithTitle:@"" message:NSLocalizedString(@"confirm_clear_message", nil)
                              yes:NSLocalizedString(@"confirm_clear", nil) action:^
        {
            [[EBIMManager sharedInstance] clearMessage:_conversation.id];
            [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO_CLEAR_HISTORY];
        }];
    }
    else if (_conversation.type == EConversationTypeGroup && row == 0)
    {
        [[EBController sharedInstance] promptInputWithText:_conversation.chatGroup.name  title:NSLocalizedString(@"input_group_name", nil) block:^(NSString *inputString)
        {
            if (![inputString isEqualToString:_conversation.chatGroup.name])
            {
                [[EBIMManager sharedInstance] group:_conversation.chatGroup setName:inputString handler:^(BOOL success, NSDictionary *info)
                {
                    if (success)
                    {
                        _conversation.chatGroup.name = inputString;
                        [_tableView reloadData];
                    }
                }];
            }
        }];

        [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO_RENAME_GROUP];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)updateNavigationTitle
{
    if (_conversation.type == EConversationTypeGroup)
    {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"group_format", nil), _contacts.count];
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"chat_info", nil);
    }
}

@end
