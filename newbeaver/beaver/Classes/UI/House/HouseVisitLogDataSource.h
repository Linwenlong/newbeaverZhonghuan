//
//  HouseInviteDataSource.h
//  beaver
//
//  Created by wangyuliang on 14-5-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBPagedDataSource.h"
#import "ClientItemView.h"

@class EBClient;

typedef void(^TClickOnClient)(EBClient *);

@interface HouseVisitLogDataSource : EBPagedDataSource

@property(nonatomic, assign) BOOL marking;
@property(nonatomic, copy) TClickOnClient clickBlock;

@end

