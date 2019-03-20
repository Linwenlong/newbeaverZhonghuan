//
//  HouseDetailViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBNumberStatus.h"
#import "AnonymousCallViewController.h"
#import "EBController.h"

@class EBHouse;

@interface HouseDetailViewController : BaseViewController

@property (nonatomic, strong) EBHouse *houseDetail;
@property (nonatomic, strong) EBNumberStatus *numStatus;
@property (nonatomic, assign) EHouseDetailOpenType pageOpenType;
@property (nonatomic, assign) BOOL isUplaodForNewHouse;

@property (nonatomic, strong) NSDictionary *appParam;

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
