//
// Created by 何 义 on 14-4-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBUpdater.h"
#import "EBController.h"


#define KEY_UPDATE_FORCE @"EB_FORCED_UPDATE"
#define KEY_NEW_VERSION @"EB_ONLINE_VERSION"
#define KEY_NEW_VERSION_URL @"EB_ONLINE_VERSION_URL"

@implementation EBUpdater
//当前的版本
+(NSString *)localVersion
{
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
//是否可以更新
+(BOOL)hasUpdate
{
    NSString *currentVersion = [self localVersion];
    NSLog(@"currentVersion=%@",currentVersion);
    //线上版本
    NSString *onlineVersion = [self currentOnlineVersion];
    NSLog(@"onlineVersion=%@",onlineVersion);
    if ((!onlineVersion || onlineVersion.length == 0) ||
            [currentVersion isEqualToString:onlineVersion])
    {
         return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)isForcedUpdate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_UPDATE_FORCE];
}

+(NSString *)currentOnlineVersion
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:KEY_NEW_VERSION];
}

+(void)newVersionAvailable:(NSString *)version url:(NSString *)url force:(BOOL)force;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:KEY_NEW_VERSION];
    [defaults setObject:url forKey:KEY_NEW_VERSION_URL];
    [defaults setBool:force forKey:KEY_UPDATE_FORCE];
    [defaults synchronize];
    
    if ([self hasUpdate])
    {
        [EBController broadcastNotification:[NSNotification
                notificationWithName: force ? NOTIFICATION_VERSION_FORCE_UPDATE : NOTIFICATION_VERSION_UPDATE object:nil]];
    }

}

+(void)clearNewVersionReminder
{
    NSString *currentVersion = [self currentOnlineVersion];
    if (currentVersion)
    {
       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
       [defaults removeObjectForKey:KEY_NEW_VERSION];
       [defaults removeObjectForKey:KEY_NEW_VERSION_URL];
       [defaults removeObjectForKey:KEY_UPDATE_FORCE];
       [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_VERSION_NO_UPDATE object:nil]];
    }
}

+(NSString *)newVersionUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KEY_NEW_VERSION_URL];
}

@end