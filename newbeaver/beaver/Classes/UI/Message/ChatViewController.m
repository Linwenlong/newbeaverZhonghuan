//
//  ChatViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "SDImageCache.h"
#import "ChatViewController.h"
#import "EBIMConversation.h"
#import "EBIMManager.h"
#import "EBContact.h"
#import "EBViewFactory.h"
#import "EBBubbleMessageCell.h"
#import "EBInputWithBoardView.h"
#import "EBHttpClient.h"
#import "EBCache.h"
#import "EBController.h"
#import "ChatInfoViewController.h"
#import "EBIMGroup.h"
#import "EBTimeFormatter.h"
#import "EBRecorderPlayer.h"
//#import "EBMessageInputView.h"
#import "EBMessageBoardView.h"
#import "EBMessageInputbar.h"
#import "EBMessageInputView.h"
#import "EBMessageTextView.h"
#import "EBBubbleView.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "UIImage+Alpha.h"
#import "UIImage+ImageCompress.h"
#import "MainTabViewController.h"
#import "UIImageView+WebCache.h"

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, EBMessageBoardViewDelegate>
{
    NSMutableArray *_messageArray;
    BOOL _hasMore;
    BOOL _isLoadingMore;
    UIButton *_rightButton;
}

@property (nonatomic, readonly) EBMessageTextView *textView;

@end

@implementation ChatViewController

- (void)loadView
{
    [super loadView];
	// Do any additional setup after loading the view.
    
//    [self addLeftNavigationBtnWithImage:[UIImage imageNamed:@"icon_back"] target:self action:@selector(backAction)];
    if (_conversation.type == EConversationTypeGroup)
    {
        _rightButton = [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_group"]target:self action:@selector(viewChatInfo:)];

        if (_conversation.chatGroup.members.count == 0)
        {
            _conversation.chatGroup.members = [[EBIMManager sharedInstance] groupMembers:_conversation.chatGroup.globalId];
        }
    }
    else
    {
        if (_conversation.type == EConversationTypeChat)
        {
            _rightButton = [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_member"]target:self action:@selector(viewChatInfo:)];
        }
        self.navigationItem.title = _conversation.chatContact.name;
    }

    [self updateNavigationTitle];
    [self setup];
}

- (BOOL)shouldPopOnBack
{
    _inputWithBoardView.delegate = nil;
//    [_inputWithBoardView resignFirstResponder];
    return YES;
}

- (void)backAction
{
    _inputWithBoardView.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [EBController sharedInstance].mainTabViewController.selectedIndex = 2;
    });
}

#pragma send actions

- (void)newMessage:(EBIMMessage *)message
{
    message.to = _conversation.objId;
    message.conversationType = _conversation.type;

    [[EBIMManager sharedInstance] sendMessage:message inConversation:_conversation
                                      handler:^(BOOL success, NSDictionary *info)
    {
        [self updateCurrentChat];
        if (message.status == EMessageStatusOK)
        {
            [JSMessageSoundEffect playMessageSentSound];
        }
    }];
    [_messageArray addObject:message];
    [self updateCurrentChat];

    if (_conversation.type == EConversationTypeSystemEAll)
    {
        [EBTrack event:EVENT_CLICK_IM_SEND_TO_EALL];
    }
    else if (_conversation.type == EConversationTypeSystemCompany)
    {
        [EBTrack event:EVENT_CLICK_IM_SEND_TO_COMPANY];
    }
}

- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)onlyStatus
{
    [[EBIMManager sharedInstance] updateMessage:message onlyStatus:onlyStatus needUpdateTime:YES
                                        handler:^(BOOL success, NSDictionary *info){
          [self updateCurrentChat];
          if (success && message.status == EMessageStatusOK)
          {
              [JSMessageSoundEffect playMessageSentSound];
          }
    }];
    [self updateCurrentChat];
}

- (void)updateCurrentChat
{
    [self updateMessageTimeDisplay];
    [_tableView reloadData];
    [self scrollToBottom:YES];
}


- (void)updateCurrentGroupMember
{
    _conversation.chatGroup.members = [[EBIMManager sharedInstance] groupMembers:_conversation.chatGroup.globalId];
    [self updateNavigationTitle];
}

- (void)messageBoardView:(EBInputWithBoardView *)boardView sendText:(NSString *)text
{
    EBIMMessage *message = [[EBIMMessage alloc] init];
    message.status = EMessageStatusSending;
    message.content = [EBIMMessage buildTextContent:text];

    [self newMessage:message];
}

- (void)messageBoardView:(EBInputWithBoardView *)boardView sendImage:(UIImage *)sendImage
{
    //compress image to 0.4M
    NSData *imgData = UIImageJPEGRepresentation(sendImage, 1.0);
    CGFloat quality = imgData.length / (1024*1024*0.1);
    if (quality > 1.0) {
        quality = 1/quality;
        sendImage = [UIImage compressImage:sendImage compressRatio:quality];
    }
    
    NSString *localUrl = [EBCache localUrlForCategory:@"image" object:sendImage];
    [[SDImageCache sharedImageCache] storeImage:sendImage forKey:localUrl];

    EBIMMessage *message = [[EBIMMessage alloc] init];
    message.type = EMessageContentTypeImage;
    message.status = EMessageStatusUploading;
    message.content = [EBIMMessage buildImageContent:nil localUrl:localUrl size:sendImage.size];

    [self newMessage:message];

    [[EBHttpClient sharedInstance] dataRequest:@{@"type":@"chat"} uploadImage:sendImage withHandler:^(BOOL success, id result)
    {
        if (success)
        {
            NSDictionary *data = (NSDictionary *)result;

            NSString *url = data[@"url"];
            [[SDImageCache sharedImageCache] storeImage:sendImage forKey:url];
            message.status = EMessageStatusSending;
            message.content = [EBIMMessage buildImageContent:url localUrl:localUrl size:sendImage.size];
            [self updateMessage:message onlyStatus:NO];
        }
        else
        {
            message.status = EMessageStatusUploadingError;
            [self updateMessage:message onlyStatus:YES];
        }
    }];
}

- (void)messageBoardView:(EBInputWithBoardView *)boardView shareLocation:(NSDictionary *)poiInfo
{
    EBIMMessage *message = [[EBIMMessage alloc] init];
    message.type = EMessageContentTypeShareLocation;
    message.status = EMessageStatusSending;
    message.content = poiInfo;

    [self newMessage:message];
}

- (void)messageBoardView:(EBInputWithBoardView *)boardView reportLocation:(NSDictionary *)poiInfo
{
    EBIMMessage *message = [[EBIMMessage alloc] init];
    message.type = EMessageContentTypeReportLocation;
    message.status = EMessageStatusSending;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:poiInfo];
    CLLocationCoordinate2D  coor = [[EBController sharedInstance] BD09FromGCJ02:CLLocationCoordinate2DMake([poiInfo[@"lat"] floatValue], [poiInfo[@"lon"] floatValue])];
    [dict setObject:[NSString stringWithFormat:@"%lf",coor.latitude] forKey:@"lat"];
    [dict setObject:[NSString stringWithFormat:@"%lf",coor.longitude] forKey:@"lon"];
    
    poiInfo = dict;
    message.content = poiInfo;

    [self newMessage:message];
}

- (void)messageBoardView:(EBInputWithBoardView *)boardView sendAudio:(NSDictionary *)audioInfo length:(NSTimeInterval)length
{
    EBIMMessage *message = [[EBIMMessage alloc] init];
    message.type = EMessageContentTypeAudio;
    message.status = EMessageStatusUploading;
//    message.status = EMessageStatusGenerating;
    message.content = [EBIMMessage buildAudioContent:nil localUrl:audioInfo[@"key"] length:[audioInfo[@"length"] integerValue] listened:NO];

    [self newMessage:message];

    [[EBHttpClient sharedInstance] dataRequest:@{@"type":@"chat"} uploadAudio:[NSURL fileURLWithPath:audioInfo[@"amr"]]
                                   withHandler:^(BOOL success, NSDictionary *result)
    {
        if (success)
        {
            NSDictionary *data = result;

            NSString *url = data[@"url"];
//            [[SDImageCache sharedImageCache] storeImage:sendImage forKey:url];
            message.status = EMessageStatusSending;
            message.content = [EBIMMessage buildAudioContent:url localUrl:audioInfo[@"key"] length:[audioInfo[@"length"] integerValue] listened:NO];
            [self updateMessage:message onlyStatus:NO];
        }
        else
        {
            message.status = EMessageStatusUploadingError;
            [self updateMessage:message onlyStatus:YES];
        }
    }];
}

- (void)messageBoardView:(EBInputWithBoardView *)boardView boardFrameChange:(CGRect)frame
{
////    if (_tableView.contentSize.height > _tableView.bounds.size.height - frame.size.height)
////    {
//
//        CGRect tableFrame = [EBStyle fullScrTableFrame:NO];
////        tableFrame.origin.y -= tableFrame.size.height - 45 - frame.origin.y ;
//////        tableFrame.size.height -= 45;
//
//
//
//        _tableView.contentInset = UIEdgeInsetsMake(0, 0, tableFrame.size.height - 45 - frame.origin.y + 10, 0);
//       [self scrollToBottom:YES];
//
////        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:
////                ^{
////                    _tableView.frame = tableFrame;
////                } completion:^(BOOL finish){
////            if (_messageArray.count)
////            {
////                [self scrollToBottom:YES];
////            }
////        }];
////    }
    _tableView.frame = CGRectMake(_tableView.left, _tableView.top, _tableView.width, frame.origin.y - _tableView.top);
    [self scrollToBottom:YES];
}

- (void)setup
{
    CGRect tableFrame = [EBStyle fullScrTableFrame:NO];

    if (_conversation.type != EConversationTypeSystemNewHouse)
    {
        CGFloat inputBoardViewHeight = 261;
        CGRect inputFrame = CGRectMake(0.0f, tableFrame.size.height - 44, tableFrame.size.width, inputBoardViewHeight);
        EBMessageBoardView *boardView = [[EBMessageBoardView alloc] initWithFrame:inputFrame];
        boardView.delegate = self;
        [self.view addSubview:boardView];
        _inputWithBoardView = boardView;
        tableFrame.size.height -= 44;
    }

    _tableView = [[UITableView alloc] initWithFrame:tableFrame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];

    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);

    [self.view addSubview:_tableView];

    [self setBackgroundColor:[UIColor whiteColor]];

    self.view.clipsToBounds = NO;
    [self.view bringSubviewToFront:_inputWithBoardView];
}

- (EBMessageTextView *)textView
{
    return self.inputWithBoardView.messageInputbar.textView;
}

- (EBIMMessage *)messageForIndexPath:(NSIndexPath *)indexPath
{
    return _messageArray[(NSUInteger)[indexPath row]];
}

- (NSInteger)indexOfmMessage:(EBIMMessage *)message
{
    for (int i = 0; i < _messageArray.count; i++)
    {
        EBIMMessage *msg = _messageArray[i];
        if (message.id == msg.id)
        {
            return i;
        }
    }
    return NSNotFound;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    [_inputWithBoardView registerEventObservers];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_conversation.id > 0)
    {
        [super viewWillAppear:animated];
        [[EBIMManager sharedInstance] clearUnread:_conversation.id];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[EBRecorderPlayer sharedInstance] stopPlaying];
    [self.textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"*** %@: didReceiveMemoryWarning ***", [self class]);
}

- (void)dealloc
{
    [self unregisterNotifications];
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

#define PAGE_SIZE_CHAT 10

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshMessages];
    
    [self registerNotifications];
}

- (void)handleBubbleSizeChanged:(NSNotification *)notification
{
    [_tableView reloadData];
}

- (void)refreshMessages
{
    if (_conversation.id > 0)
    {
        _messageArray = [[EBIMManager sharedInstance] getMessages:_conversation.id page:1 pageSize:PAGE_SIZE_CHAT];

        if (_messageArray.count)
        {
            _hasMore = _messageArray.count == PAGE_SIZE_CHAT;
            [self updateMessageTimeDisplay];
            [_tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^
            {
                [self scrollToBottom:NO];
            });
        }
        else
        {
            _hasMore = NO;
            [_tableView reloadData];
        }

        if (_hasMore)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 30)];
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicatorView.tag = 99;
            activityIndicatorView.frame = CGRectMake(150, 5, 20, 20);
            [view addSubview:activityIndicatorView];
            _tableView.tableHeaderView = view;
        }
        else
        {
            _tableView.tableHeaderView = nil;
        }
    }
    else
    {
        _messageArray = [[NSMutableArray alloc] init];
        _hasMore = NO;
    }
}

- (void)messageDeleted:(NSNotification *)notification
{
    NSInteger cvsnId = [notification.object integerValue];
    if (cvsnId == _conversation.id)
    {
        [_inputWithBoardView resignFirstResponder];
        [self refreshMessages];
    }
}

- (void)messageReceived:(NSNotification *)notification
{
    EBIMMessage *message = notification.object;

    if ((message.cvsnId == _conversation.id) || (message.conversationType == EConversationTypeGroup && [message.to isEqualToString:_conversation.objId])
            || [message.from isEqualToString:_conversation.objId])
    {
        [_messageArray addObject:message];
        [self updateCurrentChat];

        if (message.type != EMessageContentTypeHint)
        {
            [JSMessageSoundEffect playMessageReceivedSound];
        }
        else
        {
            [self updateCurrentGroupMember];
        }

        [[EBIMManager sharedInstance] clearUnread:_conversation.id];
    }
}

- (void)handleFailureMessage:(NSNotification *)notification
{
    [_inputWithBoardView resignFirstResponder];
    EBIMMessage *msg = notification.object;
    NSInteger row = [self indexOfmMessage:msg];
    
    EBBubbleMessageCell *cell = nil;
    if (row != NSNotFound)
    {
        cell = (EBBubbleMessageCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    [[[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil)]
                    destructiveButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"delete", nil) action:^
                    {
                        [[EBIMManager sharedInstance] deleteMessage:msg];
                    }] otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"btn_resend", nil) action:^
            {
                
                if (cell)
                {
                    [cell setCellSendingStatus];
                }
                [[EBIMManager sharedInstance] resendMessage:msg handler:^(BOOL success, NSDictionary *info)
                {
                    [_tableView reloadData];
                }];
            }], nil] showInView:self.view];
}

- (void)viewChatInfo:(UIButton *)btn
{
    ChatInfoViewController *viewController = [[ChatInfoViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;

    viewController.conversation = _conversation;

    [self.navigationController pushViewController:viewController animated:YES];

    [EBTrack event:EVENT_CLICK_IM_CONVERSATION_INFO];
}

- (void)scrollToBottom:(BOOL)animated
{
    if (_messageArray.count)
    {
//        if (_tableView.contentSize.height > _tableView.bounds.size.height)
//        {
//            CGPoint bottomOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.bounds.size.height + 20);
//            [_tableView setContentOffset:bottomOffset animated:animated];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionNone animated:animated];

//        [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX) animated:animated];
//        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBIMMessage *message = [self messageForIndexPath:indexPath];

    if (message.type == EMessageContentTypeHint)
    {
        return [self tableView:tableView hintCellForMessage:message];
    }

    JSBubbleMessageType type = [self messageTypeForRowAtIndexPath:indexPath];

    NSString *cellIdentifier = nil;
    NSString *extraStr = message.content[@"extra"];
    BOOL extra = extraStr && extraStr.length > 0;
//    BOOL extra = message.content[@"extra"] ? YES : NO;
    cellIdentifier = [NSString stringWithFormat:@"message_cell_%ld_%d_%d_%d", message.type, message.isIncoming,extra, message.displayTimestamp];

    EBBubbleMessageCell *cell = (EBBubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        UIImageView *bubbleImageView = [self bubbleImageViewWithType:type
                                                   forRowAtIndexPath:indexPath];
        cell = [[EBBubbleMessageCell alloc] initWithBubbleType:type
                                               bubbleImageView:bubbleImageView
                                                       message:message
                                               reuseIdentifier:cellIdentifier];
    }

    [self updateCell:cell atIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBIMMessage *message = [self messageForIndexPath:indexPath];

    if (message.contentHeight > 0)
    {
        return message.cellHeight;
    }

    else
    {
        if (message.type == EMessageContentTypeHint)
        {
            message.contentHeight = [EBViewFactory textSize:message.content[@"text"] font:[UIFont systemFontOfSize:12.0]
                                  bounding:CGSizeMake(190, 9999)].height + 10;
        }
        else
        {
            message.contentHeight = [EBBubbleMessageCell neededHeightForBubbleMessageCellWithMessage:message];
        }

        return message.cellHeight;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageArray.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBIMMessage *message = [self messageForIndexPath:indexPath];
    return message.isIncoming ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBIMMessage *message = [self messageForIndexPath:indexPath];
    return [EBViewFactory bubbleImageView:message.isIncoming];
}

#pragma mark - Messages view delegate: OPTIONAL

//
//  *** Implement to customize cell further
//
- (void)updateCell:(EBBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EBIMMessage *message = [self messageForIndexPath:indexPath];

    cell.message = message;

    if (cell.timestampLabel)
    {
        cell.timestampLabel.textColor = [EBStyle grayTextColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
        cell.timestampLabel.text = [EBTimeFormatter formatMessageTime:message.timestamp];
    }
    CGFloat buffY = cell.bubbleView.bottom;
    if (cell.extraLabel) {
        cell.extraLabel.text = [NSString stringWithFormat:@"<u><a href='http://'>%@</a></u>",message.content[@"extra"]];
        cell.extraView.frame = CGRectMake(cell.extraView.left, buffY + 5, cell.extraView.width, cell.extraView.height);
        buffY += 5 + cell.extraView.height;
    }
    
    if (cell.sourceBtn) {
        cell.sourceBtn.frame = CGRectMake(cell.sourceBtn.left, buffY + 5, cell.sourceBtn.width, cell.sourceBtn.height);
    }

    if (cell.nameLabel)
    {
        cell.nameLabel.text = message.sender.name;
    }

    [self configureAvatarView:cell.avatarImageView atIndexPath:indexPath];

//#if TARGET_IPHONE_SIMULATOR
//        cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
//    #else
//    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
//#endif
    
    __weak ChatViewController *weakSelf = self;
    cell.bubbleView.failure = ^(EBIMMessage *message) {
        ChatViewController *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.inputWithBoardView resignFirstResponder];
            NSInteger row = [strongSelf indexOfmMessage:message];
            
            EBBubbleMessageCell *cell = nil;
            if (row != NSNotFound) {
                cell = (EBBubbleMessageCell *)[strongSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            }
            [[[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil)] destructiveButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"delete", nil) action:^{
                [[EBIMManager sharedInstance] deleteMessage:message];
            }] otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"resend", nil) action:^{
                if (cell) {
                    [cell setCellSendingStatus];
                }
                [[EBIMManager sharedInstance] resendMessage:message handler:^(BOOL success, NSDictionary *info) {
                    [strongSelf.tableView reloadData];
                }];
            }], nil] showInView:[[UIApplication sharedApplication] keyWindow]];
        }
    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView hintCellForMessage:(EBIMMessage *)message
{
    NSString *text = message.content[@"text"];

    static NSString *cellIdentifier = @"hintcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 190, message.cellHeight)];
        label.tag = 99;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [EBStyle grayTextColor];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12.0];
        [cell.contentView addSubview:label];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *timeStampLabel = [EBViewFactory timestampLabel];
        timeStampLabel.tag = 100;
        [cell.contentView addSubview:timeStampLabel];
    }

    UILabel *hintLabel = (UILabel *)[cell.contentView viewWithTag:99];
    UILabel *timestampLabel = (UILabel *)[cell.contentView viewWithTag:100];

    CGFloat yOffset = 0;
    if (message.displayTimestamp)
    {
        timestampLabel.hidden = NO;
        yOffset = timestampLabel.frame.origin.y + timestampLabel.frame.size.height;
        timestampLabel.text = [EBTimeFormatter formatMessageTime:message.timestamp];
    }
    else
    {
       timestampLabel.hidden = YES;
    }

    hintLabel.frame = CGRectMake(65, yOffset, 190, message.contentHeight);
    hintLabel.text = text;

    return cell;
}

- (void)configureAvatarView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath
{
//    UIImage *image = [self.avatars objectForKey:sender];
    EBIMMessage *message = [self messageForIndexPath:indexPath];
    if (_conversation.type == EConversationTypeSystemEAll && message.isIncoming)
    {
       imageView.image = [UIImage imageNamed:@"im_eall_logo"];
    }
    else if (_conversation.type == EConversationTypeSystemCompany && message.isIncoming)
    {
        imageView.image = [UIImage imageNamed:@"im_company_logo"];
    }
    else if (_conversation.type == EConversationTypeSystemNewHouse && message.isIncoming)
    {
        imageView.image = [UIImage imageNamed:@"im_client_follow_logo"];
    }
    else
    {
        EBContact *chatContact = message.sender;
        NSRange range = [chatContact.userId rangeOfString:@"@"];
        if (range.location == NSNotFound) {
            imageView.image = [EBViewFactory imageFromGender:message.sender.gender big:NO];
        }
        else
        {
            NSString *placeHold = @"avatar_f_big";
            if (![chatContact.gender isEqualToString:@"f"] && ![chatContact.gender isEqualToString:@"F"]) {
                placeHold = @"avatar_m_big";
            }
            [imageView sd_setImageWithURL:[NSURL URLWithString:chatContact.avatar] placeholderImage:[UIImage imageNamed:placeHold]];
        }
    }
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
    _tableView.backgroundColor = color;
}

- (NSInteger)loadMoreMessages
{
    EBIMMessage *lastMessage = [_messageArray firstObject];
    NSInteger lastTimestamp = lastMessage.timestamp;

    NSMutableArray *sameTimeMessages = [[NSMutableArray alloc] init];
    [_messageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        EBIMMessage *item = obj;
        if (item.timestamp == lastTimestamp)
        {
            [sameTimeMessages addObject:@(item.id)];
        }
        else
        {
            *stop = YES;
        }
    }];

    NSMutableArray *earlierMessages = [[EBIMManager sharedInstance] getMessages:_conversation.id earlierThan:lastTimestamp
                                                                         except:sameTimeMessages pageSize:PAGE_SIZE_CHAT];
    _hasMore = earlierMessages.count == PAGE_SIZE_CHAT;
    if (earlierMessages.count > 0)
    {
        NSInteger count = earlierMessages.count;
        [earlierMessages addObjectsFromArray:_messageArray];
        _messageArray = earlierMessages;
        [self updateMessageTimeDisplay];

        return count;
    }
    else
    {
        return 0;
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_hasMore && scrollView.contentOffset.y < 0 && !_isLoadingMore)
    {
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[_tableView.tableHeaderView viewWithTag:99];
        [indicatorView startAnimating];

        _isLoadingMore = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
        {
            NSInteger loadedCount = [self loadMoreMessages];

            if (loadedCount)
            {
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:loadedCount - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }

            [indicatorView stopAnimating];
            if (!_hasMore)
            {
                _tableView.tableHeaderView = nil;
            }

            _isLoadingMore = NO;
        });
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_inputWithBoardView resignFirstResponder];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    self.isUserScrolling = NO;
}

#pragma -mark whether display message timestamp
- (void)updateMessageTimeDisplay
{
    NSInteger maxInterval = 300;
//    NSInteger maxCountInterval = 5;

    __block NSInteger lastDisplayTimestamp = 0;

    [_messageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        EBIMMessage *msg = obj;

        if (msg.timestamp - lastDisplayTimestamp > maxInterval)
        {
            msg.displayTimestamp = YES;
            lastDisplayTimestamp = msg.timestamp;
        }
        else
        {
            msg.displayTimestamp = NO;
        }
    }];
}

- (void)updateNavigationTitle
{
    UIImage *image = nil;
    
    if (_conversation.type == EConversationTypeGroup)
    {
        CGFloat titleViewWidth = 230.0;
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
        {
            titleViewWidth = 230.0;
        }
        else
        {
            titleViewWidth = 180.0;
        }
        image = [UIImage imageNamed:@"nav_btn_group"];
        [_conversation.chatGroup ensureGroupTitle];
        CGFloat nameWidth = [EBViewFactory textSize:_conversation.chatGroup.groupTitle font:[UIFont boldSystemFontOfSize:18.0] bounding:CGSizeMake(MAXFLOAT, 44)].width;
        CGFloat countWidth = [EBViewFactory textSize:[NSString stringWithFormat:@"(%ld)", _conversation.chatGroup.members.count] font:[UIFont boldSystemFontOfSize:18.0] bounding:CGSizeMake(MAXFLOAT, 44)].width;
        
        UIView *titleView = self.navigationItem.titleView;
        UILabel *title = nil;
        UILabel *count = nil;
        if (titleView && titleView.tag == 99)
        {
            title = (UILabel *)[titleView viewWithTag:77];
            count = (UILabel *)[titleView viewWithTag:88];
        }
        else
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(50, 0, titleViewWidth, 44)];
            view.tag = 99;
            
            title = [[UILabel alloc] initWithFrame:CGRectMake((titleViewWidth - nameWidth - countWidth + 6)/2, 0, titleViewWidth - countWidth - 6, 44)];
            title.font = [UIFont boldSystemFontOfSize:18.0];
            title.textColor = [UIColor whiteColor];
            title.backgroundColor = [UIColor clearColor];
            title.tag = 77;
            [view addSubview:title];
            
            count = [[UILabel alloc] initWithFrame:CGRectMake((titleViewWidth + nameWidth - countWidth - 6)/2, 0, countWidth, 44)];
            count.font = [UIFont boldSystemFontOfSize:18.0];
            count.textColor = [UIColor whiteColor];
            count.backgroundColor = [UIColor clearColor];
            count.tag = 88;
            [view addSubview:count];
            
            self.navigationItem.titleView = view;
        }
        if((nameWidth + countWidth) > titleViewWidth + 6)
        {
            title.frame = CGRectMake(0, 0, titleViewWidth - countWidth - 6, 44);
            count.frame = CGRectMake(titleViewWidth - countWidth, 0, countWidth, 44);
            
        }
        else if((nameWidth + countWidth) < titleViewWidth)
        {
            title.frame = CGRectMake((titleViewWidth - nameWidth - countWidth)/2, 0, nameWidth, 44);
            count.frame = CGRectMake((titleViewWidth + nameWidth - countWidth)/2, 0, countWidth, 44);
        }
        else
        {
            title.frame = CGRectMake((titleViewWidth - nameWidth - countWidth + 6)/2, 0, titleViewWidth - countWidth - 6, 44);
            count.frame = CGRectMake((titleViewWidth + nameWidth - countWidth - 6)/2, 0, countWidth, 44);
        }
        title.text = _conversation.chatGroup.groupTitle;
        count.text = [NSString stringWithFormat:@"(%ld)", _conversation.chatGroup.members.count];
    }
    else
    {
        if (_conversation.type == EConversationTypeChat)
        {
            image = [UIImage imageNamed:@"nav_btn_member"];
        }
        
        self.navigationItem.title = _conversation.chatContact.name;
    }
    if (image)
    {
        [_rightButton setImage:image forState:UIControlStateNormal];
        [_rightButton setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    }
}

#pragma mark - NSNotificationCenter register/unregister

- (void)willShowOrHideKeyboard:(NSNotification *)notification
{
    // Skips this if it's not the expected textView.
    if (![self.textView isFirstResponder]) {
        return;
    }
    
    NSInteger curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Checks if it's showing or hidding the keyboard
    BOOL willShow = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    
    if (willShow) {
        CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //        if (dy == self.messageBoardView.frame.origin.y) {
        //            return;
        //        }
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:curve
                         animations:^{
                             CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                             CGFloat dy = keyboardY - self.inputWithBoardView.messageInputbar.height - self.inputWithBoardView.top;
                             self.inputWithBoardView.frame = CGRectOffset(self.inputWithBoardView.frame, 0, dy);
                             [self messageBoardView:self.inputWithBoardView boardFrameChange:self.inputWithBoardView.frame];
                         }
                         completion:nil];
    } else {
        CGRect frame = [EBStyle fullScrTableFrame:NO];
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.inputWithBoardView.frame = CGRectMake(0, frame.size.height - self.inputWithBoardView.messageInputbar.height, frame.size.width, self.inputWithBoardView.height);
            [self messageBoardView:self.inputWithBoardView boardFrameChange:self.inputWithBoardView.frame];
        } completion:nil];
    }
}

- (void)registerNotifications
{
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowOrHideKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowOrHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [self.inputWithBoardView registerNotifications];
    [EBController observeNotification:NOTIFICATION_MESSAGE_RECEIVE from:self selector:@selector(messageReceived:)];
    [EBController observeNotification:NOTIFICATION_MESSAGE_DELETE from:self selector:@selector(messageDeleted:)];
    [EBController observeNotification:NOTIFICATION_MESSAGE_FAILURE_HANDLE from:self selector:@selector(handleFailureMessage:)];
    [EBController observeNotification:NOTIFICATION_IM_BUBBLE_SIZE_CHANGED from:self selector:@selector(handleBubbleSizeChanged:)];
}

- (void)unregisterNotifications{
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.inputWithBoardView removeNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_DELETE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_RECEIVE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_IM_BUBBLE_SIZE_CHANGED object:nil];
}

@end
