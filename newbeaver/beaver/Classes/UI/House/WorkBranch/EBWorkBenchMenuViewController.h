//
//  EBShopViewController.h
//  beaver
//  菜单列表页
//  Created by 凯文马 on 15/12/16.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface EBWorkBenchMenuViewController : BaseViewController

@property (nonatomic, strong) NSArray *items;

@end


@interface EBWorkBenchItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) BOOL tips;
@property (nonatomic, assign) BOOL isWap;

+ (instancetype)itemWithDict:(NSDictionary *)dict;
+ (NSArray *)itemsWithDicts:(NSArray *)dicts;

@end