//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMBaseModel.h"
#import "FMResultSet.h"


@implementation EBIMBaseModel

- (id)initWithFMResultSet:(FMResultSet *)rs
{
    self = [super init];
    if (self)
    {
        [self parseFromRs:rs];
    }
    return self;
}

- (void)parseFromRs:(FMResultSet *)rs
{
    _timestamp = [rs intForColumn:@"Ftime"];
}

@end