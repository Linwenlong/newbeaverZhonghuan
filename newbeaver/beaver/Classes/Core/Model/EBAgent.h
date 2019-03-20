//
//  EBAgent.h
//  beaver
//
//  Created by ChenYing on 14-8-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"
#import "EBContact.h"

@interface EBAgent : EBBaseModel

@property (nonatomic, copy) NSString *deptName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userTel;
@property (nonatomic, copy) NSString *happenDate;

@end
