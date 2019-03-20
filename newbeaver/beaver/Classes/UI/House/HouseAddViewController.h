//
//  HouseAddViewController.h
//  beaver
//
//  Created by LiuLian on 7/25/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ParserContainerViewController.h"

@class EBHouse;

@interface HouseAddViewController : ParserContainerViewController


@property (nonatomic,assign) NSInteger floor;//当前楼层
@property (nonatomic,assign) NSInteger lists;//梯
@property (nonatomic,assign) NSInteger rooms;//户
@property (nonatomic,assign) NSInteger totle_floor;//总楼层

//房号锁定
@property (nonatomic, assign) CGFloat usable_area;      //使用面积
@property (nonatomic, assign) NSInteger room;      //室
@property (nonatomic, assign) NSInteger living_room;      //厅
@property (nonatomic, assign) NSInteger washroom;      //卫
@property (nonatomic, assign) NSInteger balcony; //阳台



@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) NSMutableArray *uploadPhotos;

@property (nonatomic) BOOL editFlag;
@property (nonatomic, weak) EBHouse *house;


@end
