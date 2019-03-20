//
//  EBAnonymousCallAlertView.h
//  beaver
//
//  Created by wangyuliang on 14-6-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "CustomIOS7AlertView.h"

typedef NS_ENUM(NSInteger , EAlertype)
{
    EAlertypeStart = 1,
    EAlertypePhone = 2,
    EAlertypeInput = 3,
    EAlertypeEnd = 4
};

@interface EBAnonymousCallAlertView : CustomIOS7AlertView

@property (nonatomic, copy) void(^completion)();
@property (nonatomic)  NSInteger showType;

@end
