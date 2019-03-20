//
// Created by 何 义 on 14-7-11.
// Copyright (c) 2014 eall. All rights reserved.
//


@class EBNumberStatus;
typedef NS_ENUM(NSInteger , ECallEventType){
    ECallEventTypeHouse = 1,
    ECallEventTypeClient
};

@interface EBCallEventHandler : NSObject

+(void)clickPhoneButton:(UIButton *)btn withParams:(NSDictionary *)params  numStatus:(EBNumberStatus *)numberStatus timesRemain:(NSInteger)timesRemain
           phoneNumbers:(NSArray *)phoneNumbers type:(ECallEventType)type phoneGotHandler:(void(^)(BOOL success, id result))handler inView:(UIView *)view;


@end