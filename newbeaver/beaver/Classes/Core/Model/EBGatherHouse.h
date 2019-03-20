//
//  EBGatherHouse.h
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"

typedef NS_ENUM(NSInteger , EGatherHouseRentalType)
{
    EGatherHouseRentalTypeRent = 1,
    EGatherHouseRentalTypeSale = 2,
};
typedef NS_ENUM(NSInteger , EGatherHouseTelType)
{
    EGatherHouseTelTypePlain = 1,
    EGatherHouseTelTypeMosaic = 2,
    EGatherHouseTelTypeImage = 3
};

@interface EBGatherHouse : EBBaseModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *community;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger create_time;
@property (nonatomic, copy) NSString *owner_name;
@property (nonatomic, copy) NSString *owner_tel_img;//?
@property (nonatomic, copy) NSString *decoration;//?
@property (nonatomic, copy) NSString *total_price;
@property (nonatomic, copy) NSString *district1;
@property (nonatomic, copy) NSString *district2;
@property (nonatomic, copy) NSString *total_floor;
@property (nonatomic, assign) NSInteger crawl_time;
@property (nonatomic, assign) NSInteger washroom;
@property (nonatomic, copy) NSString *port_id;
@property (nonatomic, copy) NSString *port_name;
@property (nonatomic, assign) BOOL remark;
@property (nonatomic, copy) NSString *floor;
@property (nonatomic, copy) NSString *crawl_id;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *towards;
@property (nonatomic, assign) EGatherHouseRentalType type;
@property (nonatomic, copy) NSString *owner_tel;
@property (nonatomic, copy) NSString *unit_price;
@property (nonatomic, assign) NSInteger report_count;
@property (nonatomic, copy) NSString *restriction;//?
@property (nonatomic, copy) NSString *des;//?
@property (nonatomic, assign) NSInteger view_count;
@property (nonatomic, assign) NSInteger viewed;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, assign) NSInteger hall;
@property (nonatomic, assign) NSInteger room;
@property (nonatomic, assign) NSInteger balcony;
@property (nonatomic, assign) NSInteger bookmarked;
@property (nonatomic, assign) NSInteger reported;
@property (nonatomic, assign) NSInteger to_erp_count;
@property (nonatomic, assign) NSInteger input_erp;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *built_year;
@property (nonatomic, assign) NSInteger tel_type;
@property (nonatomic, copy) NSString *house_type;//?
@property (nonatomic, copy) NSString *due_date;//?
@property (nonatomic, assign) NSInteger update_time;
@property (nonatomic, assign) NSInteger kitchen;

@end
