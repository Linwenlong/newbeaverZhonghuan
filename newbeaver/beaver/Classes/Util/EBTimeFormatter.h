//
// Created by 何 义 on 14-4-15.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface EBTimeFormatter : NSObject

+ (NSString *) formatMessageTime:(NSInteger)time;
+ (NSString *) formatAppointmentTime:(NSInteger)time;
+ (NSString *) formatAppointmentTimeToClient:(NSInteger)time;
+ (NSString *) formatConversationTime:(NSInteger)time;
+ (NSString *) formatRentExpirationTime:(NSInteger)time;

@end