//
// Created by 何 义 on 14-3-29.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <sqlite3.h>
#import "EBIMConversation.h"
#import "EBIMMessage.h"

@class XMPPMessage;
@class EBIMMessage;
@class EBIMGroup;

@interface EBIMManager : NSObject

+ (EBIMManager *)sharedInstance;

- (void)closeDB;
- (void)openDB;

- (NSMutableArray *)getConversations:(NSInteger)page pageSize:(NSInteger)pageSize;
- (NSMutableArray *)getConversationsEarlierThan:(NSInteger)time except:(NSArray *)cvsnIds pageSize:(NSInteger)pageSize;

- (NSMutableArray *)getMessages:(NSInteger)cvsnId page:(NSInteger)page pageSize:(NSInteger)pageSize;
- (NSMutableArray *)getMessages:(NSInteger)cvsnId earlierThan:(NSInteger)time except:(NSArray *)msgIds pageSize:(NSInteger)pageSize;

- (NSMutableArray *)getSavedGroups:(NSInteger)page pageSize:(NSInteger)pageSize;
- (EBIMGroup *)groupFromId:(NSString *)groupId;

- (NSInteger)getUnreadCount;

- (void)deleteConversation:(NSInteger)cvsnId;
- (void)clearMessage:(NSInteger)cvsnId;
- (void)clearUnread:(NSInteger)cvsnId;
- (NSInteger)getConversationId:(NSString *)from type:(NSInteger)conversationType;
- (NSInteger)ensureConversationExist:(NSString *)from converstaionType:(EConversationType)conversationType;

- (void)sendSystemEAllMessage;
- (void)sendSystemCompanyMessage;
- (void)sendSystemNewHouseMessage;

- (void)sendMessage:(EBIMMessage *)message inConversation:(EBIMConversation *)conversation handler:(void(^)(BOOL success, NSDictionary *result))handler;
- (void)sendMessages:(NSArray *)messages inConversation:(EBIMConversation *)conversation handler:(void(^)(BOOL success, NSDictionary *result))handler;
//- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)only;
- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)only needUpdateTime:(BOOL)needUpdateTime;
//- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)only handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)only needUpdateTime:(BOOL)needUpdateTime handler:(void(^)(BOOL success, NSDictionary *info))handler;

- (void)deleteMessage:(EBIMMessage *)message;
- (void)resendMessage:(EBIMMessage *)message handler:(void(^)(BOOL success, NSDictionary *result))handler;
- (void)receiveMessage:(XMPPMessage *)message;

- (void)setNotifyState:(NSString *)objId notify:(BOOL)notify;
- (BOOL)notifyState:(NSString *)objId;

- (NSArray *)messagesByType:(EMessageContentType)contentType inConversation:(NSInteger)cvsnId;

// group
- (EBIMGroup *)groupFromGlobalId:(NSString *)globalId withMembers:(BOOL) withMembers;
- (void)createGroupWithMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (EBIMGroup *)persistGroup:(NSString *)groupId members:(NSArray *)members;
- (void)updateGroupMembers:(NSString *)groupId members:(NSArray *)members;
- (NSArray *)groupMembers:(NSString *)globalId;

- (void)group:(EBIMGroup *)group setSaveState:(BOOL)saved;

- (void)group:(EBIMGroup *)group addMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *result))handler;
- (void)group:(EBIMGroup *)group deleteMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *result))handler;
- (void)group:(EBIMGroup *)group setName:(NSString *)name handler:(void(^)(BOOL success, NSDictionary *result))handler;
- (void)quitGroup:(EBIMGroup *)group handler:(void(^)(BOOL success, NSDictionary *result))handler;

- (void)group:(EBIMGroup *)group membersJoined:(NSArray *)members;
- (void)group:(EBIMGroup *)group nameSet:(NSString *)name;
- (void)group:(EBIMGroup *)group membersLeft:(NSArray *)members;



@end