//
//  SinaWeiboPreferences.h
//  chow
//
//  Created by ChenYing on 14-10-13.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import "DDGPreferences.h"

@interface SinaWeiboPreferences : DDGPreferences

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, copy) NSString *refreshToken;

- (BOOL)isAuthValid;
- (void)clearCache;

@end
