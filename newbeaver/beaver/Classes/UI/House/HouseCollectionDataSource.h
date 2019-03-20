//
//  HouseCollectionDataSource.h
//  beaver
//
//  Created by wangyuliang on 14-6-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBPagedDataSource.h"
#import "EBListView.h"

@interface HouseCollectionDataSource : EBPagedDataSource

@property(nonatomic, assign) BOOL marking;
@property (nonatomic) BOOL showImage;

@end
