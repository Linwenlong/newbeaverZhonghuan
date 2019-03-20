//
// Created by 何 义 on 14-2-28.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface EBStyle : NSObject

// 获取设备的宽和高
+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;

+ (BOOL)isUnder_iPhone5;
+ (CGFloat)activityIndicatorSize;
+ (CGFloat)loginLogoOffsetY;
+ (CGFloat)loadingOffsetYInListView;
+ (CGFloat)emptyOffsetYInListView;
+ (CGFloat)failOffsetYInListView;
+ (CGFloat)separatorLineHeight;
+ (CGFloat)separatorLeftMargin;
+ (CGFloat)buttonCornerRadius;
+ (CGFloat)buttonBorderWidth;
+ (CGFloat)viewPagerCursorHeight;
+ (CGFloat)viewPagerHeight;
+ (CGRect)fullScrTableFrame:(BOOL)inTab;
+ (CGRect)viewPagerFrame;
+ (UIColor *)grayClickLineColor;
+ (UIColor *)grayUnClickLineColor;
+ (UIColor *)grayTextColor;
+ (UIColor *)redTextColor;
+ (UIColor *)darkRedTextColor;
+ (UIColor *)greenTextColor;
+ (UIColor *)lightGreenTextColor;
+ (UIColor *)shallowLightGreenTextColor;
+ (UIColor *)blackTextColor;
+ (UIColor *)blueBorderColor;
+ (UIColor *)blueTextColor;
+ (UIColor *)darkBlueTextColor;
+ (UIColor *)darkBlueHighlightTextColor;
+ (UIColor *)cellValueTextColor;
+ (UIColor *)blueMainColor;
+ (NSNumberFormatter *)numberFormatter;
+ (NSString *)formatFloat:(CGFloat)number;
+ (NSString *)formatMoney:(CGFloat)number;

@end