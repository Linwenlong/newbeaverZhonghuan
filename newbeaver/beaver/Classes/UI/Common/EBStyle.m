//
// Created by 何 义 on 14-2-28.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBStyle.h"
#import "EBCompatibility.h"


@implementation EBStyle

+ (CGFloat)screenWidth
{
    CGRect frame = [UIScreen mainScreen].bounds;
    return frame.size.width;
}
+ (CGFloat)screenHeight
{
    CGRect frame = [UIScreen mainScreen].bounds;
    return frame.size.height;
}

+ (BOOL)isUnder_iPhone5
{
    return [UIScreen mainScreen].bounds.size.height <= 480;
}

+ (CGFloat)activityIndicatorSize
{
     return 32.0f;
}

+ (CGFloat)loadingOffsetYInListView
{
    return [EBStyle isUnder_iPhone5] ? 130.f : 145.0f;
}

+ (CGFloat)loginLogoOffsetY
{
    return [EBStyle isUnder_iPhone5] ? 120.f : 142.f;
}

+ (CGFloat)emptyOffsetYInListView
{
    return [EBStyle isUnder_iPhone5] ? 115.f : 130.0f;
}

+ (CGFloat)failOffsetYInListView
{
    return [EBStyle isUnder_iPhone5] ? 115.f : 130.0f;
}

+ (CGFloat)separatorLineHeight
{

    return 0.5f;
}

+ (CGFloat)separatorLeftMargin
{
    return [EBCompatibility isIOS7Higher] ? 15.0f : 10.0;
}

+ (CGFloat)buttonCornerRadius
{
    return 5.0f;
}

+ (CGFloat)viewPagerCursorHeight
{
     return [EBStyle isUnder_iPhone5] ? 1.0f : 2.0f;
}

+ (CGFloat)viewPagerHeight
{
    return [EBStyle isUnder_iPhone5] ? 34.0f : 44.0f;
}

+ (CGFloat)buttonBorderWidth
{
   return 1.0f;
}

+ (CGRect)fullScrTableFrame:(BOOL)inTab
{
    CGFloat dy = inTab ?  114.0 : 64.0;
    CGRect frame = [UIScreen mainScreen].bounds;
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - dy);
}

+ (CGRect)viewPagerFrame
{
    CGRect frame = [UIScreen mainScreen].bounds;
    return CGRectMake(0, 0.0f, frame.size.width, [EBStyle viewPagerHeight]);
}

+ (UIColor *)grayClickLineColor
{
    return [UIColor colorWithWhite:0xcf/255.0f alpha:1.0];
    return [UIColor colorWithRed:184/255.f green:184/255.f blue:185/255.f alpha:1.0];
}

+ (UIColor *)grayUnClickLineColor
{
    return [UIColor colorWithWhite:0xe8/255.0f alpha:1.0];
}

+ (UIColor *)grayTextColor
{
    return [UIColor colorWithRed:168/255.f green:169/255.f blue:170/255.f alpha:1.0];
}

+ (UIColor *)blackTextColor
{
    return [UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1.0];
}

+ (UIColor *)redTextColor
{
    return [UIColor colorWithRed:255/255.f green:69/255.f blue:0/255.f alpha:1.0];
}

+ (UIColor *)darkRedTextColor
{
    return [UIColor colorWithRed:211/255.f green:65/255.f blue:68/255.f alpha:1.0];
}

+ (UIColor *)greenTextColor
{
    return [UIColor colorWithRed:64/255.f green:199/255.f blue:49/255.f alpha:1.0];
}

+ (UIColor *)lightGreenTextColor
{
    return [UIColor colorWithRed:117/255.f green:169/255.f blue:57/255.f alpha:1.0];
}

+ (UIColor *)shallowLightGreenTextColor
{
    return [UIColor colorWithRed:117/255.f green:169/255.f blue:57/255.f alpha:0.4];
}

+ (UIColor *)blueBorderColor
{
    return AppMainColor(1);
}

+ (UIColor *)blueTextColor
{
    return AppMainColor(1);
}

+ (UIColor *)blueMainColor
{
    return AppMainColor(1);
}

+ (UIColor *)darkBlueTextColor
{
    return AppMainColor(1);
}

+ (UIColor *)darkBlueHighlightTextColor
{
    return [UIColor colorWithRed:32/255.f green:126/255.f blue:225/255.f alpha:0.4];
}

+ (UIColor *)cellValueTextColor
{
    return [UIColor colorWithRed:56/255.f green:126/255.f blue:205/255.f alpha:1.0];
}

+ (NSNumberFormatter *)numberFormatter
{
    NSNumberFormatter *formatter;
    if (formatter == nil)
    {
        formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setMinimumFractionDigits:2];
    }

    return formatter;
}

+ (NSString *)formatFloat:(CGFloat)number
{
    NSNumberFormatter *formatter = [EBStyle numberFormatter];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:number]];
}

+ (NSString *)formatMoney:(CGFloat)number
{
    return [NSString stringWithFormat:NSLocalizedString(@"md_result_yuan_fmt", nil), [EBStyle formatFloat:number]];
}


@end
