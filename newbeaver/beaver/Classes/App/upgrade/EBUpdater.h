//
// Created by 何 义 on 14-4-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface EBUpdater : NSObject

+(NSString *)localVersion;
+(BOOL)hasUpdate;
+(BOOL)isForcedUpdate;
+(NSString *)currentOnlineVersion;
+(NSString *)newVersionUrl;
+(void)newVersionAvailable:(NSString *)version url:(NSString *)url force:(BOOL)force;
+(void)clearNewVersionReminder;

@end