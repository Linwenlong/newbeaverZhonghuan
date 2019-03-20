//
//  ClientDataSourceCollection.h
//  beaver
//
//  Created by wangyuliang on 14-6-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBPagedDataSource.h"
#import "EBListView.h"

@class EBClient;

typedef void(^TClickOnClient)(EBClient *);

@interface ClientDataSourceCollection : EBPagedDataSource

@property(nonatomic, assign) BOOL marking;
@property(nonatomic, copy) TClickOnClient clickBlock;

@end
