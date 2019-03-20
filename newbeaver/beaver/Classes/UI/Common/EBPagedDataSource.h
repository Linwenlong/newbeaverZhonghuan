//
// Created by 何 义 on 14-3-20.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBListView.h"

@class EBFilter;

typedef void(^TRequestBlock)(NSDictionary *, void(^)(BOOL successful, id result));

@interface EBPagedDataSource : NSObject <EBListDataSource>

@property (nonatomic, strong) EBFilter *filter;
@property (nonatomic, readonly) NSMutableArray *dataArray;
@property (nonatomic, readonly) NSMutableSet *selectedSet;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger pageSize;
@property (nonatomic, copy) TRequestBlock requestBlock;

@end