//
// Created by 何 义 on 14-4-12.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "MobClick.h"


@implementation EBTrack

+ (void)start
{
//  53211fb056240bd993058863
//    [UMConfigure initWithAppkey:MobClickappKey channel:@"App Store"];
    [MobClick startWithAppkey:MobClickappKey];
    [MobClick setAppVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

+ (void)event:(NSString *)eventID
{
    [MobClick event:eventID];
}

+ (void)event:(NSString *)eventID count:(NSInteger)count
{

}

+ (void)beginLogPageView:(NSString *)pageName
{
   [MobClick beginLogPageView:pageName];
}

+ (void)endLogPageView:(NSString *)pageName
{
    [MobClick endLogPageView:pageName];
}

@end
