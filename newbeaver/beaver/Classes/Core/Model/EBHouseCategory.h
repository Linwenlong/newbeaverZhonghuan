//
//  EBHouseCategory.h
//  beaver
//
//  Created by 何 义 on 14-3-6.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBHouseCategory : EBBaseModel

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *des;
@property (nonatomic, copy, readonly) NSString *id;
@property (nonatomic, copy) NSString *count;
@property (nonatomic, assign) BOOL isCustom;
@property (nonatomic, strong) NSDictionary *condition;

// for display
@property (nonatomic, assign) CGFloat cellHeight;

@end
