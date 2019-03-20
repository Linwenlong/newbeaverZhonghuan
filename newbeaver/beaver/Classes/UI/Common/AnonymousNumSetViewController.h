//
//  AnonymousNumSetViewController.h
//  beaver
//
//  Created by wangyuliang on 14-7-9.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger , ESetType)
{
    ESetTypeMobile = 1,
    ESetTypeFix = 2,
    ESetTypeFixSingle = 3
};

@interface AnonymousNumSetViewController : BaseViewController

@property (nonatomic)  NSInteger setType;
@property (nonatomic, copy) void(^phoneVerifySuccess)();

@end
