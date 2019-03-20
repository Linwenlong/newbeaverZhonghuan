//
//  MessageViewController.h
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"

@class EBIMConversation;

@interface ConversationViewController : BaseViewController

@property (nonatomic, copy) void(^selectBlock)(EBIMConversation *conversation);

@end