//
// Created by 何 义 on 14-3-8.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBClient.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "Mantle.h"

@implementation EBClient

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"contractCode": @"contract_code",
            @"delegationAgent": @"delegation_agent",
            @"inputAgent": @"input_agent",
            @"closeAgent": @"close_agent",
            @"priceRange": @"price_range",
            @"floorRange": @"floor_range",
            @"inputDate": @"input_date",
            @"roomRange": @"room_range",
            @"areaRange": @"area_range",
            @"ageRange": @"age_range",
            @"phoneNumbers": @"phone_numbers",
            @"timesRemain": @"times_remain",
            @"rentalState": @"rental_state",
            @"fullPaid": @"full_paid",
            @"collected":@"collect",
            @"inputbyme": @"input_by_me",
            @"ownbyme": @"own_by_me",
            @"enableanonymouscall": @"enable_anonymous_call",
            @"companyhasbalance": @"company_has_balance",
            @"recommendTags": @"recommend_tag",
            @"clientPri": @"client_pri",
            @"extraArray": @"extra",
            @"factoryExtra": @"factory_extra",
            @"memo": @"memo",
            @"coreMemo": @"core_memo",
            @"changeStatus": @"change_status",
            @"decoration": @"decoration",
            @"fitment": @"fitment",
            @"direction": @"direction",
            @"reason": @"reason",
            @"source": @"source",
            @"purpose": @"purpose",
            @"doorWidth": @"door_width",
            @"follow": @"follow"
    };
}

+ (NSValueTransformer *)accessJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"public": @(EClientAccessTypePublic),
            @"private": @(EClientAccessTypePrivate)
    }];
}

+ (NSValueTransformer *)delegationAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

+ (NSValueTransformer *)inputAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

+ (NSValueTransformer *)closeAgentJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBContact.class];
}

//+ (NSValueTransformer *)purposeJSONTransformer
//{
//    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
//            NSLocalizedString(@"house_purpose_1", nil): @(EClientPurposeTypeVilla),
//            NSLocalizedString(@"house_purpose_2", nil): @(EClientPurposeTypeWorkshop),
//            NSLocalizedString(@"house_purpose_3", nil): @(EClientPurposeTypeCarport),
//            NSLocalizedString(@"house_purpose_4", nil): @(EClientPurposeTypeApartment),
//            NSLocalizedString(@"house_purpose_5", nil): @(EClientPurposeTypeShop),
//            NSLocalizedString(@"house_purpose_6", nil): @(EClientPurposeTypeCommercial),
//            NSLocalizedString(@"house_purpose_7", nil): @(EClientPurposeTypeLand),
//            NSLocalizedString(@"house_purpose_8", nil): @(EClientPurposeTypeOfficeBuilding),
//            NSLocalizedString(@"house_purpose_9", nil): @(EClientPurposeTypeResidence)}];
//}

+ (NSValueTransformer *)purposeJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *roomNo) {
        if (roomNo == nil || [roomNo isKindOfClass:[NSNull class]] || roomNo.length < 1) {
            return @0;
        }
        else
        {
            NSValueTransformer *transformer = [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                            NSLocalizedString(@"house_purpose_1", nil): @(EClientPurposeTypeVilla),
                                                                            NSLocalizedString(@"house_purpose_2", nil): @(EClientPurposeTypeWorkshop),
                                                                            NSLocalizedString(@"house_purpose_3", nil): @(EClientPurposeTypeCarport),
                                                                            NSLocalizedString(@"house_purpose_4", nil): @(EClientPurposeTypeApartment),
                                                                            NSLocalizedString(@"house_purpose_5", nil): @(EClientPurposeTypeShop),
                                                                            NSLocalizedString(@"house_purpose_6", nil): @(EClientPurposeTypeCommercial),
                                                                            NSLocalizedString(@"house_purpose_7", nil): @(EClientPurposeTypeLand),
                                                                            NSLocalizedString(@"house_purpose_8", nil): @(EClientPurposeTypeOfficeBuilding),
                                                                            NSLocalizedString(@"house_purpose_9", nil): @(EClientPurposeTypeResidence)}];
            return [NSNumber numberWithInteger:[[transformer transformedValue:roomNo] integerValue]];
//            NSNumber *temp = [NSNumber numberWithInteger:[[transformer reverseTransformedValue:@0] integerValue]];
//            return temp;
        }
        
    } reverseBlock:^(NSString *roomNo) {
        return @0;
    }];
}

@end