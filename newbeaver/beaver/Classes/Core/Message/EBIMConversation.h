//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMBaseModel.h"

@class EBContact;
@class EBIMMessage;
@class EBIMGroup;

typedef NS_ENUM(NSInteger , EConversationType)
{
    EConversationTypeChat = 0,
    EConversationTypeGroup = 1,
    EConversationTypeSystemEAll = 2,
    EConversationTypeSystemCompany = 3,
    EConversationTypeSystemNewHouse = 4
};

@interface EBIMConversation : EBIMBaseModel

@property (nonatomic, assign) EConversationType type;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) BOOL receiveNotify;

@property (nonatomic, assign) NSInteger lastMessageId;
@property (nonatomic, strong) EBIMMessage *lastMessage;
@property (nonatomic, strong) EBContact *chatContact;
@property (nonatomic, strong) EBIMGroup *chatGroup;
@property (nonatomic, copy) NSString *objId;

+ (EConversationType)typeByObjectId:(NSString *)objId;

@end