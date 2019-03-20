//
//  SinaWeiboPreferences.m
//  chow
//
//  Created by ChenYing on 14-10-13.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import "SinaWeiboPreferences.h"

@implementation SinaWeiboPreferences

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static SinaWeiboPreferences *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [SinaWeiboPreferences new];
    });
    return _sharedInstance;
}

- (void)clearCache
{
    _userID = nil;
    _accessToken = nil;
    _expirationDate = nil;
    _refreshToken = nil;
}

/**
 * @description 判断登录是否有效，当已登录并且登录未过期时为有效状态
 * @return YES为有效；NO为无效
 */
- (BOOL)isAuthValid
{
    if (_userID && _accessToken && _expirationDate) {
        NSDate *now = [NSDate date];
        return [now compare:
                _expirationDate] != NSOrderedDescending;
    }
    return NO;
}

@end
