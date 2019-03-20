//
//  EBGatherHouse.m
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBGatherHouse.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation EBGatherHouse

+ (NSValueTransformer *)typeJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"sale": @(EGatherHouseRentalTypeSale),
            @"rent": @(EGatherHouseRentalTypeRent),
    }];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @"des": @"description"
    };
}

@end
