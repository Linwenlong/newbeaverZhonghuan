//
//  EBClientVisitLog.m
//  beaver
//
//  Created by wangyuliang on 14-5-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "EBClientVisitLog.h"
#import "EBHouse.h"


@implementation EBClientVisitLog

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"visitUser" : @"visit_user",
             @"visitDate" : @"visit_date",
             @"visitContent" : @"visit_content",
             @"images":@"image"
             };
}

+ (NSValueTransformer *)houseJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:EBHouse .class];
}

@end
