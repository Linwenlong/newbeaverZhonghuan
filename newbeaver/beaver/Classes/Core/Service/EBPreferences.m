//
// Created by 何 义 on 14-3-20.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBPreferences.h"


@implementation EBPreferences

+ (EBPreferences *)sharedInstance
{
    static dispatch_once_t pred;
    static EBPreferences *_sharedInstance = nil;

    dispatch_once(&pred, ^{
        _sharedInstance = [EBPreferences new];

    });
    return _sharedInstance;
}

#pragma mark -- 验证token是否可以用
- (BOOL)isTokenValid
{
   if (_token == nil || ![_token isKindOfClass:[NSString class]] || _token.length == 0)
   {
       return NO;
   }
//   NSTimeInterval now = (NSInteger)NSDate.date.timeIntervalSince1970;
//   if (now < _loginTime)
//   {
//       return NO;
//   }
//   if (now - _loginTime > _tokenLife)
//   {
//       return NO;
//   }
   return YES;
}

+ (NSString *)systemIMIDEALL
{
   return @"beaver";
}

//返回信息编码
+ (NSString *)systemIMIDCompany
{
   return [EBPreferences sharedInstance].companyCode;
}

//返回信息编码
+ (NSString *)systemIMIDNewHouse
{
    return [NSString stringWithFormat:@"%@_newhouse",[EBPreferences sharedInstance].companyCode];
}

//重新更新设置信息
- (void)resetPref
{
    self.token = @"";
    self.deviceToken = @"";
    self.ticket = @"";
    self.loginTime = 0;
    self.tokenLife = 0;
    self.deviceTokenGot = NO;

    self.companyName = @"";
    self.userId = @"";
    self.phone = @"";
    self.userName = @"";
    self.storeName = @"";
//    self.city = @"";

    [self writePreferences];
}


@end
