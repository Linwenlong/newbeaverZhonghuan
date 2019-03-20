//
//  ChatViewController.h
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "JSMessagesViewController.h"

@class EBIMConversation;
@class EBMessageInputView;
@class EBEmojiBoardView;
@class EBMessageBoardView;
@class EBIMMessage;

@interface ChatViewController : BaseViewController

@property (nonatomic, strong) EBIMConversation *conversation;

@property (strong, nonatomic, readonly) UITableView *tableView;
@property (weak, nonatomic, readonly) EBMessageBoardView *inputWithBoardView;

//- (void)sendMessage:(EBIMMessage *)message;

@end
