//
// Created by 何 义 on 14-3-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBCache.h"
#import "TMCache.h"
#import "EBHttpClient.h"
#import "EBPreferences.h"
#import "EBContactManager.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBFilter.h"
#import "EBBusinessConfig.h"
#import "EBCompanyInfo.h"
#import "EBController.h"
#import "CommuityModel.h"
#import "BMChineseSort.h"

#define EB_CACHE_LOCAL_URL @"http://local.beaver.me/"

@implementation EBCache

+ (EBCache *)sharedInstance
{
    static dispatch_once_t pred;
    static EBCache *_sharedInstance = nil;

    dispatch_once(&pred, ^{
        _sharedInstance = [[EBCache alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {

    }

    return self;
}

- (NSString *)companyCacheKey:(NSString *)key
{
    return [NSString stringWithFormat:@"c_%@_%@", self.companyCode, key];
}

- (id)objectForKey:(NSString *)key
{
    return [[TMCache sharedCache] objectForKey:[self companyCacheKey:key]];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [[TMCache sharedCache] setObject:object forKey:[self companyCacheKey:key]];
}

- (void)removeObjectForKey:(NSString *)key
{
    [[TMCache sharedCache] removeObjectForKey:[self companyCacheKey:key]];
}

- (id)privateObjectForKey:(NSString *)key
{
    return [[TMCache sharedCache] objectForKey:[self privateKey:key]];
}

- (void)removePrivateObjectForKey:(NSString *)key
{
   [[TMCache sharedCache] removeObjectForKey:[self privateKey:key]];
}

- (void)setPrivateObject:(id)object forKey:(NSString *)key
{
    [[TMCache sharedCache] setObject:object forKey:[self privateKey:key]];
}

- (void)setCompanyCode:(NSString *)companyCode
{
    [[TMCache sharedCache] setObject:companyCode forKey:EB_CACHE_KEY_COMPANY_CODE];
}

- (NSDictionary *)emojiMap
{
   NSDictionary *map = [self objectForKey:EB_CACHE_KEY_EMOJI];
   if (!map)
   {
       map = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emotion.bundle/emotion_map" ofType:@"plist"]];
       [self setObject:map forKey:EB_CACHE_KEY_EMOJI];
   }

   return map;
}

- (BOOL)systemMessageSent
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *key = [NSString stringWithFormat:@"system_sent_%@", pref.userId];
    NSString *sent = [self objectForKey:key];
    return sent != nil;
}

- (void)setSystemMessageSent
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *key = [NSString stringWithFormat:@"system_sent_%@", pref.userId];
    [self setObject:@"1" forKey:key];
}

- (BOOL)systemNewHouseMessageSent
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *key = [NSString stringWithFormat:@"system_new_house_sent_%@", pref.userId];
    NSString *sent = [self objectForKey:key];
    return sent != nil;
}

- (void)setSystemNewHouseMessageSent
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSString *key = [NSString stringWithFormat:@"system_new_house_sent_%@", pref.userId];
    [self setObject:@"1" forKey:key];
}

- (NSDictionary *)emojiValueMap
{
   NSDictionary *emojiValueMap = [self objectForKey:EB_CACHE_KEY_EMOJI_VALUE];
   if (!emojiValueMap)
   {
       NSDictionary *emojiMap = [self emojiMap];
       emojiValueMap = [[NSMutableDictionary alloc] initWithObjects:[emojiMap allKeys] forKeys:[emojiMap allValues]];
       [self setObject:emojiValueMap forKey:EB_CACHE_KEY_EMOJI_VALUE];
   }

   return emojiValueMap;
}

- (NSString *)getCompanyCode
{
    return [[TMCache sharedCache] objectForKey:EB_CACHE_KEY_COMPANY_CODE];
}

- (void)filterDataChanged
{
    [[EBHttpClient sharedInstance] dataRequest:nil filter:^(BOOL success, id result)
    {
        if (success)
        {
             [self updateFilterData:result[@"filter"]];
        }
    }];
}

// 缓存职务
- (void)updatePosition:(NSArray *)position{
     NSMutableArray *allPosition = [NSMutableArray array];
    for (NSDictionary *dic in position) {
        [allPosition addObject:dic[@"name"]];
    }
      [[EBCache sharedInstance]setObject:allPosition forKey:EB_CACHE_KEY_POSITION_ALL];//设置索引
}

//LWL 缓存小区数据
- (void)updateCommunityDate:(NSDictionary *)community{
    //保存通讯录信息
//    NSArray *commuity = [[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_COMMUITYS];
//    NSLog(@"commuity=%@",community);
    //变成model
    NSMutableArray *allCommuityModel = [NSMutableArray array];
    NSDictionary *tmpDic = community[@"community"];
    for (NSDictionary *dic in tmpDic) {
        CommuityModel *model = [[CommuityModel alloc]initWithDict:dic];
        [allCommuityModel addObject:model];
    }
    
   NSArray * indexArray = [BMChineseSort IndexWithArray:allCommuityModel Key:@"spell"];
   NSArray  *tmpArray = [BMChineseSort sortObjectArray:allCommuityModel Key:@"spell"];
    
    [[EBCache sharedInstance]setObject:allCommuityModel forKey:EB_CACHE_KEY_COMMUITYS_ALL];  //所有小区
    [[EBCache sharedInstance]setObject:indexArray forKey:EB_CACHE_KEY_COMMUITYS_INDEX];//设置索引
     [[EBCache sharedInstance]setObject:tmpArray forKey:EB_CACHE_KEY_COMMUITYS];//设置小区
  
   
}
//缓存部门数据    NSArray *daquDeptArray  = data[@"daqu"];
//NSArray *dept = data[@"dept"];//小区跟门店
- (void)updateDaquDeptData:(NSArray *)daquDeptArray deptData:(NSArray *)dept{
    //部门
    NSMutableArray *  _DeptAarray = [NSMutableArray array];
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < daquDeptArray.count; i++) {
        NSDictionary *dic = daquDeptArray[i];
        
        [tmpDic addEntriesFromDictionary:dic];//将字典加入
        
        for (int j = 0; j < dept.count; j++) {
            NSMutableDictionary *nextDic = dept[j];
            if ([dic[@"id"] integerValue] == [nextDic[@"pid"]integerValue]) {
                [tmpArray addObject:nextDic];
            }
        }
        if (tmpArray.count>0) {
            [tmpDic setObject:[tmpArray mutableCopy] forKey:@"children"];
        }
        [_DeptAarray addObject:[tmpDic mutableCopy]];
        //清空
        [tmpArray removeAllObjects];
        [tmpDic removeAllObjects];
    }
    [[EBCache sharedInstance]setObject:_DeptAarray forKey:EB_CACHE_KEY_DEPT_ALL];  //所有小区
}

- (void)updateFilterData:(NSDictionary *)filter
{
    [self setObject:filter[@"rent_price"] forKey:EB_CACHE_KEY_RENT_PRICE_OPTIONS];
    [self setObject:filter[@"sale_price"] forKey:EB_CACHE_KEY_SALE_PRICE_OPTIONS];
    [self setObject:filter[@"district"] forKey:EB_CACHE_KEY_DISTRICTS];
    [self setObject:filter[@"area"] forKey:EB_CACHE_KEY_AREA_OPTIONS];
//    [self addCustomFilter];
}

- (void)updateConfigData:(NSDictionary *)config
{
    NSError *error = nil;
    EBBusinessConfig *businessConfig = [MTLJSONAdapter modelOfClass:[EBBusinessConfig class]
                          fromJSONDictionary:config error:&error];
    if (!error){
        [self setObject:businessConfig forKey:EB_CACHE_KEY_CONFIG];
        
        [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_BUSINESS_CONFIG object:nil]];
    }
}

- (EBBusinessConfig *)businessConfig
{
    return [self objectForKey:EB_CACHE_KEY_CONFIG];
}

- (void)updateCompanyInfo:(NSDictionary *)companyInfo
{
    NSError *error = nil;
    EBCompanyInfo *info = [MTLJSONAdapter modelOfClass:[EBCompanyInfo class]
                                                 fromJSONDictionary:companyInfo error:&error];
    if (!error)
    {
        [self setObject:info forKey:EB_CACHE_KEY_COMPANY_INFO];
    }
}

- (EBCompanyInfo *)companyInfo
{
    return [self objectForKey:EB_CACHE_KEY_COMPANY_INFO];
}
//
//- (void)addCustomFilter
//{
//    NSArray *choices = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_RENT_PRICE_OPTIONS];
//    NSMutableArray *newChoices = [[NSMutableArray alloc] initWithArray:choices];
//    NSString *title = [NSString stringWithFormat:@"%d-%d%@", 0, 0, NSLocalizedString(@"amount_rent_unit", @"rent")];
//    NSDictionary *newChoice = @{@"down":@(0), @"up":@(0), @"title":title};
//    [newChoices addObject:newChoice];
//    [[EBCache sharedInstance] setObject:newChoices forKey:EB_CACHE_KEY_RENT_PRICE_OPTIONS];
//    
//    choices = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_SALE_PRICE_OPTIONS];
//    
//    newChoices = [[NSMutableArray alloc] initWithArray:choices];
//    title = [NSString stringWithFormat:@"%d-%d%@", 0, 0, NSLocalizedString(@"amount_unit", @"sale")];
//    newChoice = @{@"down":@(0), @"up":@(0), @"title":title};
//    [newChoices addObject:newChoice];
//    [[EBCache sharedInstance] setObject:newChoices forKey:EB_CACHE_KEY_SALE_PRICE_OPTIONS];
//    
//    choices = [EBFilter rawAreaChoices];
//   
//    newChoices = [[NSMutableArray alloc] initWithArray:choices];
//    title = [NSString stringWithFormat:@"%d-%d%@", 0, 0, NSLocalizedString(@"area_unit", @"area")];
//    newChoice = @{@"down":@(0), @"up":@(0), @"title":title};
//    [newChoices addObject:newChoice];
//    [[EBCache sharedInstance] setObject:newChoices forKey:EB_CACHE_KEY_AREA_OPTIONS];
//}

#pragma mark -- 同步数据 （缓存）
- (void)synchronizeCompanyData:(void(^)(BOOL success))completion
{
    NSString *currentVersion = [[EBContactManager sharedInstance] contactsVersion]; //contact
    if (!currentVersion)
    {
        currentVersion = @"";
    }
    //数据请求
    [[EBHttpClient sharedInstance] dataRequest:@{@"cont_ver":currentVersion} prefetch:^(BOOL success, id result)
    {
        if (success)
        {
            EBPreferences *pref = [EBPreferences sharedInstance];
            self.companyCode = pref.companyCode;

            NSDictionary *data = (NSDictionary *)result;
            //所有联系人
            [[EBContactManager sharedInstance] cacheContacts:data[@"contacts"] version:data[@"contacts_version"]];
            
            //所有职务
            NSArray *position = data[@"position"];
            if (position) {
                [self updatePosition:position];
            }

            //所有小                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          区
            NSDictionary *community = data[@"community"];
            if (community) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSLog(@"curentThread = %@",[NSThread currentThread]);
                   [self updateCommunityDate:community];
                });
            }
            
            //部门
            NSArray *daquDeptArray  = data[@"daqu"];
            NSArray *dept = data[@"dept"];//小区跟门店
            
            if (daquDeptArray && dept) {
                [self updateDaquDeptData:daquDeptArray deptData:dept];
            }
          
            NSDictionary *filter = data[@"filter"];
            if (filter)
            {
                [self updateFilterData:filter];
            }

            NSDictionary *config = data[@"config"];
            if (config)
            {
                [self updateConfigData:data[@"config"]];
            }
            
            NSDictionary *companyInfo = data[@"company_info"];
            if (companyInfo)
            {
                [self updateCompanyInfo:data[@"company_info"]];
            }

            pref.enableExtensionNumber = [data[@"enable_extension_number"] boolValue];
            [pref writePreferences];

            completion(YES);
        }
        else
        {
            completion(NO);
        }
    }];
}

- (BOOL)imageManager:(SDWebImageManager *)imageManager shouldDownloadImageForURL:(NSURL *)imageURL
{
    NSRange strRange = [[imageURL absoluteString] rangeOfString:EB_CACHE_LOCAL_URL];
    if (strRange.length > 0)
    {
        return NO;
    }
    else
    {
       EBPreferences *pref = [EBPreferences sharedInstance];
       AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
       if (status == AFNetworkReachabilityStatusReachableViaWiFi)
       {
           return YES;
       }
       else if (status == AFNetworkReachabilityStatusReachableViaWWAN)
       {
           return pref.allowImageDownloadViaWan;
       }
       return YES;
    }
}

+ (NSString *)localUrlForCategory:(NSString *)category object:(NSObject *)object
{
    return [NSString stringWithFormat:@"%@%@/%ld", EB_CACHE_LOCAL_URL, category, object.hash];
}

#define EB_CACHE_KEY_PRIVATE_CATEGORIES @"h_categories"
#define EB_CACHE_KEY_PRIVATE_RECENT_HOUSES @"h_recent"
#define EB_CACHE_KEY_PRIVATE_HOUSE_DETAIL @"h_detail"
#define EB_CACHE_KEY_PRIVATE_RECENT_CLIENTS @"c_recent"
#define EB_CACHE_KEY_PRIVATE_CLIENT_DETAIL @"c_detail"
#define EB_CACHE_KEY_PRIVATE_PUBLISH_PORTS @"c_ports"

- (NSString *)privateOneDayKey:(NSString *)key
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
            components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"p_%ld%ld%ld_%@_%@",
                    components.year,
                    components.month,
                    components.day,[EBPreferences sharedInstance].userId, key];
}

- (NSString *)privateKey:(NSString *)key
{
    return [NSString stringWithFormat:@"p_%@_%@", [EBPreferences sharedInstance].userId, key];
}

- (void)clearExpiredCache
{
   // image
   NSInteger cacheAge = 60 * 60 * 24 * 4;
   [SDImageCache sharedImageCache].maxCacheAge = cacheAge;
   [[SDImageCache sharedImageCache] cleanDisk];
    
    //4天之后的数据清楚 lwl
//   [[TMCache sharedCache] trimToDate:[NSDate dateWithTimeIntervalSinceNow:-cacheAge]];
}

- (void)clearDataWhenLogOut
{
    [[TMCache sharedCache] removeAllObjects];
}

- (void)updateCacheByViewClientDetail:(EBClient *)client
{
    // recent
    NSMutableArray *updatedResult;
    NSArray *result = [self recentViewedClients:1 pageSize:30];
    if (result.count == 0)
    {
        updatedResult = [[NSMutableArray alloc] initWithObjects:client, nil];
    }
    else
    {
        updatedResult = [[NSMutableArray alloc] initWithArray:result];
        [updatedResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            EBClient *item = (EBClient *)obj;
            if (item.rentalState == client.rentalState && [item.id isEqualToString:client.id])
            {
                [updatedResult removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
        [updatedResult insertObject:client atIndex:0];
    }

    [self cacheRecentViewedClients:updatedResult];
}

- (void)updateCacheByViewHouseDetail:(EBHouse *)house
{
    NSMutableArray *updatedResult;
    NSArray *result = [self recentViewedHouses:1 pageSize:30];
    if (result.count == 0)
    {
        updatedResult = [[NSMutableArray alloc] initWithObjects:house, nil];
    }
    else
    {
        updatedResult = [[NSMutableArray alloc] initWithArray:result];
        [updatedResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            EBHouse *item = (EBHouse *)obj;
            if (item.rentalState == house.rentalState && [item.id isEqualToString:house.id])
            {
                [updatedResult removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
        [updatedResult insertObject:house atIndex:0];
    }

    [self cacheRecentViewedHouses:updatedResult];
}

- (void)cacheRecentViewedHouses:(NSArray *)houses
{
    NSString *key = [self privateOneDayKey:EB_CACHE_KEY_PRIVATE_RECENT_HOUSES];
    [[TMCache sharedCache] setObject:houses forKey:key];
}

- (void)cacheSpecialCategory:(NSArray *)categories
{
    NSString *key = [self privateOneDayKey:EB_CACHE_KEY_PRIVATE_CATEGORIES];
    [[TMCache sharedCache] setObject:categories forKey:key];
}

- (void)cacheHouseDetail:(EBHouse *)house
{
    NSString *key = [self privateOneDayKey:[NSString stringWithFormat:@"%@_%@_%@",
                                                                      EB_CACHE_KEY_PRIVATE_HOUSE_DETAIL, [EBFilter typeString:house.rentalState], house.id]];
    [[TMCache sharedCache] setObject:house forKey:key];
}

- (NSArray *)specialCategories
{
    NSString *key = [self privateOneDayKey:EB_CACHE_KEY_PRIVATE_CATEGORIES];
    return [[TMCache sharedCache] objectForKey:key];
}

- (NSArray *)recentViewedHouses:(NSInteger)page pageSize:(NSInteger)pageSize
{
    NSString *key = [self privateOneDayKey:EB_CACHE_KEY_PRIVATE_RECENT_HOUSES];
    id result = [[TMCache sharedCache] objectForKey:key];
    if ([result isKindOfClass:[NSArray class]])
    {
        return result;
    }
    else
    {
        [[TMCache sharedCache] removeObjectForKey:key];
        return nil;
    }
}

- (EBHouse *)houseDetail:(NSString *)id type:(NSString *)type
{
    NSString *key = [self privateOneDayKey:[NSString stringWithFormat:@"%@_%@_%@",
                                                                      EB_CACHE_KEY_PRIVATE_HOUSE_DETAIL, type, id]];
    return [[TMCache sharedCache] objectForKey:key];
}

- (void)cacheRecentViewedClients:(NSArray *)clients
{
    NSString *key = [self privateOneDayKey:EB_CACHE_KEY_PRIVATE_RECENT_CLIENTS];
    [[TMCache sharedCache] setObject:clients forKey:key];

//    [[TMCache sharedCache] r]
}

- (void)cacheClientDetail:(EBClient *)client
{
    NSString *key = [self privateOneDayKey:[NSString stringWithFormat:@"%@_%@_%@",
                                                                      EB_CACHE_KEY_PRIVATE_CLIENT_DETAIL, [EBFilter typeString:client.rentalState], client.id]];
    [[TMCache sharedCache] setObject:client forKey:key];
}

- (NSArray *)recentViewedClients:(NSInteger)page pageSize:(NSInteger)pageSize
{
    NSString *key = [self privateOneDayKey:EB_CACHE_KEY_PRIVATE_RECENT_CLIENTS];
    NSArray *result = [[TMCache sharedCache] objectForKey:key];
    return result;
}

- (EBClient *)clientDetail:(NSString *)id type:(NSString *)type
{
    NSString *key = [self privateOneDayKey:[NSString stringWithFormat:@"%@_%@_%@",
                                                                      EB_CACHE_KEY_PRIVATE_CLIENT_DETAIL, type, id]];
    return [[TMCache sharedCache] objectForKey:key];
}

@end
