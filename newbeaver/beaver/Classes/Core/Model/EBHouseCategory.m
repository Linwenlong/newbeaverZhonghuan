//
//  EBHouseCategory.m
//  beaver
//
//  Created by 何 义 on 14-3-6.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBHouseCategory.h"

@implementation EBHouseCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"isCustom": @"is_custom",
            @"des": @"description"
    };
}

@end
