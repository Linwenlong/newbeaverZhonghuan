//
// Created by 何 义 on 14-4-4.
// Copyright (c) 2014 eall. All rights reserved.
//


@class EBHouse;
@class EBClient;
@class EBAppointment;


@interface EBShare : NSObject

+ (void)setShareHouses:(NSArray *)houses forKey:(NSString *)key;
+ (void)setShareVisitLogs:(NSArray *)visitLogs forKey:(NSString *)key forCustomName:(NSString *)custName;

+ (NSString *)imContentForAppointment:(EBAppointment *)appointment;
+ (NSString *)smsContentForAppointment:(EBAppointment *)appointment url:(NSString *)url;
+ (NSString *)mailContentForAppointment:(EBAppointment *)appointment url:(NSString *)url;
+ (NSString *)mailTitleForAppointment:(EBAppointment *)appointment;
+ (NSString *)mailTitleForVisitLogs;

+ (NSString *)smsContentForHouse:(EBHouse *)house;
+ (NSString *)smsContentForHouses:(NSArray *)houses;
+ (NSString *)smsContentForNewHouse:(EBHouse *)house;
+ (NSString *)smsContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client withKey:(NSString *)key;

+ (NSString *)mailContentForHouse:(EBHouse *)house withKey:(NSString *)key;
+ (NSString *)mailContentForHouses:(NSArray *)houses withKey:(NSString *)key;
+ (NSString *)mailSubjectForHouses:(NSArray *)houses;
+ (NSString *)mailSubjectForNewHouse:(EBHouse *)house;
+ (NSString *)mailContentForNewHouse:(EBHouse *)house;
+ (NSString *)mailContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client withKey:(NSString *)key;

+ (NSString *)wbContentForHouse:(EBHouse *)house;
+ (NSString *)wbContentForHouses:(NSArray *)houses;
+ (NSString *)wbContentForNewHouse:(EBHouse *)house;

+ (NSString *)wxContentForHouse:(EBHouse *)house;
+ (NSString *)wxContentForHouses:(NSArray *)houses;
+ (NSString *)wxContentForNewHouse:(EBHouse *)house;
+ (NSString *)wxContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client;

+ (NSString *)wxFriendsContentForHouse:(EBHouse *)house;
+ (NSString *)wxFriendsContentForHouses:(NSArray *)houses;
+ (NSString *)wxFriendsContentForNewHouse:(EBHouse *)house;

+ (NSString *)qqContentForHouse:(EBHouse *)house;
+ (NSString *)qqContentForHouses:(NSArray *)houses;
+ (NSString *)qqContentForNewHouse:(EBHouse *)house;
+ (NSString *)qqContentForVisitLogs:(NSArray *)visitLogs client:(EBClient *)client;

+ (NSString *)imContentForClient:(EBClient *)client;
+ (NSString *)imContentForHouse:(EBHouse *)house;
+ (NSString *)imContentForNewHouse:(EBHouse *)house;

+ (NSString *)contentShareKey;
+ (NSString *)contentShareUrl:(NSString *)key;
+ (NSString *)contentShareNewHouseUrl:(EBHouse *)house;

+ (UIImage *)coverForHouses:(NSArray *)houses;
+ (UIImage *)coverForVisitLogs:(NSArray *)visitLogs;

+ (NSString *)rentPriceDesc:(EBHouse *)house;
+ (NSString *)salePriceDesc:(EBHouse *)house;
+ (NSString *)roomDesc:(EBHouse *)house;
+ (NSString *)areaDesc:(EBHouse *)house;

+ (NSArray *)shareEntries:(BOOL)multipleShareItems;
+ (NSArray *)sendEntries;

@end