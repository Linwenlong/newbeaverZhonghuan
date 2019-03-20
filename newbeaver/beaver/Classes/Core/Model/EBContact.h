//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBContact : EBBaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *deptTel;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *deptId;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *gender; //m, f
@property (nonatomic, assign) BOOL special;
@property (nonatomic, assign) BOOL notFound;
@property (nonatomic, assign) BOOL fromOtherPlatform;//是否来自其他平台
@property (nonatomic, assign) NSInteger localId;
@property (nonatomic, copy) NSString *happenDate;

@property (nonatomic, copy) NSString *pinyin;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSString *firstLetter;

@end