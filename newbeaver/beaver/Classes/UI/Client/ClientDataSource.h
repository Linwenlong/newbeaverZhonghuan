//
//  HouseDataSource.h
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBListView.h"
#import "EBPagedDataSource.h"

@class EBClient;

typedef void(^TClickOnClient)(EBClient *);
typedef void(^TChangeMarkedStatus)(BOOL);

@interface ClientDataSource : EBPagedDataSource

@property(nonatomic, assign) BOOL marking;
@property(nonatomic, copy) TClickOnClient clickBlock;
@property(nonatomic, copy) TChangeMarkedStatus changeMarkedStausBlock;


@end


//@interface ClientDataSourceInvite : EBPagedDataSource
//
//@property(nonatomic, assign) BOOL marking;
//@property(nonatomic, copy) TClickOnClient clickBlock;
//
//@end
