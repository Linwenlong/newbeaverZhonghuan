//
// Created by 何 义 on 14-5-27.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "EBAppointment.h"
#import "EBClient.h"
#import "EBHouse.h"


@implementation EBAppointment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"timestamp" : @"visit_date",
            @"addressTitle" : @"visit_address",
            @"longitude" : @"longtitude",
            @"addressDetail" : @"location",
            @"houseIds" : @"houseid"
    };
}

+ (NSValueTransformer *)clientJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBClient.class];
}

+ (NSValueTransformer *)housesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:EBHouse.class];
}

@end
