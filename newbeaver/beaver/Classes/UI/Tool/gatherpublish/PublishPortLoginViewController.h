//
//  PublishPortLoginViewController.h
//  beaver
//
//  Created by LiuLian on 8/29/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger , EBPortOperateType)
{
    EBPortOperateLogin = 1,
    EBPortOperateRefresh = 2,
};

@interface PublishPortLoginViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *port;
@property (nonatomic) BOOL isEdit;
@property (nonatomic, copy) void (^editSuccess)(NSDictionary *port);
@end
