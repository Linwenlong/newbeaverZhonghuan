//
// Created by 何 义 on 14-5-31.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface EBMapPOI : NSObject

@property (nonatomic, strong) NSString *name; // 名称
@property (nonatomic, strong) NSString *address; // 地址
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) NSInteger cityCode;
@property (nonatomic, strong) NSArray *nearbyPois;

@end