//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMBaseModel.h"

@class EBContact;

@interface EBIMGroup : EBIMBaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *globalId;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) BOOL saved;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, copy) NSString *adminId;

- (NSString *)groupTitle;
- (void)ensureGroupTitle;

@end