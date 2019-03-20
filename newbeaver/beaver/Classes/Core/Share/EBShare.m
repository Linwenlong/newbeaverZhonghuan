//
// Created by 何 义 on 14-4-4.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <CommonCrypto/CommonDigest.h>
#import <MessageUI/MessageUI.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "EBShare.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBPrice.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBPreferences.h"
#import "EBFilter.h"
#import "EBHttpClient.h"
#import "SDImageCache.h"
#import "UIImage+Resize.h"
#import "WXApi.h"
#import "ShareConfig.h"
#import "EBAppointment.h"
#import "EBTimeFormatter.h"
#import "EBClientVisitLog.h"


@implementation EBShare

+(UIImage *)coverForHouses:(NSArray *)houses
{
    EBHouse *house = [houses firstObject];

    NSString *key = house.cover;
    if (key.length == 0 && house.pictures.count > 0)
    {
        key = [house.pictures firstObject][@"image"];
    }

    if (!key)
    {
        return [UIImage imageNamed:@"pl_house"];
    }

    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromMemoryCacheForKey:key];
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:key]]];
    if (!image)
    {
        image = [imageCache imageFromDiskCacheForKey:key];
    }

    if (image)
    {
       CGSize sz = image.size;
       if (sz.width > 120)
       {
           sz.width = 120;
           sz.height = image.size.height / image.size.width * 120;
       }
       return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:sz
                      interpolationQuality:kCGInterpolationLow];
       
    }
    else
    {
        return [UIImage imageNamed:@"pl_house"];
    }
}

+(UIImage *)coverForVisitLogs:(NSArray *)visitLogs
{
    EBClientVisitLog *visitLog = [visitLogs firstObject];
    
    NSString *key = visitLog.house.cover;
    if (key.length == 0 && visitLog.house.pictures.count > 0)
    {
        key = [visitLog.house.pictures firstObject][@"image"];
    }
    
    if (!key)
    {
        return [UIImage imageNamed:@"pl_house"];
    }
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromMemoryCacheForKey:key];
    if (!image)
    {
        image = [imageCache imageFromDiskCacheForKey:key];
    }
    
    if (image)
    {
        CGSize sz = image.size;
        if (sz.width > 120)
        {
            sz.width = 120;
            sz.height = image.size.height / image.size.width * 120;
        }
        return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:sz
                             interpolationQuality:kCGInterpolationLow];
        
    }
    else
    {
        return [UIImage imageNamed:@"pl_house"];
    }
}

+ (void)setShareHouses:(NSArray *)houses forKey:(NSString *)key
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    params[@"key"] = key;
    EBHouse *firstItem = [houses firstObject];
    params[@"type"] = [EBFilter typeString:firstItem.rentalState];

    NSMutableArray *houseIds = [[NSMutableArray alloc] init];
    [houses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        EBHouse *house = (EBHouse *)obj;
        [houseIds addObject:house.id];
    }];

    params[@"id"] = [houseIds componentsJoinedByString:@";"];

    EBContact *contact = [EBContactManager sharedInstance].myContact;
    params[@"user_name"] = contact.name;
    if (contact.phone)
    {
        params[@"user_tel"] = contact.phone;
    }
    params[@"gender"] = contact.gender;
    params[@"company_name"] = [EBPreferences sharedInstance].companyName;

    [[EBHttpClient sharedInstance] houseRequest:params setShareData:^(BOOL success, id result)
    {

    }];
}

+ (void)setShareVisitLogs:(NSArray *)visitLogs forKey:(NSString *)key forCustomName:(NSString *)custName
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    params[@"key"] = key;
    EBClientVisitLog *firstItem = [visitLogs firstObject];
    params[@"type"] = [EBFilter typeString:firstItem.house.rentalState];
    
    NSMutableArray *houseIds = [[NSMutableArray alloc] init];
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    [visitLogs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         EBClientVisitLog *visitlog = (EBClientVisitLog *)obj;
         [houseIds addObject:visitlog.house.id];
         
//         NSString* timeStr = visitlog.visitDate;
//         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//         [formatter setDateStyle:NSDateFormatterMediumStyle];
//         [formatter setTimeStyle:NSDateFormatterShortStyle];
//         [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//         
//         NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
//         [formatter setTimeZone:timeZone];
//         NSDate* date = [formatter dateFromString:timeStr];
         NSString *timeSp = [NSString stringWithFormat:@"%ld",visitlog.visitDate];
         [dateArray addObject:timeSp];
     }];
    
    params[@"id"] = [houseIds componentsJoinedByString:@";"];
    
    EBContact *contact = [EBContactManager sharedInstance].myContact;
    params[@"user_name"] = contact.name;
    if (contact.phone)
    {
        params[@"user_tel"] = contact.phone;
    }
    params[@"gender"] = contact.gender;
    params[@"company_name"] = [EBPreferences sharedInstance].companyName;
    params[@"customer_name"] = custName;
    
    params[@"timestamp"] = [dateArray componentsJoinedByString:@";"];
    
    
    [[EBHttpClient sharedInstance] houseRequest:params setShareData:^(BOOL success, id result)
     {
         
     }];
}

+(NSString *)contentShareUrl:(NSString *)key
{
    return [NSString stringWithFormat:@"%@%@", BEAVER_SHARE_URL, key];
}

+(NSString *)contentShareNewHouseUrl:(EBHouse *)house
{
    return [NSString stringWithFormat:NSLocalizedString(@"new_house_detail_format", nil), house.id];
}

+(NSString *)contentShareKey
{
    NSLog(@"userId=%@",[EBPreferences sharedInstance].userId);
    NSString *tag = [NSString stringWithFormat:@"%@%.2f", [EBPreferences sharedInstance].userId, NSDate.date.timeIntervalSince1970];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    const char *str = [tag UTF8String];
    CC_MD5(str, strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];

    for(NSInteger i = 0; i<CC_MD5_DIGEST_LENGTH; i++){
        [ret appendFormat:@"%02x", result[i]];
    }
    return [ret substringWithRange:NSMakeRange(8, 8)];
}

+ (NSString *)contentForHouses:(NSArray *)houses
{
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    for (EBHouse *house in houses)
    {
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendString:house.title];
        [content appendString:@", "];
        [content appendString:[NSString stringWithFormat:NSLocalizedString(@"house_room_format", nil), house.room]];
        [content appendString:@", "];

        NSString *areaDesc = [self areaDesc:house];
        if (areaDesc.length)
        {
            [content appendString:areaDesc];
            [content appendString:@", "];
        }

        if (house.rentalState == EHouseRentalTypeSale)
        {
            [content appendString:[NSString stringWithFormat:NSLocalizedString(@"sell_price_amount", nil), house.sellPrice.amount]];
        }
        else
        {
            [content appendString:[NSString stringWithFormat:@"%.0f/%@",house.rentPrice.unitCost, house.rentPrice.unit]];
        }

        [infoArray addObject:content];
    }

    return [infoArray componentsJoinedByString:@"; "];
}

+ (NSString *)contentForNewHouses:(NSArray *)houses
{
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    for (EBHouse *house in houses)
    {
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendString:house.title];
        
        [infoArray addObject:content];
    }
    
    return [infoArray componentsJoinedByString:@"; "];
}

+ (NSString *)contentForVisitLogs:(NSArray *)visitLogs
{
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    for (EBClientVisitLog *visitLog in visitLogs)
    {
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendString:visitLog.house.title];
        [content appendString:@", "];
        [content appendString:[NSString stringWithFormat:NSLocalizedString(@"house_room_format", nil), visitLog.house.room]];
        [content appendString:@", "];
        
        NSString *areaDesc = [self areaDesc:visitLog.house];
        if (areaDesc.length)
        {
            [content appendString:areaDesc];
            [content appendString:@", "];
        }
        
        if (visitLog.house.rentalState == EHouseRentalTypeSale)
        {
            [content appendString:[NSString stringWithFormat:NSLocalizedString(@"sell_price_amount", nil), visitLog.house.sellPrice.amount]];
        }
        else
        {
            [content appendString:[NSString stringWithFormat:@"%.0f/%@",visitLog.house.rentPrice.unitCost, visitLog.house.rentPrice.unit]];
        }
        
        [infoArray addObject:content];
    }
    
    return [infoArray componentsJoinedByString:@"; "];
}

//+ (NSString *)detailContentForHouses:(NSArray *)houses
//{
//    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
//    for (EBHouse *house in houses)
//    {
//        [infoArray addObject:[self imContentForHouse:house]];
//    }
//
//    return [infoArray componentsJoinedByString:@"; "];
//}

+ (NSString *)mailDelegationTail
{
   EBContact *myContact = [[EBContactManager sharedInstance] myContact];

   NSMutableString *tailString = [[NSMutableString alloc] init];
   [tailString appendString:NSLocalizedString(@"mail_greeting", nil)];
   [tailString appendString:@"\n\n"];

   if (myContact.name.length && myContact.phone.length)
   {
       [tailString appendFormat:@"%@ %@" ,myContact.name, myContact.phone];
   }
   else
   {
       [tailString appendString:myContact.name];
   }

   [tailString appendString:@"\n"];
   [tailString appendString:[EBPreferences sharedInstance].companyName];

   return tailString;
}

+ (NSString *)delegationTail
{
   EBContact *myContact = [[EBContactManager sharedInstance] myContact];

   if (myContact.name.length && myContact.phone.length)
   {
       return [NSString stringWithFormat:@"%@, %@", myContact.name, myContact.phone];
   }
   else
   {
       return myContact.name;
   }
}

+ (NSString *)smsContentForHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
    [NSString stringWithFormat:NSLocalizedString(@"share_sms_lead_format", nil),
                    [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];

    [content appendString:[self imContentForHouse:house]];
    [content appendString:@"。"];

    return content;
}

+ (NSString *)smsContentForHouses:(NSArray *)houses
{
    if (houses.count == 1)
    {
        return [self smsContentForHouse:houses[0]];
    }

    NSMutableString *content = [[NSMutableString alloc] initWithString:
            [NSString stringWithFormat:NSLocalizedString(@"share_sms_lead_format", nil),
                                       [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];

    [content appendString:[self contentForHouses:houses]];
    [content appendString:@"。"];

    return content;
}
+ (NSString *)smsContentForNewHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"share_sms_lead_format", nil),
                                 [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
    
    [content appendString:[self imContentForNewHouse:house]];
    [content appendString:@"。"];
    
    return content;
}

+ (NSString *)smsContentForVisitLog:(EBClientVisitLog *)visitLog client:(EBClient *)client
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"visit_sms_lead_format", nil),client.name]];
    
//    [content appendString:[self imContentForHouse:house]];
//    [content appendString:@"。"];
    
    return content;
}

+ (NSString *)smsContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client withKey:(NSString *)key
{
    EBClientVisitLog *vistLog = visitLogs[0];
//        return [self smsContentForVisitLog:vistLog client:client];
    NSMutableString *content = [[NSMutableString alloc] initWithString:[self smsContentForVisitLog:vistLog client:client]];
    [content appendString:[EBShare contentShareUrl:key]];
    [content appendString:@"。 "];
    [content appendString:[NSString stringWithFormat:@"\n%@  %@",[EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
    return content;
    
//    NSMutableString *content = [[NSMutableString alloc] initWithString:
//                                [NSString stringWithFormat:NSLocalizedString(@"share_sms_lead_format", nil),
//                                 [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
//    
//    [content appendString:[self contentForVisitLogs:visitLogs]];
//    [content appendString:@"。"];
    
//    return content;
}

+ (NSString *)mailContentForHouse:(EBHouse *)house  withKey:(NSString *)key
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
            [NSString stringWithFormat:NSLocalizedString(@"share_mail_lead_format_1", nil),
                                       [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
    NSMutableArray *houseContentItems = [self detailHouseContentItems:house];
    [content appendString:[houseContentItems componentsJoinedByString:@"\n"]];
    [content appendString:@"\n"];
    [content appendString:[EBShare contentShareUrl:key]];
    [content appendString:@"\n\n"];
    [content appendString:[self mailDelegationTail]];

    return content;
}

+ (NSString *)mailContentForHouses:(NSArray *)houses  withKey:(NSString *)key
{
    if (houses.count == 1)
    {
        return [self mailContentForHouse:houses[0] withKey:key];
    }

    NSMutableString *content = [[NSMutableString alloc] initWithString:
            [NSString stringWithFormat:NSLocalizedString(@"share_mail_lead_format", nil),
                                       [EBPreferences sharedInstance].companyName,
                            [EBContactManager sharedInstance].myContact.name, houses.count]];

    for (EBHouse *house in houses)
    {
        NSMutableArray *houseContentItems = [self detailHouseContentItems:house];
        [content appendString:[houseContentItems componentsJoinedByString:@"\n"]];

        [content appendString:[NSString stringWithFormat:@"\n%@/%@\n\n", [EBShare contentShareUrl:key], house.id]];
    }
//    [content appendString:[self detailContentForHouses:houses]];
    [content appendString:[self mailDelegationTail]];

    return content;
}

+ (NSString *)mailContentForNewHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"share_mail_lead_format_1", nil),
                                 [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
    [content appendString:house.title];
    [content appendString:@"\n"];
    [content appendString:[EBShare contentShareNewHouseUrl:house]];
    [content appendString:@"\n\n"];
    [content appendString:[self mailDelegationTail]];
    
    return content;
}

+ (NSString *)mailContentForVisitLog:(EBClientVisitLog *)visitLog  client:(EBClient *)client withKey:(NSString *)key
{
    NSInteger timeDate = visitLog.visitDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeDate];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
    NSString *date;
    if([array count] > 1)
    {
        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSInteger month = [dateArray[1] intValue];
        NSInteger day = [dateArray[2] intValue];
        date = [NSString stringWithFormat:NSLocalizedString(@"visit_month_day", nil), month , day];
    }
    else
    {
        date = confromTimespStr;
    }
    
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"visit_mail_lead_format", nil),
                                 client.name,[EBPreferences sharedInstance].companyName]];
    [content appendString:@"\n"];
    [content appendString:date];
    [content appendString:@"\n"];
    NSMutableArray *houseContentItems = [self detailHouseContentItems:visitLog.house];
    [content appendString:@"•  "];
    [content appendString:[houseContentItems componentsJoinedByString:@"，"]];
    [content appendString:@"， "];
    [content appendString:[EBShare contentShareUrl:key]];
    [content appendString:@"\n\n"];
    [content appendString:[self mailDelegationTail]];
    
    return content;
}

+ (NSString *)mailContentForVisitLogs:(NSArray *)visitLogs  client:(EBClient *)client withKey:(NSString *)key
{
    if (visitLogs.count == 1)
    {
        EBClientVisitLog *visitLog = visitLogs[0];
        return [self mailContentForVisitLog:visitLog client:client withKey:key];
    }
    
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"visit_mail_lead_format", nil),
                                 client.name , [EBPreferences sharedInstance].companyName]];
    for(int i = 0; i < [visitLogs count] ; i ++)
    {
        if(i < 4)
        {
            EBClientVisitLog *visitLog = visitLogs[i];
            NSInteger timeDate = visitLog.visitDate;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeDate];
            NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
            NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
            NSString *date;
            if([array count] > 1)
            {
                NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
                NSInteger month = [dateArray[1] intValue];
                NSInteger day = [dateArray[2] intValue];
                date = [NSString stringWithFormat:NSLocalizedString(@"visit_month_day", nil), month , day];
            }
            else
            {
                date = confromTimespStr;
            }
            [content appendString:@"\n"];
            [content appendString:date];
            [content appendString:@"\n"];
            NSMutableArray *houseContentItems = [self detailHouseContentItems:visitLog.house];
            [content appendString:@"•  "];
            [content appendString:[houseContentItems componentsJoinedByString:@"，"]];
            
            [content appendString:[NSString stringWithFormat:@"，%@/%@", [EBShare contentShareUrl:key], visitLog.house.id]];
        }
    }
    if([visitLogs count] > 4)
    {
        [content appendString:@"\n"];
        [content appendString:[NSString stringWithFormat:NSLocalizedString(@"visit_mail_all_logs", nil) , [EBShare contentShareUrl:key]]];
    }
    //    [content appendString:[self detailContentForHouses:houses]];
    [content appendString:@"\n"];
    [content appendString:[self mailDelegationTail]];
    
    return content;
}

+ (NSString *)mailTitleForVisitLogs
{
    NSString *format = NSLocalizedString(@"visit_mail_title_format", nil);
    return [NSString stringWithFormat:format, [EBPreferences sharedInstance].companyName];
}

+ (NSString *)mailSubjectForHouses:(NSArray *)houses
{
    EBContact *myContact = [[EBContactManager sharedInstance] myContact];
    if (houses.count == 1)
    {
        EBHouse *house = [houses firstObject];
        return  [NSString stringWithFormat:NSLocalizedString(@"share_mail_subject_format_1", nil),
                myContact.name, [NSString stringWithFormat:@"%@ %@ %@", house.title, [self roomDesc:house], [self areaDesc:house]]];
    }
    else
    {
        return  [NSString stringWithFormat:NSLocalizedString(@"share_mail_subject_format_n", nil),
                                           myContact.name, houses.count];
    }
}

+ (NSString *)mailSubjectForNewHouse:(EBHouse *)house
{
    EBContact *myContact = [[EBContactManager sharedInstance] myContact];
    return [NSString stringWithFormat:NSLocalizedString(@"share_mail_subject_format_nh", nil),
             myContact.name];
}

+ (NSString *)wbContentForHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:NSLocalizedString(@"share_wb_lead", nil)];

    [content appendString:[self imContentForHouse:house]];
    [content appendString:@"。"];
    [content appendString:[self delegationTail]];
    return content;
}

+ (NSString *)wbContentForHouses:(NSArray *)houses
{
    if (houses.count == 1)
    {
        return [self wbContentForHouse:houses[0]];
    }

    NSMutableString *content = [[NSMutableString alloc] initWithString:NSLocalizedString(@"share_wb_lead", nil)];
    [content appendString:[self contentForHouses:houses]];
    [content appendString:@"。"];
    [content appendString:[self delegationTail]];

    return content;
}

+ (NSString *)wbContentForNewHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:NSLocalizedString(@"share_wb_nh_lead", nil)];
    
    [content appendString:[self imContentForNewHouse:house]];
    [content appendString:@"。"];
    [content appendString:[self delegationTail]];
    return content;
}

+ (NSString *)wxContentForHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] init];

    [content appendString:[self imContentForHouse:house]];
    [content appendString:@"。"];
//    [content appendString:[self delegationTail]];

    return content;
}

+ (NSString *)wxContentForHouses:(NSArray *)houses
{
    if (houses.count == 1)
    {
        return [self wxContentForHouse:houses[0]];
    }

    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendString:[self contentForHouses:houses]];
    [content appendString:@"。"];
//    [content appendString:[self delegationTail]];

    return content;
}

+ (NSString *)wxContentForNewHouse:(EBHouse *)house
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"share_new_house_lead_format", nil),
                                 [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
    
    [content appendString:[self imContentForNewHouse:house]];
    [content appendString:@"。"];
    return content;
}

+ (NSString *)wxContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client
{
    if (visitLogs.count == 1)
    {
        EBClientVisitLog *vistLog = visitLogs[0];
        NSMutableString *content = [[NSMutableString alloc] init];
//        [content appendString:[self wxContentForHouse:vistLog.house]];
//        [content appendString:@"\n\n"];
        if(client)
         {
             [content appendString:[NSString  stringWithFormat:NSLocalizedString(@"share_wx_Text_format", nil),client.name , [EBPreferences sharedInstance].companyName]];
         }
        return content;
    }
    
    NSMutableString *content = [[NSMutableString alloc] init];
//    [content appendString:[self contentForVisitLogs:visitLogs]];
//    [content appendString:@"。"];
    if(client)
    {
//        [content appendString:@"\n\n"];
        [content appendString:[NSString  stringWithFormat:NSLocalizedString(@"share_wx_Text_format", nil),client.name , [EBPreferences sharedInstance].companyName]];
    }
    
    //    [content appendString:[self delegationTail]];
    
    return content;
}

+ (NSString *)qqContentForHouse:(EBHouse *)house
{
    return [self wxContentForHouse:house];
}

+ (NSString *)qqContentForHouses:(NSArray *)houses
{
    return [self wxContentForHouses:houses];
}

+ (NSString *)qqContentForNewHouse:(EBHouse *)house
{
    return [self wxContentForNewHouse:house];
}

+ (NSString *)qqContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client
{
    return [self wxContentForVisitLogs:visitLogs client:client];
}

+ (NSString *)wxFriendsContentForHouse:(EBHouse *)house
{
    return [self wxContentForHouse:house];
}

+ (NSString *)wxFriendsContentForHouses:(NSArray *)houses
{
    return [self wxContentForHouses:houses];
    if (houses.count == 1)
    {
        return [self wxFriendsContentForHouse:houses[0]];
    }
    NSMutableString *content = [[NSMutableString alloc] init];

    NSMutableArray *titles = [[NSMutableArray alloc] init];
    [houses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        EBHouse *house = (EBHouse *)obj;
        [titles addObject:house.title];
    }];

    [content appendString:[titles componentsJoinedByString:@", "]];

    return content;
}

+ (NSString *)wxFriendsContentForNewHouse:(EBHouse *)house
{
    return [self wxContentForNewHouse:house];
}

+ (NSString *)imContentForHouse:(EBHouse *)house
{
    NSMutableArray *houseContentItems = [self detailHouseContentItems:house];

    return [houseContentItems componentsJoinedByString:@", "];
}

+ (NSString *)imContentForNewHouse:(EBHouse *)house
{
    return house.title;
}

+ (NSString *)imContentForClient:(EBClient *)client
{
    NSMutableString *content = [[NSMutableString alloc] init];
    [content appendString:client.name];
    [content appendString:@", "];

    NSString *key = client.rentalState == EClientRequireTypeRent ? @"want_to_rent" : @"want_to_buy";
    [content appendString:NSLocalizedString(key, nil)];

    NSString *priceFormat = client.rentalState == EClientRequireTypeRent ?
            NSLocalizedString(@"rent_price_amount", nil) : NSLocalizedString(@"buy_price_amount", nil);
    NSString *priceInfo = [NSString stringWithFormat:priceFormat, [client.priceRange[0] floatValue], [client.priceRange[1] floatValue]];

    NSString *detailFormat = NSLocalizedString(@"client_require_share_format", nil);
    NSString *detail = [NSString stringWithFormat:detailFormat, [client.districts componentsJoinedByString:@", "],
                                                   client.roomRange[0], client.roomRange[1], client.areaRange[0], client.areaRange[1],
                                                   priceInfo];

    [content appendString:detail];

    if (client.urgent)
    {
        [content appendString:@", "];
        [content appendString:NSLocalizedString(@"tag_urgent", nil)];
    }

    if (client.fullPaid)
    {
        [content appendString:@", "];
        [content appendString:NSLocalizedString(@"tag_full_price", nil)];
    }

    return content;
}

+ (NSMutableArray *)detailHouseContentItems:(EBHouse *)house
{
    NSMutableArray *houseItems = [[NSMutableArray alloc] init];

    [houseItems addObject:house.title];

    NSString *roomDesc = [self roomDesc:house];
    if (roomDesc.length)
    {
        [houseItems addObject:roomDesc];
    }

    NSString *areaDesc = [self areaDesc:house];
    if (areaDesc.length)
    {
        [houseItems addObject:areaDesc];
    }

    if (house.rentalState == EHouseRentalTypeSale)
    {
        [houseItems addObject:[NSString stringWithFormat:NSLocalizedString(@"sell_price_amount", nil), house.sellPrice.amount]];
    }
    else
    {
        [houseItems addObject:[NSString stringWithFormat:@"%@%@",house.rentPrice.amount, house.rentPrice.unit]];
    }

    if (house.urgent)
    {
        [houseItems addObject:NSLocalizedString(@"tag_urgent", nil)];
    }

//    NSString *key = [NSString stringWithFormat:@"tag_%@", house.access == EHouseAccessTypePrivate ? @"private" : @"public"];
//    [houseItems addObject:NSLocalizedString(key, nil)];

    return houseItems;
}

+(NSString *)rentPriceDesc:(EBHouse *)house
{
    return [NSString stringWithFormat:@"%@%@", house.rentPrice.amount, house.rentPrice.unit];
}

+(NSString *)salePriceDesc:(EBHouse *)house
{
    return [NSString stringWithFormat:@"%@%@", house.rentPrice.amount, NSLocalizedString(@"amount_unit", nil)];
}

+(NSString *)roomDesc:(EBHouse *)house
{
    if (house.room > 0 && house.hall > 0)
    {
        return [NSString stringWithFormat:@"%ld%@%ld%@", house.room,
                                          NSLocalizedString(@"room_unit", nil), house.hall,
                                          NSLocalizedString(@"hall_unit", nil)];
    }
    else if (house.room > 0)
    {
        return [NSString stringWithFormat:@"%ld%@", house.room,
                                          NSLocalizedString(@"room_unit", nil)];
    }
    else if (house.hall > 0)
    {
        return [NSString stringWithFormat:@"%ld%@", house.hall,
                                          NSLocalizedString(@"hall_unit", nil)];
    }
    else
    {
        return @"";
    }
}

+(NSString *)areaDesc:(EBHouse *)house
{
    return [NSString stringWithFormat:@"%.0f%@", house.area,
                                      NSLocalizedString(@"area_unit", nil)];
}

+ (void)filterSnsEntries:(NSMutableArray *)entries
{
    if (![WXApi isWXAppSupportApi])
    {
        [entries removeObject:@(EShareTypeWeChat)];
        [entries removeObject:@(EShareTypeWeChatFriend)];
    }

    if (![MFMailComposeViewController canSendMail])
    {
        [entries removeObject:@(EShareTypeMail)];
    }

    if (![MFMessageComposeViewController canSendText])
    {
        [entries removeObject:@(EShareTypeMessage)];
    }

    if (![QQApiInterface isQQSupportApi])
    {
        [entries removeObject:@(EShareTypeQQ)];
        [entries removeObject:@(EShareTypeQQZone)];
    }
}

+ (NSArray *)shareEntries:(BOOL)multipleShareItems
{
    //lwl
//   NSMutableArray *allEntries = [@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9,@10] mutableCopy];
    NSMutableArray *allEntries = [@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9] mutableCopy];
   if (multipleShareItems)
   {
        allEntries = [@[@0, @1, @2, @3, @4, @5, @6, @7, @8] mutableCopy];
   }
   [self filterSnsEntries:allEntries];
   return allEntries;
}

+ (NSArray *)sendEntries
{
    NSMutableArray *targetEntries = [@[@0, @2, @5, @6] mutableCopy];
    [self filterSnsEntries:targetEntries];
    return targetEntries;
}

+ (NSString *)imContentForAppointment:(EBAppointment *)appointment
{
   NSString *format = NSLocalizedString(@"appointment_im_content_format", nil);
   return [NSString stringWithFormat:format, [EBTimeFormatter formatAppointmentTimeToClient:appointment.timestamp], appointment.addressTitle];
}

+ (NSString *)smsContentForAppointment:(EBAppointment *)appointment  url:(NSString *)url
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *format = NSLocalizedString(@"appointment_sms_content_format", nil);
    return [NSString stringWithFormat:format, appointment.client.name,
                    [EBTimeFormatter formatAppointmentTimeToClient:appointment.timestamp], appointment.addressTitle, url,
            pref.companyName, pref.userName];
}

+ (NSString *)mailContentForAppointment:(EBAppointment *)appointment url:(NSString *)url
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:
                                [NSString stringWithFormat:NSLocalizedString(@"invite_mail_lead_format_1", nil),
                                 [EBPreferences sharedInstance].companyName, [EBContactManager sharedInstance].myContact.name]];
    NSInteger time = appointment.timestamp;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
    NSString *timeShow;
    
    if([array count] > 1)
    {
        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
        if(([dateArray count] > 2) && ([timeArray count] > 2))
        {
            int hour = [timeArray[0] intValue];
            timeShow = [NSString stringWithFormat:@"•  时间：%@月%@日%d点%@分",dateArray[1],dateArray[2],hour,timeArray[1]];
        }
        else
            timeShow = confromTimespStr;
    }
    else
    {
        timeShow = confromTimespStr;
    }
    [content appendString:timeShow];
    [content appendString:@"\n"];
    [content appendString:[NSString stringWithFormat:@"•  地点：%@",appointment.addressTitle]];
    [content appendString:@"\n"];
    if(appointment.latitude > 0)
    {
        [content appendString:[NSString stringWithFormat:@"•  地址：%@",appointment.addressDetail]];
        [content appendString:@"\n"];
        [content appendString:[NSString stringWithFormat:@"•  地图和详情请点击：%@",url]];
        [content appendString:@"\n"];
    }
    
    [content appendString:@"\n"];
    [content appendString:@"祝您万事如意。"];
    [content appendString:@"\n\n"];
    [content appendString:[NSString stringWithFormat:@"%@ %@",[EBContactManager sharedInstance].myContact.name,[EBContactManager sharedInstance].myContact.phone]];
     [content appendString:@"\n"];
     [content appendString:[EBPreferences sharedInstance].companyName];
    
   return content;
}

+ (NSString *)mailTitleForAppointment:(EBAppointment *)appointment
{
    NSString *format = NSLocalizedString(@"appointment_mail_title_format", nil);
    return [NSString stringWithFormat:format, [EBTimeFormatter formatAppointmentTimeToClient:appointment.timestamp],
                    appointment.addressTitle];
}

@end