//
// Created by 何 义 on 14-3-24.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "SDWebImageManager.h"

@class EBHouse;
@class EBClient;
@class EBBusinessConfig;
@class EBCompanyInfo;

//lwl
#define EB_CACHE_KEY_DEPARMENTS @"deparments"


#define EB_CACHE_KEY_POSITION_ALL @"position"

#define EB_CACHE_KEY_DEPT_ALL @"dept_all"

#define EB_CACHE_KEY_COMMUITYS @"community"
#define EB_CACHE_KEY_COMMUITYS_INDEX @"community_index"
#define EB_CACHE_KEY_COMMUITYS_ALL @"community_all"

#define EB_CACHE_KEY_DISTRICTS @"districts"
#define EB_CACHE_KEY_COMPANY_CODE @"company_code"
#define EB_CACHE_KEY_EMOJI @"emoji_map_0"
#define EB_CACHE_KEY_EMOJI_VALUE @"emoji_map_0_value"
#define EB_CACHE_KEY_RENT_PRICE_OPTIONS @"rent_prices"
#define EB_CACHE_KEY_SALE_PRICE_OPTIONS @"sale_prices"
#define EB_CACHE_KEY_AREA_OPTIONS @"area"
#define EB_CACHE_KEY_CONTACT_VERSION @"contact_ver"
#define EB_CACHE_KEY_CONTACTS @"contacts"
#define EB_CACHE_KEY_NON_SPECIAL_CONTACTS @"non_special_contacts"
#define EB_CACHE_KEY_CONFIG @"beaver_business_config"
#define EB_CACHE_KEY_COMPANY_INFO @"beaver_company_info"

@interface EBCache : NSObject<SDWebImageManagerDelegate>

@property (nonatomic, getter=getCompanyCode, setter=setCompanyCode:) NSString *companyCode;

+ (EBCache *)sharedInstance;

- (id)objectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;

- (id)privateObjectForKey:(NSString *)key;
- (void)removePrivateObjectForKey:(NSString *)key;
- (void)setPrivateObject:(id)object forKey:(NSString *)key;

- (NSDictionary *)emojiMap;
- (NSDictionary *)emojiValueMap;

- (EBBusinessConfig *)businessConfig;

- (EBCompanyInfo *)companyInfo;

- (BOOL)systemMessageSent;
- (void)setSystemMessageSent;

- (BOOL)systemNewHouseMessageSent;
- (void)setSystemNewHouseMessageSent;

- (void)filterDataChanged;

//同步数据
- (void)synchronizeCompanyData:(void(^)(BOOL success))completion;

+ (NSString *)localUrlForCategory:(NSString *)category object:(NSObject *)object;

//清楚图片
- (void)clearExpiredCache;
- (void)clearDataWhenLogOut;

- (void)updateCacheByViewClientDetail:(EBClient *)client;
- (void)updateCacheByViewHouseDetail:(EBHouse *)house;

- (void)cacheRecentViewedHouses:(NSArray *)houses;
- (void)cacheSpecialCategory:(NSArray *)categories;
- (void)cacheHouseDetail:(EBHouse *)house;

- (NSArray *)specialCategories;
- (NSArray *)recentViewedHouses:(NSInteger)page pageSize:(NSInteger)pageSize;
- (EBHouse *)houseDetail:(NSString *)id type:(NSString *)type;

- (void)cacheRecentViewedClients:(NSArray *)houses;
- (void)cacheClientDetail:(EBClient *)client;

- (NSArray *)recentViewedClients:(NSInteger)page pageSize:(NSInteger)pageSize;
- (EBClient *)clientDetail:(NSString *)id type:(NSString *)type;

@end
