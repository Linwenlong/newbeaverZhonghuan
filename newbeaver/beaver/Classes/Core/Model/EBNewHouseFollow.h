//
//  EBNewHouseFollow.h
//  beaver
//
//  Created by ChenYing on 14-8-12.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBNewHouseFollow : EBBaseModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *statusNote;
@property (nonatomic, copy) NSString *statusTitle;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *updateDate;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *companyId;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *agentId;
@property (nonatomic, copy) NSString *agentName;
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *clientName;
@property (nonatomic, copy) NSString *clientPhone;
@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, strong) NSArray *statusLog;

@end
