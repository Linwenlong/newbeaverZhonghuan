//
// Created by 何 义 on 14-4-12.
// Copyright (c) 2014 eall. All rights reserved.
//

// 13789013891

#import "EBTrackEvents.h"

@interface EBTrack : NSObject

+ (void)start;

+ (void)event:(NSString *)eventID;
+ (void)event:(NSString *)eventID count:(NSInteger)count;

+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

@end