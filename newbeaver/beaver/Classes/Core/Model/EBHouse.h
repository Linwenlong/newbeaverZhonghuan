//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//



#import "EBBaseModel.h"
#import "EBContact.h"

@class EBPrice;

typedef NS_ENUM(NSInteger , EHouseRentalType)
{
    EHouseRentalTypeRent = 1,
    EHouseRentalTypeSale = 2,
    EHouseRentalTypeBoth = 3
};

typedef NS_ENUM(NSInteger , EHouseAccessType)
{
    EHouseAccessTypePrivate = 1,
    EHouseAccessTypePublic = 2
};

typedef NS_ENUM(NSInteger , EHousePurposeType)
{
    EHousePurposeTypeOther = 0,
    EHousePurposeTypeVilla = 1,
    EHousePurposeTypeWorkshop = 2,//产房
    EHousePurposeTypeCarport = 3,
    EHousePurposeTypeApartment = 4,
    EHousePurposeTypeShop = 5,  //商铺
    EHousePurposeTypeCommercial = 6,
    EHousePurposeTypeLand = 7,
    EHousePurposeTypeOfficeBuilding = 8,//写字楼
    EHousePurposeTypeResidence = 9 //住宅
};

@interface EBHouse : EBBaseModel

//查看门牌号
@property (nonatomic, assign) BOOL view_room_pri;

//房源收藏
@property (nonatomic, strong) NSArray * group;//房源收藏

@property (nonatomic, strong) NSNumber * group_id;//房源id
@property (nonatomic, strong) NSString * favorite_group;//房源收藏
//隐号通话
@property (nonatomic, strong) NSArray * implicit_call;
@property (nonatomic, assign) BOOL implicit_call_pri;

@property (nonatomic, strong) NSDictionary * call_follow_info;   //补写跟进对应的房源信息
@property (nonatomic, assign) BOOL call_follow;             //是否需要需要补写隐号跟进

//@property (nonatomic, copy) NSString *purpose;//用途

@property (nonatomic, assign) NSInteger image_num;//当前房源图片

@property (nonatomic, copy) NSDictionary *force_follow;//强制写跟进

@property (nonatomic, copy) NSString *if_dhgj;//是否开启强制写跟进

@property (nonatomic, copy) NSString *community_id;
@property (nonatomic, copy) NSString *region_id;
@property (nonatomic, copy) NSString *district_id;

@property (nonatomic, assign) BOOL if_start;

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *contractCode;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *pictures;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat area;
@property (nonatomic, assign) NSInteger room;
@property (nonatomic, assign) NSInteger hall;
@property (nonatomic, assign) NSInteger floor;
@property (nonatomic, assign) NSInteger floorNumber;
@property (nonatomic, assign) NSInteger elevatorNumber;
@property (nonatomic, assign) NSInteger householdNumber;
@property (nonatomic, assign) NSInteger builtYear;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *keysLocation;
@property (nonatomic, copy) NSString *community;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *road;
@property (nonatomic, copy) NSString *facility;
@property (nonatomic, copy) NSString *inputDate;
@property (nonatomic, copy) NSString *curInfo;
@property (nonatomic, copy) NSString *decoration;
@property (nonatomic, assign) EHouseAccessType access;
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, copy) NSString *towards;
@property (nonatomic, assign) BOOL urgent;
@property (nonatomic, assign) BOOL collected;
@property (nonatomic, assign) BOOL new;
@property (nonatomic, assign) BOOL marked;
@property (nonatomic, assign) BOOL recommended;

//推荐
@property (nonatomic, assign) BOOL is_recommend;

@property (nonatomic, assign) BOOL follow;
//@property (nonatomic, copy) NSString *description;
@property (nonatomic, assign) NSInteger timesRemain;
@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, copy) NSString *delegationType;
@property (nonatomic, assign) EHouseRentalType rentalState;
@property (nonatomic, strong) EBPrice *rentPrice;
@property (nonatomic, strong) EBPrice *sellPrice;
@property (nonatomic, assign) BOOL inputbyme;
@property (nonatomic, assign) BOOL ownbyme;
@property (nonatomic, assign) BOOL enableanonymouscall;
@property (nonatomic, assign) BOOL companyhasbalance;
@property (nonatomic, assign) EHousePurposeType purpose;
@property (nonatomic, strong) NSArray *recommendTags;
@property (nonatomic, strong) NSArray *extraArray;
@property (nonatomic, strong) NSArray *factoryExtra;
@property (nonatomic, copy) NSString *visitCat;
@property (nonatomic, copy) NSString *entrustProp;
@property (nonatomic, copy) NSString *entrustNum;
@property (nonatomic, copy) NSString *submitDate;
@property (nonatomic, copy) NSString *keyStore;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *doorWidth;
@property (nonatomic, copy) NSString *depth;
@property (nonatomic, copy) NSString *length;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *usableArea;
@property (nonatomic, assign) CGFloat variablePower;
@property (nonatomic, assign) CGFloat dormArea;
@property (nonatomic, assign) CGFloat officeArea;
@property (nonatomic, assign) CGFloat spaceArea;
@property (nonatomic, assign) CGFloat loadBearing;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSString *coreMemo;
@property (nonatomic, copy) NSString *building;
@property (nonatomic, copy) NSString *media;
@property (nonatomic, strong) NSDictionary *housePri;
@property (nonatomic, strong) EBContact *inputAgent;
@property (nonatomic, strong) EBContact *closeAgent;
@property (nonatomic, strong) EBContact *keyAgent;
@property (nonatomic, strong) EBContact *delegationAgent;

@property (nonatomic, assign) BOOL priUploadVideo;

@end
