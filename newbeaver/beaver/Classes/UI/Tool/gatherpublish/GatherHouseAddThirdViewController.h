//
//  GatherHouseAddThirdViewController.h
//  beaver
//
//  Created by wangyuliang on 14-8-29.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ParserContainerViewController.h"

@class EBHouse;
@class EBGatherHouse;

@interface GatherHouseAddThirdViewController : ParserContainerViewController

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) NSMutableArray *uploadPhotos;

@property (nonatomic, weak) EBHouse *house;

@property (nonatomic, weak) EBGatherHouse *gatherHouse;

@end
