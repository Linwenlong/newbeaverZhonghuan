//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBHouse.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "EBContact.h"
#import "EBPrice.h"
#import "Mantle.h"


@implementation EBHouse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"contractCode": @"contract_code",
//            @"priceUnit": @"price_unit",
            @"delegationAgent": @"delegation_agent",
            @"inputAgent": @"input_agent",
            @"closeAgent": @"close_agent",
            @"keyAgent": @"key_agent",
//            @"priceTrend": @"price_trend",
            @"floorNumber": @"floor_number",
            @"timesRemain": @"times_remain",
            @"sellPrice": @"sell_price",
            @"rentPrice": @"rent_price",
            @"phoneNumbers": @"phone_numbers",
            @"delegationType": @"delegation_type",
            @"rentalState": @"rental_state",
            @"keysLocation": @"keys_location",
            @"elevatorNumber": @"elevator_number",
            @"householdNumber": @"household_number",
            @"builtYear": @"built_year",
            @"curInfo": @"curinfo",
            @"facility": @"supporting",
            @"inputDate": @"input_date",
            @"collected":@"collect",
            @"inputbyme": @"input_by_me",
            @"ownbyme": @"own_by_me",
            @"enableanonymouscall": @"enable_anonymous_call",
            @"companyhasbalance": @"company_has_balance",
            @"purpose": @"purpose",
            @"recommendTags": @"recommend_tag",
            @"extraArray": @"extra",
            @"factoryExtra": @"factory_extra",
            @"address": @"address",
            @"road": @"road",
            @"visitCat": @"visit_cat",
            @"entrustProp":@"entrust_prop",
            @"entrustNum": @"entrust_num",
            @"submitDate": @"submit_date",
            @"keyStore": @"key_store",
            @"source": @"source",
            @"doorWidth": @"door_width",
            @"depth": @"depth",
            @"height": @"height",
            @"width": @"width",
            @"length": @"length",
            @"variablePower": @"variable_power",
            @"area": @"area",
            @"dormArea": @"dorm_area",
            @"officeArea" :@"office_area",
            @"usableArea": @"usable_area",
            @"spaceArea": @"space_area",
            @"loadBearing": @"load_bearing",
            @"memo": @"memo",
            @"coreMemo": @"core_memo",
            @"housePri": @"house_pri",
            @"district": @"district",
            @"region": @"region",
            @"community": @"community",
            @"follow": @"follow",
            @"priUploadVideo": @"pri_upload_video",
            @"cover":@"cover",
            
    };
}

+ (NSValueTransformer *)accessJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"public": @(EHouseAccessTypePublic),
            @"private": @(EHouseAccessTypePrivate)
    }];
}

+ (NSValueTransformer *)rentPriceJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBPrice.class];
}

+ (NSValueTransformer *)sellPriceJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBPrice.class];
}

+ (NSValueTransformer *)delegationAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

+ (NSValueTransformer *)closeAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

+ (NSValueTransformer *)inputAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

+ (NSValueTransformer *)keyAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

//+ (NSValueTransformer *)purposeJSONTransformer
//{
//    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
//            NSLocalizedString(@"house_purpose_1", nil): @(EHousePurposeTypeVilla),
//            NSLocalizedString(@"house_purpose_2", nil): @(EHousePurposeTypeWorkshop),
//            NSLocalizedString(@"house_purpose_3", nil): @(EHousePurposeTypeCarport),
//            NSLocalizedString(@"house_purpose_4", nil): @(EHousePurposeTypeApartment),
//            NSLocalizedString(@"house_purpose_5", nil): @(EHousePurposeTypeShop),
//            NSLocalizedString(@"house_purpose_6", nil): @(EHousePurposeTypeCommercial),
//            NSLocalizedString(@"house_purpose_7", nil): @(EHousePurposeTypeLand),
//            NSLocalizedString(@"house_purpose_8", nil): @(EHousePurposeTypeOfficeBuilding),
//            NSLocalizedString(@"house_purpose_9", nil): @(EHousePurposeTypeResidence)
//    }];
//}

+ (NSValueTransformer *)purposeJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *roomNo) {
        if (roomNo == nil || [roomNo isKindOfClass:[NSNull class]] || roomNo.length < 1) {
            return @0;
        }
        else
        {
            return [NSNumber numberWithInteger:[[[NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                                                                 NSLocalizedString(@"house_purpose_1", nil): @(EHousePurposeTypeVilla),
                                                                                                                 NSLocalizedString(@"house_purpose_2", nil): @(EHousePurposeTypeWorkshop),
                                                                                                                 NSLocalizedString(@"house_purpose_3", nil): @(EHousePurposeTypeCarport),
                                                                                                                 NSLocalizedString(@"house_purpose_4", nil): @(EHousePurposeTypeApartment),
                                                                                                                 NSLocalizedString(@"house_purpose_5", nil): @(EHousePurposeTypeShop),
                                                                                                                 NSLocalizedString(@"house_purpose_6", nil): @(EHousePurposeTypeCommercial),
                                                                                                                 NSLocalizedString(@"house_purpose_7", nil): @(EHousePurposeTypeLand),
                                                                                                                 NSLocalizedString(@"house_purpose_8", nil): @(EHousePurposeTypeOfficeBuilding),
                                                                                                                 NSLocalizedString(@"house_purpose_9", nil): @(EHousePurposeTypeResidence)
                                                                                                                 }] transformedValue:roomNo] integerValue]];
        }
    } reverseBlock:^(NSString *roomNo) {
        return @0;
    }];
    
}

@end
