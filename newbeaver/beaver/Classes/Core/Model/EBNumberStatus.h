//
//  EBNumberStatus.h
//  beaver
//
//  Created by wangyuliang on 14-7-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBNumberStatus : EBBaseModel

@property (nonatomic, copy) NSString *anonymousNumber;//!为空代表号码未启用
@property (nonatomic, copy) NSString *tel;
@property (nonatomic) BOOL enableAnonymous;//!公司级别启用
@property (nonatomic) BOOL canShowNumber;//!yes 号码已启用  no 号码正在验证
@property (nonatomic) NSInteger isNumberVerified;
@property (nonatomic, copy) NSString *verifyDesc;

@end
