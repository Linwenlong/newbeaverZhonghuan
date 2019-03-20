//
// Created by 何 义 on 14-3-20.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "AFNetworkReachabilityManager.h"
#import "EBXMPP.h"
#import "XMPPStream.h"
#import "XMPPJID.h"
#import "XMPPMessage.h"
#import "XMPPPresence.h"
#import "XMPPReconnect.h"
#import "EBIMManager.h"
#import "EBPreferences.h"
#import "EBContact.h"
#import "EBIMGroup.h"
#import "XMPPIDTracker.h"
#import "EBContactManager.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPIQ.h"
#import "EBController.h"
#import "EBCache.h"

#define XMPP_TIME_OUT 10.0

@interface EBXMPP()<XMPPStreamDelegate, XMPPReconnectDelegate>
{
    XMPPStream *_xmppStream;
    XMPPReconnect *_xmppReconnect;
    XMPPIDTracker *_responseTracker;
}

@property (nonatomic, strong) NSMutableDictionary *sendObservers;

@end


@implementation EBXMPP

@synthesize sendObservers;

+ (EBXMPP *)sharedInstance
{
    static dispatch_once_t pred;
    static EBXMPP *_sharedInstance = nil;

    dispatch_once(&pred, ^{
        _sharedInstance = [[EBXMPP alloc] init];
        [_sharedInstance doInitialize];
    });

    return _sharedInstance;
}

-(NSMutableDictionary *)sendObservers
{
    if (!sendObservers)
    {
        sendObservers = [[NSMutableDictionary alloc] init];
    }
    return sendObservers;
}

- (void)doInitialize
{
    [EBController observeNotification:NOTIFICATION_NETWORK_STATUS_CHANGED from:self selector:@selector(networkStatusChanged:)];

    _xmppStream = [[XMPPStream alloc] init];

#if !TARGET_IPHONE_SIMULATOR
    {
        _xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];

    _responseTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:dispatch_get_main_queue()];
}

- (void)networkStatusChanged:(NSNotification *)notification
{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    switch (reachabilityManager.networkReachabilityStatus)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            if (![_xmppStream isConnected])
            {
                [self login];
            }
            break;
        case AFNetworkReachabilityStatusNotReachable:
        default:
            [self logout];
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)login
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
    {
        EBPreferences *pref = [EBPreferences sharedInstance];
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/beaver_ios", pref.userId, BEAVER_XMPP_DOMAIN]];
        [_xmppStream setMyJID:jid];

        NSError *error;
        if ([_xmppStream connectWithTimeout:-1 error:&error])
        {

        }
        else
        {

        }
    }
}

- (void)logout
{
    if ([_xmppStream isConnected])
    {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [_xmppStream sendElement:presence];
        [_xmppStream disconnect];
    }
}

- (NSString *)packMessage:(EBIMMessage *)message
{
    NSMutableDictionary *bodyItem = [[NSMutableDictionary alloc] init];
    bodyItem[@"type"] = @(message.type);
    bodyItem[@"content"] = message.content;

    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyItem options:0 error:nil];

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)sendMessage:(EBIMMessage *)message handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    NSString *elementId = [_xmppStream generateUUID];
    XMPPJID *toJID = message.conversationType == EConversationTypeGroup ? [self groupDelegateJID] : [self userJID:message.to];
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:toJID elementID:elementId];

    if (message.conversationType == EConversationTypeGroup)
    {
        [msg addAttributeWithName:@"groupid" stringValue:message.to];
    }

    [msg addBody:[self packMessage:message]];

    [self sendMessage:msg feedback:^(BOOL success, XMPPMessage *fMsg, NSDictionary *info)
    {
        message.status = success? EMessageStatusOK : EMessageStatusSendError;
        [[EBIMManager sharedInstance] updateMessage:message onlyStatus:YES needUpdateTime:YES];
        if (handler)
        {
            handler(success, nil);
        }
    } feedbackWhenSent:YES];
}

- (void)configPushNotification:(NSString *)objId block:(BOOL)block isGroup:(BOOL)isGroup handler:(void(^)(BOOL success, NSDictionary *result))handler
{
    NSString *elementID = [_xmppStream generateUUID];
    XMPPMessage *cfgMessage = [XMPPMessage messageWithType:@"chat" to:[self cfgDelegateJID] elementID:elementID];

    NSString *command = block ? @"block" : @"unblock";
    [cfgMessage addChild:[NSXMLElement elementWithName:@"command" stringValue:command]];

    if (isGroup)
    {
        [cfgMessage addChild:[NSXMLElement elementWithName:@"group" stringValue:objId]];
    }
    else
    {
        [cfgMessage addChild:[NSXMLElement elementWithName:@"members" stringValue:objId]];
    }

    [self sendMessage:cfgMessage feedback:^(BOOL success, XMPPMessage *message, NSDictionary *info)
    {
       handler(success, info);
    } feedbackWhenSent:YES];
}

#pragma mark group related
- (void)group:(EBIMGroup *)group createWithHandler:(void(^)(BOOL success, NSDictionary *info))handler
{
    [self group:group addMembers:group.members handler:^(BOOL success, NSDictionary *info)
    {
        handler(success, info);
    } feedbackWhenSent:NO];
}

- (void)group:(EBIMGroup *)group quitWithHandler:(void(^)(BOOL success, NSDictionary *info))handler
{
    [self group:group deleteMembers:@[[[EBContactManager sharedInstance] myContact]] handler:^(BOOL success, NSDictionary *info)
    {
        handler(success, info);
    }];
}

- (void)group:(EBIMGroup *)group deleteMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    NSString *elementID = [_xmppStream generateUUID];

    NSMutableArray *contactIds = [[NSMutableArray alloc] init];
    for (EBContact *contact in members)
    {
        [contactIds addObject:contact.userId];
    }
    NSXMLElement *membersElement = [NSXMLElement elementWithName:@"members" stringValue:[contactIds componentsJoinedByString:@","]];
    NSXMLElement *commandElement = [NSXMLElement elementWithName:@"command" stringValue:@"delmember"];
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:[self groupDelegateJID] elementID:elementID];
    [xmppMessage addChild:membersElement];
    [xmppMessage addChild:commandElement];
    [xmppMessage addAttributeWithName:@"groupid" stringValue:group.globalId];

    [self sendMessage:xmppMessage feedback:^(BOOL success, XMPPMessage *message, NSDictionary *info)
    {
        if (success)
        {
            NSArray *contacts = [EBXMPP membersFromMessage:message];
            if (contacts)
            {
                handler(YES, @{@"members":contacts});
            }
            else
            {
                handler(YES, @{@"members":@[]});
            }
        }
        else
        {
            handler(success, info);
        }
    } feedbackWhenSent:NO];
}

- (void)group:(EBIMGroup *)group addMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    [self group:group addMembers:members handler:handler feedbackWhenSent:NO];
}

- (void)group:(EBIMGroup *)group addMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler feedbackWhenSent:(BOOL)feedbackWhenSent
{
    NSString *elementID = [_xmppStream generateUUID];

    NSMutableArray *contactIds = [[NSMutableArray alloc] init];
    for (EBContact *contact in members)
    {
        [contactIds addObject:contact.userId];
    }
    NSXMLElement *membersElement = [NSXMLElement elementWithName:@"members" stringValue:[contactIds componentsJoinedByString:@","]];
    NSXMLElement *commandElement = [NSXMLElement elementWithName:@"command" stringValue:@"addmember"];
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:[self groupDelegateJID] elementID:elementID];
    [xmppMessage addChild:membersElement];
    [xmppMessage addChild:commandElement];
    [xmppMessage addAttributeWithName:@"groupid" stringValue:group.globalId];

    [self sendMessage:xmppMessage feedback:^(BOOL success, XMPPMessage *message, NSDictionary *info)
    {
        if (success)
        {
            NSArray *contacts = [EBXMPP membersFromMessage:message];
            if (contacts)
            {
                handler(YES, @{@"members":contacts});
            }
            else
            {
                handler(YES, nil);
            }
        }
        else
        {
            handler(success, info);
        }
    } feedbackWhenSent:feedbackWhenSent];
}

- (void)group:(EBIMGroup *)group fetchMemebers:(void(^)(BOOL success, NSDictionary *info))handler
{
    NSString *elementID = [_xmppStream generateUUID];

    NSXMLElement *commandElement = [NSXMLElement elementWithName:@"command" stringValue:@"getmember"];
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:[self groupDelegateJID] elementID:elementID];
    [xmppMessage addChild:commandElement];
    [xmppMessage addAttributeWithName:@"groupid" stringValue:group.globalId];

    [self sendMessage:xmppMessage feedback:^(BOOL success, XMPPMessage *message, NSDictionary *info)
    {
        if (success)
        {
            NSArray *members = [EBXMPP membersFromMessage:message];
            if (members)
            {
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                result[@"members"] = members;
                NSString *groupName = [message attributeStringValueForName:@"groupname"];
                if (groupName)
                {
                    result[@"groupname"] = groupName;
                }

                handler(YES, result);
            }
            else
            {
                handler(NO, @{@"desc":@"no contacts got"});
            }
        }
        else
        {
            handler(success, info);
        }
    } feedbackWhenSent:NO];
}

- (void)group:(EBIMGroup *)group setName:(NSString *)name handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    NSString *elementID = [_xmppStream generateUUID];

    NSXMLElement *commandElement = [NSXMLElement elementWithName:@"command" stringValue:@"setname"];
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:[self groupDelegateJID] elementID:elementID];
    [xmppMessage addChild:commandElement];
    [xmppMessage addAttributeWithName:@"groupid" stringValue:group.globalId];
    [xmppMessage addAttributeWithName:@"groupname" stringValue:name];

    [self sendMessage:xmppMessage feedback:^(BOOL success, XMPPMessage *message, NSDictionary *info)
    {
        handler(success, info);
    } feedbackWhenSent:YES];
}

+ (void)tracking:(id)obj trackingInfo:(id<XMPPTrackingInfo>)trackingInfo withHandler:(void(^)(BOOL success, XMPPMessage *message, NSDictionary *result))handler
{
    if ([obj isKindOfClass:[NSError class]])
    {
        handler(NO, nil, @{@"desc" : @"add members failure"});
    }
    else if ([obj isKindOfClass:[XMPPMessage class]])
    {
        XMPPMessage *msg = (XMPPMessage *)obj;
        if ([msg.type isEqualToString:@"chat"])
        {
            handler(YES, msg, nil);
        }
        else
        {
            handler(YES, msg, @{@"desc":@"server return error"});
        }
    }
    else
    {
        handler(NO, nil, @{@"desc" : @"time out"});
    }
}

+ (NSArray *)membersFromMessage:(XMPPMessage *)message
{
    NSString *memberIds =[[message elementForName:@"members"] stringValue];
    if (memberIds && memberIds.length > 0)
    {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        NSArray *memberArray = [memberIds componentsSeparatedByString:@","];
        for (NSString *id in memberArray)
        {
            [contacts addObject:[[EBContactManager sharedInstance] contactById:id]];
        }

        return contacts;
    }
    else
    {
        return nil;
    }
}

- (void)sendMessage:(XMPPMessage *)xmppMessage
           feedback:(void(^)(BOOL success, XMPPMessage *message, NSDictionary *info))feedback
   feedbackWhenSent:(BOOL)feedbackWhenSent
{
    __block EBXMPP *ebxmpp = self;
    [_responseTracker addID:xmppMessage.elementID block:^(id obj, id <XMPPTrackingInfo> info)
    {
        [EBXMPP tracking:obj trackingInfo:info withHandler:feedback];
        [ebxmpp.sendObservers removeObjectForKey:xmppMessage.elementID];
    } timeout:XMPP_TIME_OUT];

    if (feedbackWhenSent)
    {
        self.sendObservers[xmppMessage.elementID] = @1;
    }

    [_xmppStream sendElement:xmppMessage];
}

- (XMPPJID *)groupDelegateJID
{
    return [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", @"gc", BEAVER_XMPP_DOMAIN]];
}

- (XMPPJID *)cfgDelegateJID
{
    return [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", @"cfg", BEAVER_XMPP_DOMAIN]];
}

- (XMPPJID *)userJID:(NSString *)userId
{
    NSRange range = [userId rangeOfString:@"@"];
    if (range.location == NSNotFound) {
        return [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", userId, BEAVER_XMPP_DOMAIN]];
    }
   else
   {
       return [XMPPJID jidWithString:userId];
   }
}

#pragma mark connect and authenticate
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSError *error = nil;
    if ([_xmppStream authenticateWithPassword:[NSString stringWithFormat:@"pass_%@", pref.userId] error:&error])
    {
//        [EBAlert alertError:@"login success"];
    }
    else
    {
//        [EBAlert alertError:@"login failure"];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogDebug(@"xmppStreamDidAuthenticate");
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];

}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogDebug(@"didNotAuthenticate:%@",error.description);
}
- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
{
    DDLogDebug(@"alternativeResourceForConflictingResource: %@",conflictingResource);
    return @"beaver";
}

#pragma mark message

- (XMPPMessage *)xmppStream:(XMPPStream *)sender willSendMessage:(XMPPMessage *)message
{
    return message;
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    [_responseTracker invokeForID:message.elementID withObject:error];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    if (message.elementID && self.sendObservers[message.elementID])
    {
        [_responseTracker invokeForID:message.elementID withObject:message];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([_responseTracker invokeForID:message.elementID withObject:message])
    {

    }
    else
    {
        if ([message isChatMessage])
        {
            NSString *command = [[message elementForName:@"command"] stringValue];
            if (command && command.length > 0)
            {
               NSString *groupId = [message attributeStringValueForName:@"groupid"];
               if (groupId)
               {
                   EBIMGroup *group = [[EBIMManager sharedInstance] groupFromGlobalId:groupId withMembers:NO];
                   if (group)
                   {
                       if ([command isEqualToString:@"addmember"])
                       {
                           [[EBIMManager sharedInstance] group:group membersJoined:[EBXMPP membersFromMessage:message]];
                       }
                       else if ([command isEqualToString:@"delmember"])
                       {
                           [[EBIMManager sharedInstance] group:group membersLeft:[EBXMPP membersFromMessage:message]];
                       }
                       else if ([command isEqualToString:@"setname"])
                       {
                           [[EBIMManager sharedInstance] group:group nameSet:[message attributeStringValueForName:@"groupname"]];
                       }
                   }
               }
               else
               {
                   if ([command isEqualToString:@"synccontact"])
                   {
//                       [[EBContactManager sharedInstance] contactsChanged:[[[message elementForName:@"userid"] stringValue]
//                               componentsSeparatedByString:@","]];
//                       [[EBCache sharedInstance] filterDataChanged];

                       [[EBCache sharedInstance] synchronizeCompanyData:^(BOOL success){}];
                   }
               }
            }
            else
            {
                NSString *groupId = [message attributeStringValueForName:@"groupid"];
                if (groupId)
                {
                    EBIMGroup *group = [[EBIMManager sharedInstance] groupFromGlobalId:groupId withMembers:NO];
                    if (!group)
                    {
                        group = [[EBIMManager sharedInstance] persistGroup:groupId members:nil];
                        [self group:group fetchMemebers:^(BOOL success, NSDictionary *info)
                        {
                            if (success && info[@"members"])
                            {
                                [[EBIMManager sharedInstance] updateGroupMembers:group.globalId members:info[@"members"]];

                                if (info[@"groupname"])
                                {
                                   [[EBIMManager sharedInstance] group:group nameSet:info[@"groupname"]];
                                }

                                [[EBIMManager sharedInstance] receiveMessage:message];
                            }
                        }];
                    }
                    else
                    {
                        [[EBIMManager sharedInstance] receiveMessage:message];
                    }
                }
                else
                {
                    [[EBIMManager sharedInstance] receiveMessage:message];
                }
            }
        }
    }
}

#pragma mark presence
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{

}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{

}

#pragma mark IQ
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{

}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSString *type = [iq type];

    if ([type isEqualToString:@"result"] || [type isEqualToString:@"error"])
    {
        return [_responseTracker invokeForID:[iq elementID] withObject:iq];
    }
    else
    {
        return NO;
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{

}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    DDLogDebug(@"didReceiveError: %@",error.description);
}


- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    DDLogDebug(@"xmppStreamWasToldToDisconnect");
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    DDLogDebug(@"xmppStreamConnectDidTimeout");
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogDebug(@"xmppStreamDidDisconnect: %@",error.description);
}

#pragma xmppReconnect delegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    DDLogDebug(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    DDLogDebug(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);
    return YES;
}

@end
