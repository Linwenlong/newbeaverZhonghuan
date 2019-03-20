//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


@class FMResultSet;


@interface EBIMBaseModel : NSObject

@property (nonatomic, assign) NSInteger timestamp;

- (id)initWithFMResultSet:(FMResultSet *)rs;
- (void)parseFromRs:(FMResultSet *)rs;

@end