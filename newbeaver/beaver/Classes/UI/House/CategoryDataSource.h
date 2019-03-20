//
//  CategoryDataSource.h
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBListView.h"

typedef NS_ENUM(NSInteger , ECategoryDataSourceType){
    ECategoryDataSourceTypeHouse = 0,
    ECategoryDataSourceTypeGatherHouse = 1,
};


@interface CategoryDataSource : NSObject<EBListDataSource>

@property(nonatomic, assign) ECategoryDataSourceType categoryType;

@end
