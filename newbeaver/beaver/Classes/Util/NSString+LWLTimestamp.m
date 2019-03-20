//
//  NSString+LWLTimestamp.m
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NSString+LWLTimestamp.h"

@implementation NSString (LWLTimestamp)


#pragma mark -- 时间转时间戳

+(NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}


#pragma mark -- 时间戳转时间
+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)fromat{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:fromat];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

+ (NSMutableAttributedString *)changeString:(NSString*)str frontLength:(NSUInteger)frontLet frontColor:(UIColor *)frontColor otherColor:(UIColor *)otherColor{
    if (str.length < frontLet) {//输入的字符串长度小于前置
//        NSAssert(nil, @"输入的字符串长度小于前置");
        frontLet = str.length;
    }
    NSMutableAttributedString *attributeStr =[[NSMutableAttributedString alloc]initWithString:str];
    [attributeStr addAttributes:@{ NSForegroundColorAttributeName:frontColor} range:NSMakeRange(0, frontLet)];
    [attributeStr addAttributes:@{ NSForegroundColorAttributeName:otherColor} range:NSMakeRange(frontLet, str.length-frontLet)];
    return attributeStr;
}

+ (NSMutableAttributedString *)changeString:(NSString*)str frontLength:(NSUInteger)frontLet frontColor:(UIColor *)frontColor otherColor:(UIColor *)otherColor fontLength:(NSUInteger)fontLength frontFont:(UIFont *)frontFont otherFont:(UIFont *)otherFont{
    if (str.length < frontLet) {//输入的字符串长度小于前置
        //        NSAssert(nil, @"输入的字符串长度小于前置");
        frontLet = str.length;
        fontLength = str.length;
    }
    NSMutableAttributedString *attributeStr =[[NSMutableAttributedString alloc]initWithString:str];
    [attributeStr addAttributes:@{ NSForegroundColorAttributeName:frontColor} range:NSMakeRange(0, frontLet)];
    [attributeStr addAttributes:@{ NSForegroundColorAttributeName:otherColor} range:NSMakeRange(frontLet, str.length-frontLet)];
    
    [attributeStr addAttributes:@{ NSFontAttributeName:frontFont} range:NSMakeRange(0, fontLength)];
    
    [attributeStr addAttributes:@{ NSFontAttributeName:otherFont} range:NSMakeRange(fontLength, str.length-fontLength)];
    
    return attributeStr;
}


+ (BOOL)StringIsNullOrEmpty:(NSString *)str
{
    return (str == nil || [str isKindOfClass:[NSNull class]] || str.length == 0);
}

@end
