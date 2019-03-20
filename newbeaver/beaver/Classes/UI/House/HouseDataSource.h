//
//  HouseDataSource.h
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBListView.h"
#import "EBPagedDataSource.h"

typedef void(^TChangeMarkedStatus)(BOOL);

@interface HouseDataSource : EBPagedDataSource

@property(nonatomic, assign) BOOL marking;
@property(nonatomic, copy) TChangeMarkedStatus changeMarkedStausBlock;

@property (nonatomic) BOOL showImage;

@end
