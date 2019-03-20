//
//  MessageViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ConversationViewController.h"
#import "ContactsViewController.h"
#import "EBIMManager.h"
#import "EBViewFactory.h"
#import "CustomBadge.h"
#import "EBContact.h"
#import "EBController.h"
#import "EBIMGroup.h"
#import "EBContactManager.h"
#import "EBAlert.h"
#import "ChatViewController.h"
#import "EBTimeFormatter.h"
#import "EBHttpClient.h"
#import "EBCache.h"
#import "UIImageView+WebCache.h"

@interface ConversationViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    BOOL _hasMore;
}

@property (nonatomic, strong) NSMutableArray *conversationArray;

@end

#define PAGE_SIZE_CONVERSATION 10

@implementation ConversationViewController


- (void)loadView
{
    [super loadView];
	// Do any additional setup after loading the view.
    self.navigationItem.title = self.selectBlock ? NSLocalizedString(@"share_to_cvsn", nil) : NSLocalizedString(@"message", nil);
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_new_msg2"]target:self action:@selector(startNewChat:)];

	_tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:self.selectBlock ? NO : YES]];
	_tableView.dataSource = self;
	_tableView.delegate = self;
    _tableView.rowHeight = 68;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 20)];

	[self.view addSubview:_tableView];
}

- (void)startNewChat:(id)btn
{
    ContactsViewController *controller = [[ContactsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.filterContacts = @[[[EBContactManager sharedInstance] myContact]];
    controller.title = self.selectBlock ? NSLocalizedString(@"share_to_collegue", nil) : NSLocalizedString(@"new_chatting", nil);
    controller.selectTitleButton = self.selectBlock ? NSLocalizedString(@"spread", nil) : NSLocalizedString(@"start_chatting", nil);

    controller.contactsSelected = ^(NSArray *contacts)
    {
        [self.navigationController popViewControllerAnimated:NO];
        EBIMConversation *cvsn = [[EBIMConversation alloc] init];
        if (contacts.count == 1)
        {
            EBContact *contact = contacts[0];
            cvsn.objId = contact.userId;
            cvsn.chatContact = contact;
            cvsn.type = [EBIMConversation typeByObjectId:cvsn.objId];
            cvsn.receiveNotify = [[EBIMManager sharedInstance] notifyState:cvsn.objId];
            cvsn.id = [[EBIMManager sharedInstance] getConversationId:contact.userId type:cvsn.type];

            [self handleConversationSelection:cvsn];
        }
        else
        {
            [EBAlert showLoading:NSLocalizedString(@"loading_creating_cvsn", nil)];
            NSMutableArray *groupContacts = [[NSMutableArray alloc] initWithArray:contacts];
            [groupContacts insertObject:[[EBContactManager sharedInstance] myContact] atIndex:0];
            [[EBIMManager sharedInstance] createGroupWithMembers:groupContacts handler:^(BOOL success, NSDictionary *info)
            {
                if (success)
                {
                    EBIMGroup *group = info[@"group"];
                    cvsn.objId = group.globalId;
                    cvsn.chatGroup = group;
                    cvsn.type = EConversationTypeGroup;
                    cvsn.receiveNotify = [[EBIMManager sharedInstance] notifyState:cvsn.objId];
                    cvsn.id = [[EBIMManager sharedInstance] getConversationId:group.globalId type:cvsn.type];

                    [self handleConversationSelection:cvsn];
                }
                else
                {

                }
                [EBAlert hideLoading];
            }];
        }
    };

    controller.groupSelected = ^(EBIMGroup *group){
        [self.navigationController popViewControllerAnimated:NO];

        EBIMConversation *cvsn = [[EBIMConversation alloc] init];
        cvsn.objId = group.globalId;
        cvsn.chatGroup = group;
        cvsn.type = EConversationTypeGroup;
        cvsn.receiveNotify = [[EBIMManager sharedInstance] notifyState:cvsn.objId];
        cvsn.id = [[EBIMManager sharedInstance] ensureConversationExist:group.globalId converstaionType:EConversationTypeGroup];

        [self handleConversationSelection:cvsn];
    };

    [self.navigationController pushViewController:controller animated:YES];

    [EBTrack event:EVENT_CLICK_IM_COMPOSE];
}
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    [EBController observeNotification:NOTIFICATION_MESSAGE_RECEIVE from:self selector:@selector(messageStatusChange:)];
    [EBController observeNotification:NOTIFICATION_MESSAGE_READ from:self selector:@selector(messageStatusChange:)];
    [self hiddenleftNVItem];
//    [self messageStatusChange:nil];
}
//隐藏左箭头
- (void)hiddenleftNVItem
{
    self.navigationItem.leftBarButtonItem=nil;
}
- (void)messageStatusChange:(NSNotification *)notification
{
   [self refreshConversations];
}

- (void)refreshConversations
{
    NSInteger pageSize = _conversationArray.count;
    if (pageSize < PAGE_SIZE_CONVERSATION)
    {
        pageSize = PAGE_SIZE_CONVERSATION;
    }
    _conversationArray = [[EBIMManager sharedInstance] getConversations:1 pageSize:pageSize];
    dispatch_block_t viewRefrsh = ^(){
        NSArray *temp = [[NSArray alloc] initWithArray:_conversationArray];
        if (temp && temp.count > 0 && self.selectBlock)
        {
            for (int i = 0; i < temp.count; i++)
            {
                EBIMConversation *conversation = temp[i];
                if (conversation.type == EConversationTypeSystemNewHouse)
                {
                    [_conversationArray removeObjectAtIndex:i];
                }
            }
        }
        _hasMore = _conversationArray.count == pageSize;
        
        if (_conversationArray.count == 0)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:[EBStyle fullScrTableFrame:YES]];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.textColor = [EBStyle grayTextColor];
            label.text = NSLocalizedString(@"no_message", nil);
            
            _tableView.tableHeaderView = label;
        }
        else
        {
            _tableView.tableHeaderView = nil;
        }
        
        [_tableView reloadData];
    };
    
    NSInteger otherUnCached = 0;
    for (id obj in _conversationArray) {
        EBIMConversation *conversation = obj;
        EBContact *contact = conversation.chatContact;
        if (contact) {
            NSRange range = [contact.userId rangeOfString:@"@"];
            if (range.location != NSNotFound) {
                if (contact.name == nil || contact.name.length < 1) {
                    otherUnCached ++;
                }
            }
        }
    }
    if (otherUnCached > 0) {
        __block NSInteger cachFinished = 0;
        for (id obj in _conversationArray) {
            EBIMConversation *conversation = obj;
            EBContact *contactIndex = conversation.chatContact;
            if (contactIndex) {
                NSRange range = [contactIndex.userId rangeOfString:@"@"];
                if (range.location != NSNotFound) {
                    if (contactIndex.name == nil || contactIndex.name.length < 1) {
                        [[EBHttpClient sharedInstance] clientRequest:@{@"im": contactIndex.userId} chowDetail:^(BOOL success, id result) {
                            if (success) {
                                NSDictionary *detailDic = result[@"detail"];
                                if (detailDic) {
                                    EBContact *contact = [EBContact new];
                                    contact.userId = contactIndex.userId;
                                    contact.name = detailDic[@"user_name"];
                                    contact.avatar = detailDic[@"user_avatar"];
                                    contact.gender = detailDic[@"user_gender"];
                                    contact.fromOtherPlatform = YES;
                                    [[EBCache sharedInstance] setObject:contact forKey:contact.userId];
                                    conversation.chatContact = [contact copy];
                                }
                            }
                            cachFinished ++;
                            if (cachFinished >= otherUnCached) {
                                viewRefrsh();
                            }
                        }];
                    }
                }
            }
        }
    }
    else
    {
        viewRefrsh();
    }
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshConversations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _conversationArray.count;
}

- (void)buildCell:(UITableViewCell *)cell
{
    UIImageView *avatarView = [EBViewFactory avatarImageView:48];
    avatarView.frame = CGRectOffset(avatarView.frame, 15, 10);
    avatarView.tag = 88;
    [cell.contentView addSubview:avatarView];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 15, 177, 18)];
    nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    nameLabel.textColor = [EBStyle blackTextColor];
    nameLabel.tag = 90;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [cell.contentView addSubview:nameLabel];

    UILabel *departLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 18, 300, 18)];
    departLabel.font = [UIFont systemFontOfSize:12.0];
    departLabel.textColor = [EBStyle grayTextColor];
    departLabel.tag = 91;
    [cell.contentView addSubview:departLabel];

    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([EBStyle screenWidth]-80, 15, 70, 18)];
    timeLabel.font = [UIFont systemFontOfSize:12.0];
    timeLabel.textColor = [EBStyle grayTextColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.tag = 92;
    [cell.contentView addSubview:timeLabel];

    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 35, [EBStyle screenWidth] - 83, 18)];
    msgLabel.font = [UIFont systemFontOfSize:12.0];
    msgLabel.textColor = [EBStyle blackTextColor];
    msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    msgLabel.tag = 93;
    [cell.contentView addSubview:msgLabel];

    CustomBadge *badge = [CustomBadge customBadgeWithString:@"0"
                                            withStringColor:[UIColor whiteColor]
                                             withInsetColor:[EBStyle redTextColor]
                                             withBadgeFrame:NO
                                        withBadgeFrameColor:[UIColor whiteColor]
                                                  withScale:10.0/13.5
                                                withShining:NO];
    badge.tag = 99;

    [cell.contentView addSubview:badge];
}

- (void)updateCell:(UITableViewCell *)cell withConversation:(EBIMConversation *)conversation
{
    UIImageView *avatarView = (UIImageView *)[cell.contentView viewWithTag:88];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:90];
    UILabel *departLabel = (UILabel *)[cell.contentView viewWithTag:91];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:92];
    UILabel *msgLabel = (UILabel *)[cell.contentView viewWithTag:93];
    CustomBadge *badge = (CustomBadge *)[cell.contentView viewWithTag:99];

    EBIMMessage *lastMessage = conversation.lastMessage;
    NSString *subTitle = nil;
    NSString *title = nil;

    if (conversation.type == EConversationTypeGroup)
    {
        avatarView.image = [UIImage imageNamed:@"avatar_group"];

        avatarView.contentMode = UIViewContentModeCenter;
        avatarView.layer.borderWidth = 1.0;
        avatarView.layer.borderColor = [UIColor colorWithRed:81/255.0 green:182.0/255.0f blue:210.0/255.09 alpha:1.0].CGColor;

        EBIMGroup *group = conversation.chatGroup;
        title = group.groupTitle;
    }
    else
    {
        avatarView.layer.borderColor = [UIColor clearColor].CGColor;
        avatarView.contentMode = UIViewContentModeScaleAspectFill;
        EBContact *chatContact = conversation.chatContact;
        if (conversation.type == EConversationTypeSystemEAll)
        {
            avatarView.image = [UIImage imageNamed:@"im_eall_logo"];
        }
        else if (conversation.type == EConversationTypeSystemCompany)
        {
            avatarView.image = [UIImage imageNamed:@"im_company_logo"];
        }
        else if (conversation.type == EConversationTypeSystemNewHouse)
        {
            avatarView.image = [UIImage imageNamed:@"im_client_follow_logo"];
        }
        else
        {
            NSString *placeHold = @"avatar_f_big";
            if (![chatContact.gender isEqualToString:@"f"] && ![chatContact.gender isEqualToString:@"F"]) {
                placeHold = @"avatar_m_big";
            }
            NSRange range = [chatContact.userId rangeOfString:@"@"];
            if (range.location == NSNotFound) {
                if ([chatContact.userId hasPrefix:@"wx_customer_"]) {
                    [avatarView sd_setImageWithURL:[NSURL URLWithString:chatContact.avatar] placeholderImage:[UIImage imageNamed:placeHold]];
                }else{
                    avatarView.image = [EBViewFactory imageFromGender:chatContact.gender big:NO];
                }
            }
            else
            {
                [avatarView sd_setImageWithURL:[NSURL URLWithString:chatContact.avatar] placeholderImage:[UIImage imageNamed:placeHold]];
            }
        }

        title = chatContact.name;
        subTitle = chatContact.department;
    }

    CGSize nameSize = [EBViewFactory textSize:title font:nameLabel.font
                                      bounding:CGSizeMake([EBStyle screenWidth]-40, 20)];

    if (nameSize.width > 167)
    {
        nameSize.width = 167;
    }
    nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, nameSize.width, nameSize.height);
//    CGFloat badgeX = nameLabel.frame.origin.x + nameSize.width;
    if (subTitle && subTitle.length > 0)
    {
        NSString *deptStr = [NSString stringWithFormat:NSLocalizedString(@"cvsn_dept_format", nil), subTitle];
        CGSize deptSize = [EBViewFactory textSize:deptStr font:departLabel.font
                                          bounding:CGSizeMake([EBStyle screenWidth]-40, departLabel.frame.size.height)];
        departLabel.frame = CGRectMake(nameLabel.frame.origin.x + nameSize.width, departLabel.frame.origin.y, deptSize.width, deptSize.height);
//        badgeX = departLabel.frame.origin.x + deptSize.width;
        departLabel.hidden = NO;
        departLabel.text = deptStr;
    }
    else
    {
        departLabel.hidden = YES;
    }

    if (conversation.unreadCount > 0)
    {
        NSString *countStr = conversation.unreadCount > 99 ? NSLocalizedString(@"gp_max_unread_count", nil) : [NSString stringWithFormat:@"%ld", conversation.unreadCount];
        [badge autoBadgeSizeWithString:countStr];
        if (countStr.length >= 2)
        {
            badge.frame = CGRectMake(45,10, badge.frame.size.width - 10, badge.frame.size.height);
        }
        else
        {
            badge.frame = CGRectMake(50, 10, badge.frame.size.width, badge.frame.size.height);
        }
        
//        badge.frame = CGRectMake(badgeX, 12, badge.frame.size.width, badge.frame.size.height);
        badge.hidden = NO;
    }
    else
    {
        badge.hidden = YES;
    }

    nameLabel.text = title;
//    departLabel.text = [NSString stringWithFormat:NSLocalizedString(@"cvsn_dept_format", nil), chatContact.department];

    timeLabel.text =  [EBTimeFormatter formatConversationTime:conversation.timestamp];
    if (lastMessage)
    {
        if (conversation.type == EConversationTypeGroup)
        {
            if (lastMessage.type == EMessageContentTypeHint)
            {
                msgLabel.text = lastMessage.subString;
            }
            else
            {
                msgLabel.text = [NSString stringWithFormat:@"%@: %@", lastMessage.sender.name, lastMessage.subString];
            }
        }
        else
        {
            msgLabel.text = lastMessage.subString;
        }
    }
    else
    {
        msgLabel.text = nil;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cvsnCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:68 leftMargin:73]];

        [self buildCell:cell];
    }

    EBIMConversation *conversation = _conversationArray[[indexPath row]];

    [self updateCell:cell withConversation:conversation];

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasMore && [indexPath row] == _conversationArray.count - 3)
    {
       EBIMConversation *lastCvsn = [_conversationArray lastObject];
       NSInteger lastTimestamp = lastCvsn.timestamp;

       NSMutableArray *sameTimeCvsns = [[NSMutableArray alloc] init];
       [_conversationArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
       {
           EBIMConversation *item = obj;
           if (item.timestamp == lastTimestamp)
           {
               [sameTimeCvsns addObject:@(item.id)];
           }
           else
           {
               *stop = YES;
           }
       }];

       NSArray *earlierConversations = [[EBIMManager sharedInstance] getConversationsEarlierThan:lastTimestamp except:sameTimeCvsns
                                                                         pageSize:PAGE_SIZE_CONVERSATION];
       _hasMore = earlierConversations.count == PAGE_SIZE_CONVERSATION;
       if (earlierConversations.count > 0)
       {
           [_conversationArray addObjectsFromArray:earlierConversations];
       }
       [tableView reloadData];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"delete", nil);
}

-(void)handleConversationSelection:(EBIMConversation *)conversation
{
    if (self.selectBlock)
    {
        if([conversation.objId hasPrefix:@"c_"]){
            [EBAlert alertError:@"不能分享给客户"];
            return;
        }
        self.selectBlock(conversation);
    }
    else
    {
        ChatViewController *chatViewController = [[ChatViewController alloc] init];
        chatViewController.conversation = conversation;
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];

        [EBTrack event:EVENT_CLICK_IM_CONVERSATION];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EBIMConversation *conversation = _conversationArray[[indexPath row] ];

    [self handleConversationSelection:conversation];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        EBIMConversation *cvsn = _conversationArray[[indexPath row]];

        dispatch_block_t bc = ^{
            [[EBIMManager sharedInstance] deleteConversation:cvsn.id];
            [self refreshConversations];
            [EBTrack event:EVENT_CLICK_IM_CONVERSATION_DELETE];
        };

        if (cvsn.type == EConversationTypeGroup && !cvsn.chatGroup.saved)
        {
            [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"group_conversation_not_saved", nil) yes:NSLocalizedString(@"delete", nil) action:bc];
        }
        else
        {
            bc();
        }
	}
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

@end
