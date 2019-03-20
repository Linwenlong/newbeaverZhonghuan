//
// Created by 何 义 on 14-3-29.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMConversation.h"

@class EBContact;

@interface EBContactManager : NSObject

+ (EBContactManager *)sharedInstance;

- (void)contactsChanged:(NSArray *)contactIds;
- (void)synchronizeContacts:(void(^)(BOOL success))completion;
- (NSString *)contactsVersion;
- (void)cacheContacts:(NSArray *)contactArray version:(NSString *)version;
- (NSArray *)contactsByKeyword:(NSString *)keyword;

- (NSArray *)contactsLWLByKeyword:(NSString *)keyword;//lwl

- (NSArray *)contactsPhoneByKeyword:(NSString *)keyword;//lwl

- (NSArray *)allContacts;
- (NSArray *)nonAllContacts;

- (EBContact *)contactById:(NSString *)id;
- (EBContact *)myContact;

@end