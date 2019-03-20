//
// Created by 何 义 on 14-7-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBBaseModel.h"


@interface EBConfiguration : EBBaseModel

@property (nonatomic, strong) NSDictionary *statusMap;
@property (nonatomic, strong) NSArray *purposes;
@property (nonatomic, strong) NSDictionary *recommendTags;
@property (nonatomic, strong) NSArray *reportTypes;
@property (nonatomic, strong) NSArray *appellations; // 称呼：先生，女士等
@property (nonatomic, strong) NSArray *telDescriptions;
@property (nonatomic, strong) NSArray *photoDescriptions;
@property (nonatomic, strong) NSDictionary *followTypes;
@property (nonatomic, strong) NSArray *wantNew;
@property (nonatomic) BOOL allowAdd;

@property (nonatomic,strong)NSDictionary *housingType;

@end


@interface EBBusinessConfig : EBBaseModel

@property (nonatomic, strong) EBConfiguration *houseConfig;
@property (nonatomic, strong) EBConfiguration *clientConfig;

@end

