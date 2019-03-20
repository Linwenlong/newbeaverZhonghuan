//
// Created by 何 义 on 14-7-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "EBBusinessConfig.h"

@implementation EBConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @"statusMap" : @"status_map",
            @"purposes" : @"purpose",
            @"recommendTags" : @"recommend_tag",
            @"reportTypes" : @"report_type",
            @"appellations" : @"appellation",
            @"telDescriptions" : @"tel_desc",
            @"photoDescriptions" : @"image_position",
            @"followTypes" : @"follow_type",
            @"allowAdd" : @"has_add_privilege",
            @"wantNew" : @"new",
            @"housingType":@"housingType"
    };
}

@end

@implementation EBBusinessConfig

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @"houseConfig" : @"house",
            @"clientConfig" : @"client"
    };
}

+ (NSValueTransformer *)clientConfigJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBConfiguration.class];
}

+ (NSValueTransformer *)houseConfigJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBConfiguration.class];
}

@end

