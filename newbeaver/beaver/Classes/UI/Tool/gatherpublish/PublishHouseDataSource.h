//
//  PublishHouseDataSource.h
//  beaver
//
//  Created by wangyuliang on 14-9-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBPagedDataSource.h"
#import "PublishHouseItemView.h"

typedef void(^refreshPublishListBlock)(BOOL refresh);

@interface PublishHouseDataSource : EBPagedDataSource <PublishHouseItemDelegate>

@property (nonatomic, assign) EPublishHouseItemType showItemType;

@property (nonatomic, strong) NSMutableArray *touchTag;

@property (nonatomic, copy) refreshPublishListBlock refreshBlock;

- (void)createTouchTag;

@end
