//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBFilter.h"
#import "EBCache.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBPrice.h"

@implementation EBFilter

- (id)init
{
   self = [super init];
   if (self)
   {
       _requireOrRentalType = 2;
       _belongIndex = 3;
       _purposeIndex = 5;
   }
   return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    EBFilter *filter = [[[self class] allocWithZone:zone] init];
    filter.requireOrRentalType = self.requireOrRentalType;
    filter.houseId = self.houseId;
    filter.areaIndex = self.areaIndex;
    filter.belongIndex = self.belongIndex;
    filter.clientId = self.clientId;
    filter.district1 = self.district1;
    filter.district2 = self.district2;
    filter.keyword = self.keyword;
    filter.houseType = self.houseType;
    filter.keywordType = self.keywordType;
    filter.priceIndex = self.priceIndex;
    filter.roomIndex = self.roomIndex;
    //!wyl
    filter.areaIndex = self.areaIndex;
    filter.sortIndex = self.sortIndex;
    filter.purposeIndex = self.purposeIndex;
    
    filter.reservedCondition = [self.reservedCondition copy];
    filter.hasPhoto = self.hasPhoto;
    return filter;
}

- (NSMutableDictionary *)currentArgs
{
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    args[@"type"] = [EBFilter typeString:_requireOrRentalType];

    if (_belongIndex > 0 && _belongIndex < 3)
    {
        NSArray *belongs = [EBFilter rawBelongChoices];
        args[@"belong"] = belongs[_belongIndex - 1][@"title"];
    }

    if (_purposeIndex > 0 && _purposeIndex < 5)
    {
        NSArray *purposes = [EBFilter rawPurposeChoices];
        args[@"purpose"] = purposes[_purposeIndex - 1][@"title"];
    }

    if (_district1 > 0)
    {
       NSArray *districts = [EBFilter rawDistrictChoices];
       args[@"district1"] = districts[_district1][@"title"];
       if (_district2 > 0)
       {
           NSArray *children = districts[_district1][@"children"];
           args[@"district2"] = children[_district2];
       }
    }

    if (_sortIndex > 0)
    {
        NSArray *orders = [EBFilter rawSortOrders];
        args[@"page_sort"] = orders[(_sortIndex - 1) / 2][@"value"];
        args[@"page_dir"] = _sortIndex % 2 ? @"asc" : @"desc";
    }

    if (_priceIndex > 0)
    {
        NSArray *prices = [self priceChoices];
        NSDictionary *price = prices[_priceIndex];
        args[@"price"] = [NSString stringWithFormat:@"%ld-%ld", [price[@"down"] integerValue], [price[@"up"] integerValue]];
    }

    if (_roomIndex > 0)
    {
        NSArray *rooms = [EBFilter rawRoomChoices];
        NSInteger roomDown = _roomIndex, roomUp = _roomIndex;
        if (_roomIndex == rooms.count - 1)
        {
            roomUp = 99;
        }
        args[@"room"] = [NSString stringWithFormat:@"%ld-%ld", roomDown, roomUp];
    }

    if (_areaIndex > 0)
    {
        NSArray *areas = [EBFilter rawAreaChoices];
        NSDictionary *area = areas[_areaIndex];
        args[@"area"] = [NSString stringWithFormat:@"%ld-%ld", [area[@"down"] integerValue], [area[@"up"] integerValue]];
    }
    //lwl 装修
    if (_renovateIndex > 0 ) {
        NSArray *renovates = [EBFilter rawRenovateChoices];
        NSDictionary *renovate = renovates[_renovateIndex];
        args[@"renovate"] = renovate[@"title"];
    }
    
    //lwl 状态
    if (_status > 0 ) {
        NSArray *status = [EBFilter rawHouseStatus];
        NSDictionary *status1 = status[_status];
        args[@"house_status"] = status1[@"title"];
    }

    if (_houseId)
    {
        args[@"house_id"] = _houseId;
        args[@"type"] = _houseType;
    }

    if (_clientId)
    {
        args[@"client_id"] = _clientId;
        args[@"type"] = _clientType;
    }
    
    if (_subscriptionId)
    {
        args[@"sid"] = _subscriptionId;
    }

    // search
    if (_keyword)
    {
        args[@"keyword"] = _keyword;
        args[@"keyword_type"] = _keywordType;
    }

    if (_reservedCondition)
    {
        [args addEntriesFromDictionary:_reservedCondition];
    }
    
    if (_hasPhoto)
    {
       args[@"image"] = @1;
    }
    
    

    return args;
}

- (NSArray *)priceChoices
{
    if (_requireOrRentalType == 1)
    {
       return [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_RENT_PRICE_OPTIONS];
    }
    else
    {
        return [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_SALE_PRICE_OPTIONS];
    }
}

- (void)setRequireOrRentalType:(NSInteger)requireOrRentalType
{
    _requireOrRentalType = requireOrRentalType;
    [self safePriceIndex];
}

- (void)safePriceIndex
{
    NSArray *priceChoices = [self priceChoices];
    if (_priceIndex > priceChoices.count)
    {
        _priceIndex = priceChoices.count - 1;
    }
}

- (void)safeRoomIndex
{
    if (_roomIndex < 0)
    {
        _roomIndex = 0;
    }
    else
    {
        NSArray *roomChoices = [EBFilter rawRoomChoices];
        if (roomChoices && roomChoices.count > 0)
        {
            NSInteger maxRoom = [roomChoices[roomChoices.count - 1][@"value"] integerValue];
            if (_roomIndex > maxRoom)
            {
                _roomIndex = maxRoom;
            }
        }
    }
}

- (NSArray *)choicesByIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
            return [EBFilter rawDistrictChoices];
        case 1:
            return [self priceChoices];
        case 2:
            return [EBFilter rawRoomChoices];
        case 3:
            return [EBFilter rawAreaChoices];
        case 4:
            return [EBFilter rawRenovateChoices];
        case 6:
            return [EBFilter rawHouseStatus];
        default:
            return nil;
    }
}

- (NSString *)titleByIndex:(NSInteger)index
{
    NSInteger choice = [self choiceByIndex:index];
    if (choice == 0)
    {
        return nil;
    }

    NSString *result = nil;
    NSArray *choices = [self choicesByIndex:index];
    
    if (index > 0 || _district2 == 0)
    {
        result = choices[choice][@"title"];
    }
    else
    {
        NSArray *subChoices = choices[_district1][@"children"];
        result = [NSString stringWithFormat:@"%@ %@", choices[_district1][@"title"], subChoices[_district2]];
    }
    return result;
}

- (NSInteger)choiceByIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
            return _district1;
        case 1:
            return _priceIndex;
        case 2:
            return _roomIndex;
        case 3:
            return _areaIndex;
        case 4:
            return _renovateIndex;
            break;
        case 6:
            return _status;
            break;
        default:
            return 0;
    }
}

- (void)setChoice:(NSInteger)choice byIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
            break;
        case 1:
            _priceIndex = choice;
            break;
        case 2:
            _roomIndex = choice;
            break;
        case 3:
            _areaIndex = choice;
            break;
        case 4:
            _renovateIndex = choice;
            break;
        case 6:
            _status = choice;
            break;
        default:
            break;
    }
}

+(NSArray *)rawSortOrders
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [self arrayByKey:@"sort_house_order" values:@[@"time", @"price", @"area"]];
    }
    return choices;
}

+(NSArray *)rawDistrictChoices
{
    return [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_DISTRICTS];
}

+(NSArray *)rawRoomChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"room" values:@[@0, @1, @2, @3, @4, @5, @6]];
    }
    return choices;
}

//lwl状态
+(NSArray *)rawHouseStatus
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = @[
                    @{@"title":@"有效",
                      @"value":@0},
                    @{@"title":@"不限",
                      @"value":@1},
                    @{@"title":@"暂缓",
                      @"value":@2},
                    @{@"title":@"我租",
                      @"value":@3},
                    @{@"title":@"他租",
                      @"value":@4},
                    @{@"title":@"我售",
                      @"value":@5},
                    @{@"title":@"他售",
                      @"value":@6},
                    @{@"title":@"无效",
                      @"value":@7},
                    ];
    }
    return choices;
}

//lwl 装修
+(NSArray *)rawRenovateChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = @[
                    @{@"title":@"不限",
                      @"value":@0},
                    @{@"title":@"毛坯",
                      @"value":@1},
                    @{@"title":@"简装",
                      @"value":@2},
                    @{@"title":@"清水",
                      @"value":@3},
                    @{@"title":@"普通装",
                      @"value":@4},
                    @{@"title":@"精装",
                      @"value":@5},
                    @{@"title":@"豪装",
                      @"value":@6},
                    @{@"title":@"高装",
                      @"value":@7},
                    @{@"title":@"新装修",
                      @"value":@8},
                    @{@"title":@"中装",
                      @"value":@9},
                    ];
    }
    return choices;
}

+(NSArray *)rawAreaChoices
{
    return [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_AREA_OPTIONS];
}

+(NSArray *)rawHouseKeywordTypeChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"search_house" values:@[@"tel", @"code",
                @"community", @"housenumber", @"building", @"name", @"delegatecode"]];
    }
    return choices;
}

+(NSArray *)rawClientKeywordTypeChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"search_client" values:@[@"tel", @"code",
                 @"name"]];
    }
    return choices;
}

+(NSArray *)rawHouseRentalTypeChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"rental_house" values:@[@1, @2]];
    }
    return choices;
}

+(NSArray *)rawBelongChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"own_house" values:@[@1, @2, @3]];
    }
    return choices;
}

+(NSArray *)rawPurposeChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"type_house" values:@[@0, @1, @2, @3, @4]];
    }
    return choices;
}

+(NSString *)typeString:(NSInteger)type
{
    return type == 1 ? @"rent" : @"sale";
}

+(NSArray *)rawClientRequireTypeChoices
{
    static NSArray *choices = nil;
    if (choices == nil)
    {
        choices = [EBFilter arrayByKey:@"rental_client" values:@[@1, @2]];
    }
    return choices;
}

+ (NSArray *)arrayByKey:(NSString *)key values:(NSArray *)values
{
    static NSMutableDictionary *arrayMap = nil;

    if (arrayMap == nil)
    {
        arrayMap = [[NSMutableDictionary alloc] init];
    }

    if (arrayMap[key] == nil)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:values.count];
        for (NSInteger i = 0; i < values.count; i++)
        {
            NSString *stringKey = [NSString stringWithFormat:@"%@_%ld", key, i];
            [array addObject:@{@"title": NSLocalizedString(stringKey, nil), @"value":values[i]}];
        }

        arrayMap[key] = array;
    }

    return arrayMap[key];
}

+ (NSInteger)findTitle:(NSString *)title inDictionaryArray:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        NSDictionary *item = array[i];
        if ([item[@"title"] isEqualToString:title])
        {
            return i;
        }
    }

    return 0;
}

+ (NSInteger)findTitle:(NSString *)title inTextArray:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        if ([array[i] isEqualToString:title])
        {
            return i;
        }
    }

    return 0;
}

+ (NSInteger)findByDown:(NSInteger)down up:(NSInteger)up inArray:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        NSDictionary *item = array[i];
        if ([item[@"down"] integerValue] == down && [item[@"up"] integerValue] == up)
        {
            return i;
        }
    }

    return 0;
}

+ (NSInteger)findByValue:(NSInteger)value inArray:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        NSDictionary *item = array[i];
        if ([item[@"down"] integerValue] <= value && [item[@"up"] integerValue] >= value)
        {
            return i;
        }
    }

    return 0;
}

- (void)parseFromDictionary:(NSDictionary *)dictionary
{
    NSString *district1 = dictionary[@"district1"];

    if (district1.length > 0)
    {
        NSArray *array1 = [EBFilter rawDistrictChoices];
        _district1 = [EBFilter findTitle:district1 inDictionaryArray:array1];
        NSString *district2 = dictionary[@"district2"];
        if (district2.length > 0 )
        {
            _district2 = [EBFilter findTitle:district2 inTextArray:array1[_district1][@"children"]];
        }
    }

    if ([dictionary[@"type"] isEqualToString: @"sale"])
    {
       _requireOrRentalType = 2;
    }
    else
    {
        _requireOrRentalType = 1;
    }

    NSString *price = dictionary[@"price"];
    if (price.length > 0)
    {
        NSArray *range = [price componentsSeparatedByString:@"-"];
        if (range.count == 2)
        {
            if (_requireOrRentalType == 1)
            {
                _priceIndex = [EBFilter ensureRentPriceExist:[range[0] integerValue] up:[range[1] integerValue]];
            }
            else
            {
                _priceIndex = [EBFilter ensureSalePriceExist:[range[0] integerValue] up:[range[1] integerValue]];
            }
        }
    }

    NSString *purpose = dictionary[@"purpose"];
    if (purpose.length > 0)
    {
        _purposeIndex = [EBFilter findTitle:purpose inDictionaryArray:[EBFilter rawPurposeChoices]] + 1;
    }

    NSString *belong = dictionary[@"belong"];
    if (belong.length > 0)
    {
        _belongIndex = [EBFilter findTitle:purpose inDictionaryArray:[EBFilter rawBelongChoices]] + 1;
    }

    NSString *area = dictionary[@"area"];
    if (area.length > 0)
    {
        NSArray *range = [area componentsSeparatedByString:@"-"];
        if (range.count == 2)
        {
            _areaIndex = [EBFilter ensureAreaExist:[range[0] integerValue] up:[range[1] integerValue]];
        }
    }

    NSString *room = dictionary[@"room"];
    if (room.length > 0)
    {
        NSArray *range = [room componentsSeparatedByString:@"-"];
        if (range.count == 2)
        {
            _roomIndex = [range[0] integerValue];
        }
    }

    NSString *community = dictionary[@"community"];
    if (community.length > 0)
    {
        _reservedCondition = @{@"community":community};
    }
    
    _hasPhoto = [dictionary[@"image"] boolValue];
}

- (void)parseFromHouse:(EBHouse *)house withDetail:(BOOL)detail
{
    _houseId = house.id;
    _houseType = [EBFilter typeString:house.rentalState];
    _requireOrRentalType = house.rentalState;

    if (detail)
    {
        NSInteger price = house.sellPrice != nil ? [house.sellPrice.amount integerValue] : [house.rentPrice.amount integerValue];
       _areaIndex = [EBFilter findByValue:(NSInteger)house.area inArray:[EBFilter rawAreaChoices]];
       _priceIndex = [EBFilter findByValue:price inArray:[self priceChoices]];
//       if (_priceIndex == 0)
//       {
//           _priceIndex = [EBFilter ensureSalePriceExist:price up:price];
//       }
       _roomIndex = house.room;
        [self safeRoomIndex];

       NSString *district = house.district;
       if (district.length > 0)
       {
           NSArray *districtChoices = [EBFilter rawDistrictChoices];
           for (NSInteger i = 0; i < districtChoices.count; i++)
           {
               if ([district isEqualToString:districtChoices[i][@"title"]])
               {
                   _district1 = i;
                   if (house.region.length > 0)
                   {
                       NSArray *childrenChoices = districtChoices[i][@"children"];
                       for (NSInteger j = 0; j < childrenChoices.count; j++)
                       {
                           if ([house.region isEqualToString:childrenChoices[j]])
                           {
                               _district2 = j;
                               break;
                           }
                       }
                   }
                   break;
               }
           }
       }
    }
}

- (void)parseFromClient:(EBClient *)client withDetail:(BOOL)detail
{
    _clientId = client.id;
    _clientType = [EBFilter typeString:client.rentalState];
    _requireOrRentalType = client.rentalState;

    if (detail)
    {
//        _areaIndex = [EBFilter findByValue:[client.areaRange[0] integerValue] inArray:[EBFilter rawAreaChoices]];
        _areaIndex = [EBFilter ensureAreaExist:[client.areaRange[0] integerValue] up:[client.areaRange[1] integerValue]];
//        _priceIndex = [EBFilter findByValue:[client.priceRange[0] integerValue] inArray:[self priceChoices]];
        if (_requireOrRentalType == 1)
        {
            _priceIndex = [EBFilter ensureRentPriceExist:[client.priceRange[0] integerValue] up:[client.priceRange[1] integerValue]];
        }
        else
        {
            _priceIndex = [EBFilter ensureSalePriceExist:[client.priceRange[0] integerValue] up:[client.priceRange[1] integerValue]];
        }
        if ([client.roomRange[0] integerValue] <= 0 && [client.roomRange[1] integerValue] > 6)
        {
            _roomIndex = 0;
        }
        else
        {
            _roomIndex = [client.roomRange[1] integerValue];
            [self safeRoomIndex];
        }
    }
}

+(NSInteger)ensureSalePriceExist:(NSInteger)down up:(NSInteger)up
{
    NSArray *prices = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_SALE_PRICE_OPTIONS];
    NSInteger found = [self findByDown:down up:up inArray:prices];
    if (found > 0)
    {
        return found;
    }
    else
    {
        NSMutableArray *newPrices = [[NSMutableArray alloc] initWithArray:prices];
        NSDictionary *lastPrice = [newPrices lastObject];
        NSString *title = [NSString stringWithFormat:@"%ld-%ld%@", down, up, NSLocalizedString(@"amount_unit", @"sale")];
        NSDictionary *newPrice = @{@"down":@(down), @"up":@(up), @"title":title, @"custom":@1};
        
        if (lastPrice && [lastPrice[@"custom"] boolValue])
        {
            [newPrices replaceObjectAtIndex:newPrices.count - 1 withObject:newPrice];
        }
        else
        {
            [newPrices addObject:newPrice];
        }
        [[EBCache sharedInstance] setObject:newPrices forKey:EB_CACHE_KEY_SALE_PRICE_OPTIONS];
        return newPrices.count - 1;
    }
}

+(NSInteger)ensureRentPriceExist:(NSInteger)down up:(NSInteger)up
{
    NSArray *prices = [[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_RENT_PRICE_OPTIONS];
    NSInteger found = [self findByDown:down up:up inArray:prices];
    if (found > 0)
    {
        return found;
    }
    else
    {
        NSMutableArray *newPrices = [[NSMutableArray alloc] initWithArray:prices];
        NSDictionary *lastPrice = [newPrices lastObject];
        NSString *title = [NSString stringWithFormat:@"%ld-%ld%@", down, up, NSLocalizedString(@"amount_rent_unit", @"rent")];
        NSDictionary *newPrice = @{@"down":@(down), @"up":@(up), @"title":title, @"custom":@1};
        
        if (lastPrice && [lastPrice[@"custom"] boolValue])
        {
            [newPrices replaceObjectAtIndex:newPrices.count - 1 withObject:newPrice];
        }
        else
        {
            [newPrices addObject:newPrice];
        }
        [[EBCache sharedInstance] setObject:newPrices forKey:EB_CACHE_KEY_RENT_PRICE_OPTIONS];
        return newPrices.count - 1;
    }
}

+(NSInteger)ensureAreaExist:(NSInteger)down up:(NSInteger)up
{
    NSArray *areas = [EBFilter rawAreaChoices];
    NSInteger found = [self findByDown:down up:up inArray:areas];
    if (found > 0)
    {
        return found;
    }
    else
    {
        NSMutableArray *newAreas = [[NSMutableArray alloc] initWithArray:areas];
        NSDictionary *lastArea = [newAreas lastObject];
        NSString *title = [NSString stringWithFormat:@"%ld-%ld%@", down, up, NSLocalizedString(@"area_unit", @"area")];
        NSDictionary *newArea = @{@"down":@(down), @"up":@(up), @"title":title, @"custom":@1};
        
        if (lastArea && [lastArea[@"custom"] boolValue])
        {
            [newAreas replaceObjectAtIndex:newAreas.count - 1 withObject:newArea];
        }
        else
        {
            [newAreas addObject:newArea];
        }
        [[EBCache sharedInstance] setObject:newAreas forKey:EB_CACHE_KEY_AREA_OPTIONS];
        return newAreas.count - 1;
    }
}

@end
