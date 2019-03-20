//
// Created by 何 义 on 14-3-29.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "SDImageCache.h"
#import "EBIMManager.h"
#import "EBPreferences.h"
#import "FMDatabase.h"
#import "EBIMConversation.h"
#import "XMPPMessage.h"
#import "EBIMMessage.h"
#import "EBContactManager.h"
#import "EBXMPP.h"
#import "EBController.h"
#import "EBIMGroup.h"
#import "EBContact.h"
#import "EBHttpClient.h"
#import "EBRecorderPlayer.h"
#import "EBHttpClient.h"
#import "EBCache.h"

@interface EBIMManager()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation EBIMManager

+ (EBIMManager *)sharedInstance
{
    static EBIMManager *_sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)closeDB
{
    [_db close];
    _db = nil;
}

- (void)openDB
{
    NSString *dbPath = [[EBIMManager userPath] stringByAppendingPathComponent:@"message.db"];
    _db = [self openOrCreateDatabase:dbPath];
}

+ (NSString *)userPath
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    BOOL isDir;
    NSString *cacheDir = [basePath stringByAppendingFormat:@"/%@/im", pref.userId];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cacheDir isDirectory:&isDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cacheDir;
}

- (FMDatabase *)db
{
    if (!_db)
    {
       [self openDB];
    }

    return _db;
}

- (FMDatabase *)openOrCreateDatabase:(NSString *)dbPath
{
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];

    _db = [FMDatabase databaseWithPath:dbPath];
    [_db open];
    if (!exist)
    {
        /*
     * im_cvsn
     * |Fid|Fobj_id|Ftype|Flast_msg|Funread|Ftime|Fdel
     *
     * im_msg
     * |Fid|Ffrom|Fto|Fcontent|Fcontent_type|Fcvsn_id|Fis_read|Fstatus|Ftime|Fdel
     *
     * im_group
     * |Fid|Fgroup_id|Fname|Fcreator_id|Ftime|Fsaved
     *
     * im_group_members
     * |Fid|Fgroup_id|Fuser_id
     *
     * im_msg_notify
     * |Fid|Fobj_id|Fnotify
     *
     *
     * */

        NSArray *createSql = @[
                @"CREATE TABLE IF NOT EXISTS im_cvsn (Fid INTEGER PRIMARY KEY AUTOINCREMENT,Fobj_id TEXT,Ftype INTEGER,Flast_msg INTEGER,Funread INTEGER  DEFAULT 0,Ftime INTEGER  DEFAULT 0,Fdel INTEGER DEFAULT 0);",
                @"CREATE TABLE IF NOT EXISTS im_msg (Fid INTEGER PRIMARY KEY AUTOINCREMENT,Ffrom TEXT,Fto TEXT,Fcontent TEXT,Fcontent_type INTEGER  DEFAULT 0,Fcvsn_id INTEGER  DEFAULT 0,Fis_read INTEGER DEFAULT 0,Fstatus INTEGER DEFAULT 0,Ftime INTEGER  DEFAULT 0,Fdel INTEGER DEFAULT 0);",
                @"CREATE TABLE IF NOT EXISTS im_group (Fid INTEGER PRIMARY KEY AUTOINCREMENT,Fgroup_id TEXT,Fcreator_id TEXT,Fname TEXT,Ftime INTEGER,Fsaved INTEGER  DEFAULT 0);",
                @"CREATE TABLE IF NOT EXISTS im_group_members (Fid INTEGER PRIMARY KEY AUTOINCREMENT,Fgroup_id TEXT,Fuser_id TEXT);",
                @"CREATE TABLE IF NOT EXISTS im_msg_notify (Fid INTEGER PRIMARY KEY AUTOINCREMENT,Fobj_id TEXT,Fnotify INTEGER  DEFAULT 1);",
                @"CREATE INDEX im_msg_idx0 ON im_msg(Fcvsn_id,Ftime);",
                @"CREATE INDEX im_msg_idx1 ON im_msg(Fcvsn_id,Fcontent_type);"
               ];

        for (NSString *sql in createSql)
        {
            [_db executeUpdate:sql];
        }
    }

    return _db;
}

- (void)conversations:(NSMutableArray *)conversations fromResultSet:(FMResultSet *)rs
{
    NSMutableArray *lastMsgIds = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        EBIMConversation *cvsn = [[EBIMConversation alloc] initWithFMResultSet:rs];
        [lastMsgIds addObject:[NSNumber numberWithInt:cvsn.lastMessageId]];
        [conversations addObject:cvsn];
    }

    if (conversations.count > 0)
    {
        NSMutableDictionary *msgMap = [[NSMutableDictionary alloc] init];
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM im_msg WHERE Fid IN (%@) AND Fcontent_type!=-1", [lastMsgIds componentsJoinedByString:@","]];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM im_msg WHERE Fid IN (%@)", [lastMsgIds componentsJoinedByString:@","]];
        rs = [self.db executeQuery:sql];
        while ([rs next])
        {
            EBIMMessage *msg = [[EBIMMessage alloc] initWithFMResultSet:rs];
            msgMap[@(msg.id)] = msg;
        }

        for (EBIMConversation *cvsn in conversations)
        {
            cvsn.lastMessage = msgMap[@(cvsn.lastMessageId)];
        }
    }
}

- (NSMutableArray *)getConversations:(NSInteger)page pageSize:(NSInteger)pageSize
{
    FMResultSet *rs = [self.db executeQuery:[NSString stringWithFormat:@"SELECT * FROM im_cvsn WHERE Fdel=0 ORDER BY Ftime DESC LIMIT %ld,%ld", (page -1) * pageSize, pageSize]];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    [self conversations:results fromResultSet:rs];
    return results;
}

- (NSMutableArray *)getConversationsEarlierThan:(NSInteger)time except:(NSArray *)cvsnIds pageSize:(NSInteger)pageSize
{
    NSString *sql;
    if (cvsnIds.count)
    {
       sql = [NSString stringWithFormat:@"SELECT * FROM im_cvsn WHERE Fdel=0 AND Ftime <= ? AND Fid NOT IN(%@) ORDER BY Fid DESC LIMIT %ld",
                                        [cvsnIds componentsJoinedByString:@","], pageSize];
    }
    else
    {
        sql = [NSString stringWithFormat:@"SELECT * FROM im_cvsn WHERE Fdel=0 AND Ftime <= ? ORDER BY Fid DESC LIMIT %ld", pageSize];
    }
    FMResultSet *rs = [self.db executeQuery:sql, @(time)];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    [self conversations:results fromResultSet:rs];
    return results;
}

- (NSMutableArray *)getMessages:(NSInteger)cvsnId earlierThan:(NSInteger)time except:(NSArray *)msgIds pageSize:(NSInteger)pageSize
{
    NSString *sql;
    if (msgIds.count)
    {
        sql = [NSString stringWithFormat:@"SELECT * FROM im_msg  WHERE Fcvsn_id=? AND Ftime <= ? AND Fid NOT IN(%@) ORDER BY Fid DESC LIMIT %ld",
                                         [msgIds componentsJoinedByString:@","], pageSize];
    }
    else
    {
        sql = [NSString stringWithFormat:@"SELECT * FROM im_msg  WHERE Fcvsn_id=? AND Ftime <= ? ORDER BY Fid DESC LIMIT %ld", pageSize];
    }

    FMResultSet *rs = [self.db executeQuery:sql, @(cvsnId), @(time)];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [results insertObject:[[EBIMMessage alloc] initWithFMResultSet:rs] atIndex:0];
    }

    return results;
}

- (NSInteger)getUnreadCount
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT COUNT(*) AS cnt FROM im_msg WHERE Fis_read=0"];
    if (rs.next)
    {
       return [rs intForColumn:@"cnt"];
    }
    else
    {
        return 0;
    }
}

- (NSMutableArray *)getMessages:(NSInteger)cvsnId page:(NSInteger)page pageSize:(NSInteger)pageSize
{
    FMResultSet *rs = [self.db executeQuery:
            [NSString stringWithFormat:@"SELECT * FROM im_msg  WHERE Fcvsn_id=? AND Fdel=0 ORDER BY Ftime DESC LIMIT %ld,%ld", (page -1) * pageSize, pageSize],
                    [NSNumber numberWithInt:cvsnId]];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [results insertObject:[[EBIMMessage alloc] initWithFMResultSet:rs] atIndex:0];
    }

    return results;
}

- (NSMutableArray *)getSavedGroups:(NSInteger)page pageSize:(NSInteger)pageSize
{
    FMResultSet *rs = [self.db executeQuery:
            [NSString stringWithFormat:@"SELECT * FROM im_group WHERE Fsaved=1 ORDER BY Ftime DESC LIMIT %ld,%ld", (page -1) * pageSize, pageSize]];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        EBIMGroup *group = [[EBIMGroup alloc] initWithFMResultSet:rs];
        group.members = [self groupMembers:group.globalId];
        [group ensureGroupTitle];
        [results addObject:group];
    }

    return results;
}

- (EBIMGroup *)groupFromId:(NSString *)groupId
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM im_group WHERE Fgroup_id=?", groupId];

    EBIMGroup *group = nil;
    if ([rs next])
    {
        group = [[EBIMGroup alloc] initWithFMResultSet:rs];
        group.members = [self groupMembers:group.globalId];
        [group ensureGroupTitle];
    }

    return group;
}

- (void)clearUnread:(NSInteger)cvsnId
{
    [self.db executeUpdate:@"UPDATE im_cvsn SET Funread=0 WHERE Fid=?", [NSNumber numberWithInt:cvsnId]];
    [self.db executeUpdate:@"UPDATE im_msg SET Fis_read=1 WHERE Fcvsn_id=?", [NSNumber numberWithInt:cvsnId]];

    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_READ object:nil]];
}

- (void)deleteConversation:(NSInteger)cvsnId
{
    [self.db executeUpdate:@"DELETE FROM im_msg WHERE Fcvsn_id=?", @(cvsnId)];
    [self.db executeUpdate:@"DELETE FROM im_cvsn WHERE Fid=?", @(cvsnId)];

    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_READ object:nil]];
}

- (void)clearMessage:(NSInteger)cvsnId
{
    [self.db executeUpdate:@"UPDATE im_cvsn SET Funread=0,Flast_msg=0 WHERE Fid=?", @(cvsnId)];
    [self.db executeUpdate:@"DELETE FROM im_msg WHERE Fcvsn_id=?", @(cvsnId)];

    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_DELETE object:@(cvsnId)]];
}

- (void)sendOut:(EBIMMessage *)message withHandler:(void(^)(BOOL success, NSDictionary *result))handler
{
   [[EBXMPP sharedInstance] sendMessage:message handler:handler];
}

- (void)sendMessage:(EBIMMessage *)message inConversation:(EBIMConversation *)conversation handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    if (conversation.id == 0)
    {
        [self saveConversation:conversation];
    }

    NSString *userId = [EBPreferences sharedInstance].userId;
    message.cvsnId = conversation.id;
    message.from = userId;
    message.to = conversation.objId;
    message.timestamp = (NSInteger)[NSDate date].timeIntervalSince1970;
    message.sender = [[EBContactManager sharedInstance] contactById:userId];
    message.isIncoming = NO;
    message.isRead = 1;
    [self persistMessage:message];
    [self updateConversation:conversation message:message];

    if (message.status == EMessageStatusSending)
    {
       [self sendOut:message withHandler:handler];
    }
}

- (void)sendMessages:(NSArray *)messages inConversation:(EBIMConversation *)conversation handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    if (conversation.id == 0)
    {
        [self saveConversation:conversation];
    }

    NSMutableSet *sentSet = [[NSMutableSet alloc] init];
    for (EBIMMessage *message in messages)
    {
        NSString *userId = [EBPreferences sharedInstance].userId;
        message.cvsnId = conversation.id;
        message.from = userId;
        message.timestamp = (NSInteger)[NSDate date].timeIntervalSince1970;
        message.isIncoming = NO;
        message.isRead = 1;
        [self persistMessage:message];

        [self sendOut:message withHandler:^(BOOL success, NSDictionary *result)
        {
            [sentSet addObject:message];
            if (sentSet.count == messages.count)
            {
                handler(YES, nil);
                [self updateConversation:conversation message:message];
            }
        }];
    }
}

- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)only needUpdateTime:(BOOL)needUpdateTime
{
    [self updateMessage:message onlyStatus:only needUpdateTime:needUpdateTime handler:nil];
}

- (void)updateMessage:(EBIMMessage *)message onlyStatus:(BOOL)only needUpdateTime:(BOOL)needUpdateTime handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    NSInteger timestamp = (NSInteger)[NSDate date].timeIntervalSince1970;
    if (!needUpdateTime)
    {
        timestamp = message.timestamp;
    }
    if (!only)
    {
        NSError *error = nil;
        NSString *contentString = @"content error";
        NSData *data = [NSJSONSerialization dataWithJSONObject:message.content options:0 error:&error];
        if (data)
        {
            contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }

        [self.db executeUpdate:@"UPDATE im_msg SET Fstatus=?,Fcontent=?,Ftime=? WHERE Fid=?",
                           [NSNumber numberWithInt:message.status],
                           contentString,
                           [NSNumber numberWithInt:timestamp],
                           [NSNumber numberWithInt:message.id]
        ];
    }
    else
    {
        [self.db executeUpdate:@"UPDATE im_msg SET Fstatus=?,Ftime=? WHERE Fid=?",
                           [NSNumber numberWithInt:message.status],
                           [NSNumber numberWithInt:timestamp],
                           [NSNumber numberWithInt:message.id]
        ];
    }

    if (message.status == EMessageStatusSending)
    {
        [self sendOut:message withHandler:handler];
    }
}

- (void)resendMessage:(EBIMMessage *)message handler:(void(^)(BOOL success, NSDictionary *result))handler
{
   EMessageStatus status = message.status;
   if (!(status == EMessageStatusSendError || status == EMessageStatusUploadingError))
   {
       return;
   }

   if (status == EMessageStatusUploadingError)
   {
       if (message.type == EMessageContentTypeImage)
       {
           NSString *localUrl = message.content[@"local"];

           UIImage *sendImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:localUrl];
           if (!sendImage)
           {
               sendImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:localUrl];
           }

           if (sendImage)
           {
               [[EBHttpClient sharedInstance] dataRequest:@{@"type":@"chat"} uploadImage:sendImage withHandler:^(BOOL success, id result)
               {
                   if (success)
                   {
                       NSDictionary *data = (NSDictionary *)result;

                       NSString *url = data[@"url"];
                       [[SDImageCache sharedImageCache] storeImage:sendImage forKey:url];
                       message.status = EMessageStatusSending;
                       message.content = [EBIMMessage buildImageContent:url localUrl:localUrl size:sendImage.size];
                       [self sendOut:message withHandler:handler];
                   }
                   else
                   {
                       message.status = EMessageStatusUploadingError;
                       [self updateMessage:message onlyStatus:YES needUpdateTime:YES];
                       handler(NO, nil);
                   }
               }];
           }

       }
       //发送语音
       else if (message.type == EMessageContentTypeAudio)
       {
           NSString *localKey = message.content[@"local"];
           NSString *filePath = [[EBRecorderPlayer sharedInstance] amrFilePathWithKey:localKey];
           if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
           {
               [[EBHttpClient sharedInstance] dataRequest:@{@"type":@"chat"} uploadAudio:[NSURL fileURLWithPath:filePath]
                                              withHandler:^(BOOL success, NSDictionary *result)
                                              {
                                                  if (success)
                                                  {
                                                      NSDictionary *data = result;
                                                      NSString *url = data[@"url"];
                                                      message.status = EMessageStatusSending;
                                                      message.content = [EBIMMessage buildAudioContent:url localUrl:localKey length:[message.content[@"length"] integerValue] listened:NO];
                                                      [self sendOut:message withHandler:handler];
                                                  }
                                                  else
                                                  {
                                                      message.status = EMessageStatusUploadingError;
                                                      [self updateMessage:message onlyStatus:YES needUpdateTime:YES];
                                                      handler(NO, nil);
                                                  }
                                              }];
           }
       }
   }
   else if (status == EMessageStatusSendError)
   {
       message.status = EMessageStatusSending;
      [[EBXMPP sharedInstance] sendMessage:message handler:handler];
   }
}

- (void)deleteMessage:(EBIMMessage *)message
{
    [self.db executeUpdate:@"DELETE FROM im_msg WHERE Fid=?", @(message.id)];
    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_DELETE object:@(message.cvsnId)]];
}

//接收到消息
- (void)receiveMessage:(XMPPMessage *)message
{
    BOOL fromEall = YES;
    NSString *fromPlatform = [[message fromStr] componentsSeparatedByString:@"@"][1];
    if (fromPlatform) {
        if (![fromPlatform hasPrefix:BEAVER_XMPP_DOMAIN]) {
            fromEall = NO;
        }
    }
    
    dispatch_block_t mesMangeBlock = ^(){
        EBIMMessage *msg = [[EBIMMessage alloc] initWithXmppMessage:message];
        if (msg)
        {
            if (msg.type < EMessageContentTypePublishFailureReminder)
            {
                msg.isRead = NO;
                NSString *objId = msg.conversationType == EConversationTypeGroup ? msg.to : msg.from;
                msg.cvsnId = [self ensureConversationExist:objId converstaionType:msg.conversationType];
                [self persistMessage:msg];
                [self updateConversation:msg.cvsnId messageId:msg.id increaseUnread:YES time:msg.timestamp];
                
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_RECEIVE object:msg]];
            }
            else if (msg.type == EMessageContentTypeReserved)
            {
                return;
            }
            else if (msg.type == EMessageContentTypePublishFailureReminder
                     || msg.type == EMessageContentTypeSubscriptionReminder)
            {
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_UNREADCOUNT_CHANGED object:nil]];
            }
            else
            {
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_SYSTEM_MESSAGE_RECEIVE object:msg]];
            }
        }
    };
    
    if (fromEall) {
        mesMangeBlock();
    }
    else
    {
        [[EBHttpClient sharedInstance] clientRequest:@{@"im": [message fromStr]} chowDetail:^(BOOL success, id result) {
            if (success) {
                NSDictionary *detailDic = result[@"detail"];
                if (detailDic) {
                    EBContact *contact = [EBContact new];
                    contact.userId = [[message fromStr] componentsSeparatedByString:@"/"][0];
                    contact.name = detailDic[@"user_name"];
                    contact.avatar = detailDic[@"user_avatar"];
                    contact.gender = detailDic[@"user_gender"];
                    contact.fromOtherPlatform = YES;
                    [[EBCache sharedInstance] setObject:contact forKey:contact.userId];
                }
            }
            mesMangeBlock();
        }];
    }
}

- (void)saveConversation:(EBIMConversation *)conversation
{
    conversation.id = [self ensureConversationExist:conversation.objId converstaionType:conversation.type];
}

- (NSInteger)getConversationId:(NSString *)from type:(NSInteger)conversationType
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT Fid FROM im_cvsn WHERE Fobj_id=? AND Ftype=? AND Fdel=0",
                                        from, [NSNumber numberWithInt:conversationType]];
    if ([rs next])
    {
        return [rs intForColumn:@"Fid"];
    }
    else
    {
        return 0;
    }
}

- (NSInteger)ensureConversationExist:(NSString *)from converstaionType:(EConversationType)conversationType
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT Fid FROM im_cvsn WHERE Fobj_id=? AND Ftype=? AND Fdel=0",
                    from, [NSNumber numberWithInt:conversationType]];
    if (![rs next])
    {
        [self.db executeUpdate:@"INSERT INTO im_cvsn (Fobj_id,Ftype) VALUES(?,?)", from, [NSNumber numberWithInt:conversationType]];
        return  (NSInteger)[self.db lastInsertRowId];
    }
    else
    {
        return [rs intForColumn:@"Fid"];
    }
}

- (void)updateConversation:(EBIMConversation *)conversation message:(EBIMMessage *)message
{
    [self updateConversation:conversation.id messageId:message.id increaseUnread:message.isIncoming time:message.timestamp];
}

- (void)updateConversation:(NSInteger)conversationId messageId:(NSInteger)messageId
            increaseUnread:(BOOL)increase time:(NSInteger)time
{
    if (increase)
    {
        [self.db executeUpdate:@"UPDATE im_cvsn SET Flast_msg=?,Funread=Funread+1,Ftime=? WHERE Fid=?",@(messageId) ,
                        @(time), @(conversationId)];
    }
    else
    {
        [self.db executeUpdate:@"UPDATE im_cvsn SET Flast_msg=?,Ftime=? WHERE Fid=?", @(messageId),
                        @(time), @(conversationId)];
    }
}

- (void)persistMessage:(EBIMMessage *)message
{
    NSError *error = nil;
    NSString *contentString = @"";
    if (message.content)
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:message.content options:0 error:&error];
        if (data)
        {
            contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }

    [self.db executeUpdate:@"INSERT INTO im_msg (Ffrom,Fto,Fcontent,Fcontent_type,Fcvsn_id,Fis_read,Fstatus,Ftime) VALUES(?,?,?,?,?,?,?,?)",
                       message.from, message.to, contentString,
                    [NSNumber numberWithInt:message.type],
                    [NSNumber numberWithInt:message.cvsnId],
                    [NSNumber numberWithInt:message.isRead],
                    [NSNumber numberWithInt:message.status],
                    [NSNumber numberWithInt:message.timestamp]];
    message.id = (NSInteger)[self.db lastInsertRowId];
}

- (void)sendSystemEAllMessage
{
    [self systemSend:[EBPreferences systemIMIDEALL] converstaionType:EConversationTypeSystemEAll
             content:NSLocalizedString(@"eall_msg", nil)
         messageType:EMessageContentTypeText ignoreDuplicate:NO isRead:NO];
}

- (void)sendSystemCompanyMessage
{
    NSString *contentFormat = NSLocalizedString(@"company_msg", nil);

    [self systemSend:[EBPreferences systemIMIDCompany] converstaionType:EConversationTypeSystemCompany
             content:[NSString stringWithFormat:contentFormat, [EBPreferences sharedInstance].userName]
         messageType:EMessageContentTypeText ignoreDuplicate:NO isRead:NO];
}

- (void)sendSystemNewHouseMessage
{
    [self systemSend:[EBPreferences systemIMIDNewHouse] converstaionType:EConversationTypeSystemNewHouse
             content:NSLocalizedString(@"new_house_msg", nil)
         messageType:EMessageContentTypeText ignoreDuplicate:NO isRead:NO];
}

- (void)sendGroupHintMessage:(NSString *)groupId withUpdatedMembers:(NSArray *)members msgFormat:(NSString *)format
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for (EBContact *contact in members)
    {
        if ([pref.userId isEqualToString:contact.userId])
        {
            continue;
        }
        [nameArray addObject:contact.name];
    }

    [self systemSend:groupId converstaionType:EConversationTypeGroup
             content:[NSString stringWithFormat:format, [nameArray componentsJoinedByString:@"、"]]
         messageType:EMessageContentTypeHint ignoreDuplicate:YES isRead:YES];
}

- (void)systemSend:(NSString *)from converstaionType:(EConversationType)conversationType
           content:(NSString *)content messageType:(EMessageContentType)msgType ignoreDuplicate:(BOOL)ignore  isRead:(BOOL)read
{
    if (ignore || ![[self.db executeQuery:@"SELECT Fid FROM im_cvsn WHERE Fobj_id=? AND Ftype=?",
                                     from, [NSNumber numberWithInt:conversationType]] next])
    {
//        [self.db executeUpdate:@"INSERT INTO im_cvsn (Fobj_id,Ftype) VALUES(?,?)", from, [NSNumber numberWithInt:conversationType]];
        NSInteger conversationId = [self ensureConversationExist:from converstaionType:conversationType];

        EBPreferences *pref = [EBPreferences sharedInstance];
        EBIMMessage *message = [[EBIMMessage alloc] init];
        message.cvsnId = conversationId;
        message.type = msgType;
        message.from = from;
        message.to = pref.userId;
        message.isRead = read;
        message.isIncoming = YES;
        message.content = @{@"text":content};
        message.timestamp = (NSInteger)[NSDate date].timeIntervalSince1970;

        [self persistMessage:message];
        [self updateConversation:conversationId messageId:message.id increaseUnread:!message.isRead time:(NSInteger)NSDate.date.timeIntervalSince1970];

        [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_MESSAGE_RECEIVE object:message]];
    }
}

/*
   * im_cvsn
   * |Fid|Fobj_id|Ftype|Flast_msg|Funread|Ftime|Fdel
   *
   * im_msg
   * |Fid|Ffrom|Fto|Fcontent|Fcontent_type|Fcvsn_id|Fis_read|Fstatus|Ftime|Fdel
   *
   * im_group
   * |Fid|Fgroup_id|Fname|Fcreator_id|Ftime|Fsaved
   *
   * im_group_members
   * |Fid|Fgroup_id|Fuser_id
   *
   *
   * */

#pragma -mark Group

- (EBIMGroup *)groupFromGlobalId:(NSString *)globalId withMembers:(BOOL)withMembers
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM im_group WHERE Fgroup_id=?", globalId];
    if ([rs next])
    {
        EBIMGroup *group = [[EBIMGroup alloc] initWithFMResultSet:rs];

        if (withMembers)
        {
             group.members = [self groupMembers:globalId];
        }

        return group;
    }
    else
    {
        return nil;
    }

}

- (NSArray *)groupMembers:(NSString *)globalId
{
   NSMutableArray *result = [[NSMutableArray alloc] init];
   FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM im_group_members WHERE Fgroup_id=?", globalId];
   while ([rs next])
   {
      NSString *userId = [rs stringForColumn:@"Fuser_id"];
      [result addObject:[[EBContactManager sharedInstance] contactById:userId]];
   }
    NSArray *components = [globalId componentsSeparatedByString:@"#"];
    
    //ensure group creater exsit
    if (![result containsObject:[[EBContactManager sharedInstance] contactById:components[0]]])
    {
        [result insertObject:[[EBContactManager sharedInstance] contactById:components[0]] atIndex:0];
        [self updateGroupMembers:globalId members:result];
    }

   return result;
}

- (void)createGroupWithMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *globalId = [NSString stringWithFormat:@"%@#%ld", pref.userId, (NSInteger) [NSDate date].timeIntervalSince1970];

    EBIMGroup *group = [[EBIMGroup alloc] init];
    group.globalId = globalId;
    group.members = members;

    [[EBXMPP sharedInstance] group:group createWithHandler:^(BOOL success, NSDictionary *info)
    {
        if (success)
        {
           EBIMGroup *newGroup = [[EBIMManager sharedInstance] persistGroup:globalId members:members];
           NSDictionary *result = @{@"group": newGroup};
           [self sendGroupHintMessage:globalId withUpdatedMembers:members msgFormat:NSLocalizedString(@"im_group_create_hint_format", nil)];
           handler(YES, result);
        }
        else
        {
            handler(NO, info);
        }
    }];
}

- (void)updateGroupMembers:(NSString *)groupId members:(NSArray *)members
{
    if (members && groupId)
    {
        [self.db executeUpdate:@"DELETE FROM im_group_members WHERE Fgroup_id=?", groupId];

        if (members.count > 0)
        {
            NSMutableString *placeHolderString = [[NSMutableString alloc] init];
            NSMutableArray *args = [[NSMutableArray alloc] init];
            for (EBContact *contact in members)
            {
                [placeHolderString appendString:@"(?,?),"];
                
                [args addObject:groupId];
                [args addObject:contact.userId];
            }
            
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO im_group_members (Fgroup_id,Fuser_id) VALUES%@",
                                   [placeHolderString substringToIndex:placeHolderString.length - 1]];
            [self.db executeUpdate:insertSql withArgumentsInArray:args];
        }
    }
}

- (EBIMGroup *)persistGroup:(NSString *)groupId members:(NSArray *)members
{
   NSArray *components = [groupId componentsSeparatedByString:@"#"];

   EBIMGroup *group = [[EBIMGroup alloc] init];
   group.adminId = components[0];
   group.globalId = groupId;
   group.members = members;

   FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM im_group WHERE Fgroup_id=?", groupId];
   if ([rs next])
   {
      group.name = [rs stringForColumn:@"Fname"];
      group.id = [rs intForColumn:@"Fid"];
   }
   else
   {
       [self.db executeUpdate:@"INSERT INTO im_group (Fgroup_id, Fcreator_id, Ftime, Fsaved) VALUES(?,?,?,?)",
                       groupId, group.adminId, [NSNumber numberWithInt:(NSInteger)NSDate.date.timeIntervalSince1970], @0];
       group.id = [self.db lastInsertRowId];
   }

   [self updateGroupMembers:group.globalId members:members];

   return group;
}


- (void)setNotifyState:(NSString *)objId notify:(BOOL)notify
{
    if ([[self.db executeQuery:@"SELECT * FROM im_msg_notify WHERE Fobj_id=?", objId] next])
    {
        [self.db executeUpdate:@"UPDATE im_msg_notify SET Fnotify=? WHERE Fobj_id=?", @(notify), objId];
    }
    else
    {
        [self.db executeUpdate:@"INSERT INTO im_msg_notify (Fobj_id,Fnotify) VALUES(?,?)", objId, @(notify)];
    }
}

- (BOOL)notifyState:(NSString *)objId
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM im_msg_notify WHERE Fobj_id=?", objId];
    if ([rs next])
    {
        return [rs intForColumn:@"Fnotify"];
    }
    else
    {
        [self setNotifyState:objId notify:YES];
        return 1;
    }
}

- (NSArray *)messagesByType:(EMessageContentType)contentType inConversation:(NSInteger)cvsnId
{
    FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM im_msg  WHERE Fcvsn_id=? AND Fcontent_type=?", @(cvsnId), @(contentType)];

    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [results addObject:[[EBIMMessage alloc] initWithFMResultSet:rs]];
    }

    return results;
}

- (void)group:(EBIMGroup *)group setSaveState:(BOOL)saved
{
    [self.db executeUpdate:@"UPDATE im_group SET Fsaved=? WHERE Fgroup_id=?", @(saved), group.globalId];
}

- (void)group:(EBIMGroup *)group addMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *result))handler
{
   [[EBXMPP sharedInstance] group:group addMembers:members handler:^(BOOL success, NSDictionary *info)
   {
       if (success && info[@"members"])
       {
           [self updateGroupMembers:group.globalId members:info[@"members"]];
           [self sendGroupHintMessage:group.globalId withUpdatedMembers:members msgFormat:NSLocalizedString(@"im_group_create_hint_format", nil)];
       }
       handler(success, info);
   }];
}

- (void)group:(EBIMGroup *)group deleteMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    [[EBXMPP sharedInstance] group:group deleteMembers:members handler:^(BOOL success, NSDictionary *info)
    {
        if (success && info[@"members"])
        {
            [self updateGroupMembers:group.globalId members:info[@"members"]];
            [self sendGroupHintMessage:group.globalId withUpdatedMembers:members msgFormat:NSLocalizedString(@"im_group_kick_hint_format", nil)];
        }
        handler(success, info);
    }];
}

- (void)group:(EBIMGroup *)group setName:(NSString *)name handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    [[EBXMPP sharedInstance] group:group setName:name handler:^(BOOL success, NSDictionary *info)
    {
         if (success)
         {
             [self.db executeUpdate:@"UPDATE im_group SET Fname=? WHERE Fgroup_id=?", name, group.globalId];
         }

         handler(success, info);
    }];
}

- (void)quitGroup:(EBIMGroup *)group handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    [[EBXMPP sharedInstance] group:group quitWithHandler:^(BOOL success, NSDictionary *info)
    {
        if (success)
        {
            [self clearGroupData:group.globalId];
        }

        handler(success, info);
    }];
}

- (void)clearGroupData:(NSString *)groupId
{
    NSInteger cvsnId = [self getConversationId:groupId type:EConversationTypeGroup];
    if (cvsnId)
    {
        [self deleteConversation:cvsnId];
    }
    // delete group
    [self.db executeUpdate:@"DELETE FROM im_group WHERE Fgroup_id=?", groupId];
    // delete msg
    [self.db executeUpdate:@"DELETE FROM im_msg WHERE Fcvsn_id=?", @(cvsnId)];
    // delete group members
    [self.db executeUpdate:@"DELETE FROM im_group_members WHERE Fgroup_id=?", groupId];
}

- (void)group:(EBIMGroup *)group nameSet:(NSString *)name
{
    [self.db executeUpdate:@"UPDATE im_group SET Fname=? WHERE Fgroup_id=?", name, group.globalId];
}

- (void)group:(EBIMGroup *)group membersJoined:(NSArray *)members
{
    [[EBXMPP sharedInstance] group:group fetchMemebers:^(BOOL success, NSDictionary *info)
    {
        if (success && info[@"members"])
        {
            [self updateGroupMembers:group.globalId members:info[@"members"]];
            [self sendGroupHintMessage:group.globalId withUpdatedMembers:members
                             msgFormat:NSLocalizedString(@"im_group_joined_hint_format", nil)];
        }
    }];
}

- (void)group:(EBIMGroup *)group membersLeft:(NSArray *)members
{
    NSString *myId = [EBPreferences sharedInstance].userId;

    for (EBContact *contact in members)
    {
        if ([contact.userId isEqualToString:myId])
        {
            [self clearGroupData:group.globalId];
            return;
        }
    }

    [[EBXMPP sharedInstance] group:group fetchMemebers:^(BOOL success, NSDictionary *info)
    {
        if (success && info[@"members"])
        {
            [self updateGroupMembers:group.globalId members:info[@"members"]];
            [self sendGroupHintMessage:group.globalId withUpdatedMembers:members
                             msgFormat:NSLocalizedString(@"im_group_left_hint_format", nil)];
        }
    }];
}

@end
