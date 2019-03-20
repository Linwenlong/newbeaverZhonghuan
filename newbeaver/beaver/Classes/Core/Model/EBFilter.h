//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//

@class EBHouse;
@class EBClient;

@interface EBFilter : NSObject<NSCopying>

@property (nonatomic, assign) NSInteger requireOrRentalType;
@property (nonatomic, assign) NSInteger district1;
@property (nonatomic, assign) NSInteger district2;
@property (nonatomic, assign) NSInteger priceIndex;
@property (nonatomic, assign) NSInteger roomIndex;
@property (nonatomic, assign) NSInteger areaIndex;

@property (nonatomic, assign) NSInteger renovateIndex;//装修

@property (nonatomic, assign) NSInteger status;//状态

@property (nonatomic, assign) NSInteger sortIndex;
@property (nonatomic, assign) NSInteger belongIndex;
@property (nonatomic, assign) NSInteger purposeIndex;
@property (nonatomic, assign) BOOL hasPhoto;

@property (nonatomic,strong) NSDictionary *floorMinAndfloorMaxWithhouserType;

@property (nonatomic, retain) NSString *communitiesIds;//选择的小区
@property (nonatomic, retain) NSString *block;//座栋
@property (nonatomic, retain) NSString *unit_name;//单元
@property (nonatomic, retain) NSString *room_code;//房号



@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *keywordType;

@property (nonatomic, strong) NSDictionary *reservedCondition;

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *subscriptionId;
@property (nonatomic, copy) NSString *houseType;
@property (nonatomic, copy) NSString *clientType;

- (void)parseFromDictionary:(NSDictionary *)dictionary;
- (void)parseFromHouse:(EBHouse *)house withDetail:(BOOL)detail;
- (void)parseFromClient:(EBClient *)client withDetail:(BOOL)detail;
- (NSArray *)priceChoices;
- (NSArray *)choicesByIndex:(NSInteger)index;
- (NSString *)titleByIndex:(NSInteger)index;
- (NSInteger)choiceByIndex:(NSInteger)index;
- (void)setChoice:(NSInteger)choice byIndex:(NSInteger)index;
- (NSMutableDictionary *)currentArgs;

+(NSArray *)rawSortOrders;
+(NSArray *)rawDistrictChoices;
+(NSArray *)rawRoomChoices;
+(NSArray *)rawAreaChoices;
+(NSArray *)rawHouseKeywordTypeChoices;
+(NSArray *)rawClientKeywordTypeChoices;
+(NSArray *)rawHouseRentalTypeChoices;
+(NSArray *)rawClientRequireTypeChoices;
+(NSArray *)rawBelongChoices;
+(NSArray *)rawPurposeChoices;
+(NSString *)typeString:(NSInteger)type;

+(NSInteger)ensureSalePriceExist:(NSInteger)down up:(NSInteger)up;
+(NSInteger)ensureRentPriceExist:(NSInteger)down up:(NSInteger)up;
+(NSInteger)ensureAreaExist:(NSInteger)down up:(NSInteger)up;

@end
