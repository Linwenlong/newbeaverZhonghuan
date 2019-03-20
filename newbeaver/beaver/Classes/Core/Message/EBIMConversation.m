//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMConversation.h"
#import "FMResultSet.h"
#import "EBContactManager.h"
#import "EBIMGroup.h"
#import "EBIMManager.h"
#import "EBContact.h"
#import "EBPreferences.h"
#import "EBCache.h"


@implementation EBIMConversation

- (void)parseFromRs:(FMResultSet *)rs
{
    [super parseFromRs:rs];
    _lastMessageId = [rs intForColumn:@"Flast_msg"];
    _unreadCount = [rs intForColumn:@"Funread"];
    _objId = [rs stringForColumn:@"Fobj_id"];
    _id = [rs intForColumn:@"Fid"];
    _type = (EConversationType)[rs intForColumn:@"Ftype"];

    if (_type != EConversationTypeGroup)
    {
        if ([_objId hasPrefix:@"wx_customer_"]) {
            _chatContact = [[EBCache sharedInstance] objectForKey:_objId];
        }else{
            _chatContact = [[EBContactManager sharedInstance] contactById:_objId];
        }
    }
    else
    {
        _chatGroup = [[EBIMManager sharedInstance] groupFromGlobalId:_objId withMembers:NO];
        if (!_chatGroup.name || _chatGroup.name.length == 0)
        {
            _chatGroup.members = [[EBIMManager sharedInstance] groupMembers:_chatGroup.globalId];
            [_chatGroup ensureGroupTitle];
        }
    }

    _receiveNotify = [[EBIMManager sharedInstance] notifyState:_objId];
}

+ (EConversationType)typeByObjectId:(NSString *)objId
{
   if ([objId isEqualToString:[EBPreferences systemIMIDEALL]])
   {
       return EConversationTypeSystemEAll;
   }
   else if ([objId isEqualToString:[EBPreferences systemIMIDCompany]])
   {
       return EConversationTypeSystemCompany;
   }
   else if ([objId isEqualToString:[EBPreferences systemIMIDNewHouse]])
   {
       return EConversationTypeSystemNewHouse;
   }
   else if ([objId rangeOfString:@"#"].length > 0)
   {
       return EConversationTypeGroup;
   }
   else
   {
       return EConversationTypeChat;
   }
}

@end