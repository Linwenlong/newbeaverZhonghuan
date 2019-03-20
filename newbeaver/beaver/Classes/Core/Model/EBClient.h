//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//



#import "EBBaseModel.h"
#import "EBContact.h"

typedef NS_ENUM(NSInteger , EClientRequireType)
{
    EClientRequireTypeRent = 1,
    EClientRequireTypeBuy = 2,
    EClientRequireTypeBoth = 3
};

typedef NS_ENUM(NSInteger , EClientAccessType)
{
    EClientAccessTypePrivate = 1,
    EClientAccessTypePublic = 2
};

typedef NS_ENUM(NSInteger , EClientPurposeType)
{
    EClientPurposeTypeOther = 0,
    EClientPurposeTypeVilla = 1,
    EClientPurposeTypeWorkshop = 2,
    EClientPurposeTypeCarport = 3,
    EClientPurposeTypeApartment = 4,
    EClientPurposeTypeShop = 5,
    EClientPurposeTypeCommercial = 6,
    EClientPurposeTypeLand = 7,
    EClientPurposeTypeOfficeBuilding = 8,
    EClientPurposeTypeResidence = 9
};

@interface EBClient : EBBaseModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *inputDate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *contractCode;
@property (nonatomic, strong) NSArray *areaRange;
@property (nonatomic, strong) NSArray *priceRange;
@property (nonatomic, strong) NSArray *roomRange;
@property (nonatomic, strong) NSArray *floorRange;
@property (nonatomic, strong) NSArray *ageRange;
@property (nonatomic, strong) NSArray *districts;
@property (nonatomic, assign) EClientAccessType access;
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, strong) NSArray *towards;
@property (nonatomic, assign) BOOL urgent;
@property (nonatomic, assign) BOOL fullPaid;
@property (nonatomic, assign) BOOL collected;
@property (nonatomic, assign) NSInteger timesRemain;
@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, assign) EClientRequireType rentalState;
@property (nonatomic, assign) BOOL marked;
@property (nonatomic, assign) BOOL recommended;
@property (nonatomic, assign) BOOL inputbyme;
@property (nonatomic, assign) BOOL ownbyme;
@property (nonatomic, assign) BOOL enableanonymouscall;
@property (nonatomic, assign) BOOL companyhasbalance;
@property (nonatomic, assign) BOOL follow;
@property (nonatomic, strong) NSArray *recommendTags;
@property (nonatomic, strong) NSDictionary *clientPri;
@property (nonatomic, strong) NSArray *extraArray;
@property (nonatomic, strong) NSArray *factoryExtra;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSString *coreMemo;
@property (nonatomic, copy) NSString *changeStatus;
@property (nonatomic, copy) NSString *decoration;
@property (nonatomic, copy) NSString *fitment;
@property (nonatomic, copy) NSString *direction;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, assign) EClientPurposeType purpose;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) EBContact *inputAgent;
@property (nonatomic, strong) EBContact *closeAgent;
@property (nonatomic, strong) EBContact *delegationAgent;
@property (nonatomic, copy) NSString *doorWidth;


@end