//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMMessage.h"
#import "FMResultSet.h"
#import "XMPPMessage.h"
#import "EBPreferences.h"
#import "EBContactManager.h"
#import "EBContact.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBFilter.h"
#import "EBShare.h"
#import "NSXMLElement+XMPP.h"
#import "NSXMLElement+XEP_0203.h"
#import "EBCache.h"

@implementation EBIMMessage

-(id)initWithXmppMessage:(XMPPMessage *)xmppMessage
{
    self = [super init];
    if (self)
    {
       [self parseFromXmpp:xmppMessage];
       return self;
    }
    return nil;
}

- (BOOL)parseFromXmpp:(XMPPMessage *)xmppMessage
{
    _from = [[xmppMessage fromStr] componentsSeparatedByString:@"@"][0];
    NSString *fromPlatform = [[xmppMessage fromStr] componentsSeparatedByString:@"@"][1];
    if (fromPlatform) {
        if (![fromPlatform hasPrefix:BEAVER_XMPP_DOMAIN]) {
            NSString *temp = [fromPlatform componentsSeparatedByString:@"/"][0];
            _from = [NSString stringWithFormat:@"%@@%@",_from, temp];
//            _from = [xmppMessage fromStr];
            _sourcePlatType = EMessageSourceTypeFang;
        }
    }
    _to = [[xmppMessage toStr] componentsSeparatedByString:@"@"][0];

    _isIncoming = YES;

    NSString *groupId = [xmppMessage attributeStringValueForName:@"groupid"];
    if (groupId)
    {
        _conversationType = EConversationTypeGroup;
        _to = groupId;
    }
    else
    {
        _conversationType = [EBIMConversation typeByObjectId:_from];
    }

//    if (xmppMessage.wasDelayed)
//    {
//        self.timestamp = (NSInteger)xmppMessage.delayedDeliveryDate.timeIntervalSince1970;
//    }
//    else
//    {
//        self.timestamp = (NSInteger)[NSDate date].timeIntervalSince1970;
//    }
    self.timestamp = (NSInteger)[NSDate date].timeIntervalSince1970;

    NSString *body = [xmppMessage body];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];

    if (data)
    {
        NSError *serializationError = nil;
        if ([data length] > 0)
        {
            NSDictionary *msgBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            _type = [msgBody[@"type"] integerValue];
            _content = msgBody[@"content"];
        }
        else
        {
            return NO;
        }

        if (serializationError)
        {
            return NO;
        }
    }

    if (_type == EMessageContentTypeHint)
    {
        _isRead = YES;
    }

    _sender = [[EBContactManager sharedInstance] contactById:_from];
    
    if ([_from hasPrefix:@"wx_customer_"]) {
        EBContact *contact = [[EBCache sharedInstance] objectForKey:_from];
        if (!contact) {
            contact = [EBContact new];
            contact.userId = _from;
            contact.name = _content[@"user_name"];
            contact.avatar = _content[@"user_photo"];
            [[EBCache sharedInstance] setObject:contact forKey:_from];
        }else{
            NSString *name = _content[@"user_name"];
            NSString *avatar = _content[@"user_photo"];
            if (![contact.name isEqualToString:name] || ![contact.avatar isEqualToString:avatar]) {
                contact.name = _content[@"user_name"];
                contact.avatar = _content[@"user_photo"];
                [[EBCache sharedInstance] setObject:contact forKey:_from];
            }
        }
    }

    return YES;
}

- (void)parseFromRs:(FMResultSet *)rs
{
    [super parseFromRs:rs];

    NSString *contentString = [rs stringForColumn:@"Fcontent"];
    NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *serializationError = nil;
    if (data)
    {
        _content = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
    }
    else
    {
        _content = @{@"text":@"Empty Message"};
    }

    if (serializationError)
    {
        _content = @{@"text":contentString};
    }

    _id = [rs intForColumn:@"Fid"];
    _from = [rs stringForColumn:@"Ffrom"];
    NSRange range = [_from rangeOfString:@"@"];
    if (range.location != NSNotFound) {
        _sourcePlatType = EMessageSourceTypeFang;
    }
    _to = [rs stringForColumn:@"Fto"];
    _cvsnId = [rs intForColumn:@"Fcvsn_id"];
    _type = [rs intForColumn:@"Fcontent_type"];
    _status = [rs intForColumn:@"Fstatus"];
    _conversationType = [EBIMConversation typeByObjectId:_to];
    _isIncoming = ![_from isEqualToString:[EBPreferences sharedInstance].userId];

    _sender = [[EBContactManager sharedInstance] contactById:_from];
}

- (NSString *)subString
{
    switch (_type)
    {
        case EMessageContentTypeText:
        case EMessageContentTypeLink:
        case EMessageContentTypeHint:
        case EMessageContentTypeInvitationReminder:
        case EMessageContentTypePublishFailureReminder:
        case EMessageContentTypeSubscriptionReminder:
                return _content[@"text"];
        case EMessageContentTypeImage:
                return NSLocalizedString(@"cvsn_picture", nil);
        case EMessageContentTypeAudio:
                return NSLocalizedString(@"cvsn_audio", nil);
        case EMessageContentTypeHouse:
                return NSLocalizedString(@"cvsn_house", nil);
        case EMessageContentTypeClient:
                return NSLocalizedString(@"cvsn_client", nil);
        case EMessageContentTypeShareLocation:
                return NSLocalizedString(@"cvsn_share_location", nil);
        case EMessageContentTypeReportLocation:
                return NSLocalizedString(@"cvsn_report_location", nil);
        case EMessageContentTypeNewHouse:
            return NSLocalizedString(@"cvsn_new_house", nil);
        default:
            break;
    }

    return @"[unknown]";
}

- (CGFloat)timestampHeight
{
    return 22.0;
}

- (CGFloat)cellHeight
{
    if (_displayTimestamp)
    {
       return self.timestampHeight + _contentHeight;
    }
    else
    {
       return _contentHeight;
    }
}

+(NSDictionary *)buildTextContent:(NSString *)text
{
     return @{@"text":text};
}

+(NSDictionary *)buildImageContent:(NSString *)url localUrl:(NSString *)localUrl size:(CGSize)size
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc]
            initWithDictionary:@{@"local":localUrl, @"width":@(size.width), @"height":@(size.height)}];

    if (url)
    {
        item[@"url"] = url;
    }
    return item;
}

+(NSDictionary *)buildAudioContent:(NSString *)url localUrl:(NSString *)localUrl length:(NSInteger)length listened:(BOOL)listened
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc]
            initWithDictionary:@{ @"local":localUrl, @"length":@(length)}];
    if (url)
    {
        item[@"url"] = url;
    }
    item[@"listened"] = @(listened);
    return item;
}

+(NSDictionary *)buildHouseContent:(EBHouse *)house
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc]
            initWithDictionary:@{@"id":house.id, @"type": [EBFilter typeString:house.rentalState]}];
    if (house.cover)
    {
        item[@"img"] = house.cover;
    }

    item[@"desc"] = [EBShare imContentForHouse:house];

    return item;
}

+(NSDictionary *)buildNewHouseContent:(EBHouse *)house
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc]
                                 initWithDictionary:@{@"id":house.id}];
    
    item[@"desc"] = [EBShare wxContentForNewHouse:house];;
    return item;
}

+(NSDictionary *)buildClientContent:(EBClient *)client
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc]
            initWithDictionary:@{@"name":client.name, @"id":client.id, @"type": [EBFilter typeString:client.rentalState]}];

    item[@"desc"] = [EBShare imContentForClient:client];

    return item;
}

@end