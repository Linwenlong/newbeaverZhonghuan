//
//  NSString+LWLTimestamp.h
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LWLTimestamp)

/**
 *  时间转时间戳
 *
 *  @param timeString 时间格式字符串
 *
 *  @return NSTimeInterval值
 */
+(NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString;

/**
 *  时间戳转时间
 *
 *  @param timeString 时间戳字符串
 *
 *  @return 时间格式字符串
 */
+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;

/**
 *  时间戳转时间
 *
 *  @param timeString 时间戳字符串
 *  @param fromat     时间格式
 *
 *  @return 时间格式字符串
 */
+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)fromat;

/**
 *  富文本字符串
 *
 *  @param str        需要转的字符串
 *  @param frontLet   前面需要的字符串长度（大于给出的字符串就登录字符串长度）
 *  @param frontColor 前面的字符串颜色
 *  @param otherColor 其他的颜色
 *
 *  @return 富文本字符串
 */
+ (NSMutableAttributedString *)changeString:(NSString*)str frontLength:(NSUInteger)frontLet frontColor:(UIColor *)frontColor otherColor:(UIColor *)otherColor;


+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)fromat;

/**
 *  富文本字符串
 *
 *  @param str        需要转的字符串
 *  @param frontLet   前面需要的字符串长度（大于给出的字符串就登录字符串长度）
 *  @param frontColor 前面的字符串颜色
 *  @param otherColor 其他的颜色
 *
 *  @return 富文本字符串
 */
+ (NSMutableAttributedString *)changeString:(NSString*)str frontLength:(NSUInteger)frontLet frontColor:(UIColor *)frontColor otherColor:(UIColor *)otherColor fontLength:(NSUInteger)fontLength frontFont:(UIFont *)frontFont otherFont:(UIFont *)otherFont;

/**
 *  判断null
 *
 *  @param str 字符串
 *
 *  @return 返回bool
 */
+ (BOOL)StringIsNullOrEmpty:(NSString *)str;

@end
