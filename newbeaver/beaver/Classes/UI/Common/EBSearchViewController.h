//
// Created by 何 义 on 14-7-3.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "BaseViewController.h"
#import "EBSearch.h"


@interface EBSearchViewController : BaseViewController

@property (nonatomic, assign) EBSearchType searchType;
@property (nonatomic, copy) void(^handleSelections)(NSArray *);

@end