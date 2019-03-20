//
// Created by 何 义 on 14-3-9.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBPrice.h"
#import "Mantle.h"


@implementation EBPrice
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @"unitCost": @"average_price"
    };
}

+ (NSValueTransformer *)amountJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *amount) {
        NSString *str = [NSString stringWithFormat:@"%@", amount];
        NSRange range = [str rangeOfString:@"."];
        if (range.location != NSNotFound && range.location + 1 < str.length - 1) {
            str = [str substringToIndex:range.location+2];
        }
        return str;
    } reverseBlock:^id(NSString *amount) {
        return amount;
    }];
}
@end