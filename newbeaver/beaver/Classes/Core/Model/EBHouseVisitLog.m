//
// Created by 何 义 on 14-5-27.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "EBHouseVisitLog.h"
#import "EBClient.h"


@implementation EBHouseVisitLog

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"visitUser" : @"visit_user",
            @"visitDate" : @"visit_date",
            @"visitContent" : @"visit_content",
    };
}

+ (NSValueTransformer *)clientJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBClient .class];
}


@end
