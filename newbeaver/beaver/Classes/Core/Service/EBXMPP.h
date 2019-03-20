//
// Created by 何 义 on 14-3-20.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "DDGPreferences.h"

@class EBIMMessage;
@class EBContact;
@class EBIMGroup;

@interface EBXMPP : NSObject

+ (EBXMPP *)sharedInstance;

//- (void)loginWithAccount:(NSString *)userName password:(NSString *)password;
- (void)login;
- (void)logout;

- (void)sendMessage:(EBIMMessage *)message handler:(void(^)(BOOL success, NSDictionary *result))handler;

- (void)configPushNotification:(NSString *)objId block:(BOOL)block isGroup:(BOOL)isGroup
                       handler:(void(^)(BOOL success, NSDictionary *result))handler;

- (void)group:(EBIMGroup *)group createWithHandler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)group:(EBIMGroup *)group quitWithHandler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)group:(EBIMGroup *)group deleteMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)group:(EBIMGroup *)group addMembers:(NSArray *)members handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)group:(EBIMGroup *)group fetchMemebers:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)group:(EBIMGroup *)group setName:(NSString *)name handler:(void(^)(BOOL success, NSDictionary *info))handler;

@end