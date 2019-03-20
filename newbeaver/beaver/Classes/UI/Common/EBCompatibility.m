//
// Created by 何 义 on 14-4-23.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBCompatibility.h"
#import "EBNavigationController.h"
#import "UIImage+Alpha.h"
#import "EBStyle.h"
#import "UIImage+ImageWithColor.h"

#define EB_NAVIGATION_BAR_APPEARANCE [UINavigationBar appearanceWhenContainedIn:[EBNavigationController class], nil]

@implementation EBCompatibility

+ (void)setupGlobalAppearance
{
    
    UIImage *navBg = [UIImage imageNamed:@"nav_bground"];
    UIImage *backImage = [UIImage imageNamed:@"icon_back"];
    //设置导航
 
    [EB_NAVIGATION_BAR_APPEARANCE setBackgroundImage:navBg forBarMetrics:UIBarMetricsDefault];
    [EB_NAVIGATION_BAR_APPEARANCE setShadowImage:[UIImage new]];
    
    [EB_NAVIGATION_BAR_APPEARANCE setTintColor:[UIColor whiteColor]];
    [EB_NAVIGATION_BAR_APPEARANCE setTitleTextAttributes:
  
     @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:18.0]}];

    if ([self isIOS7Higher])
    {
        [EB_NAVIGATION_BAR_APPEARANCE setBackIndicatorImage:backImage];
        [EB_NAVIGATION_BAR_APPEARANCE setBackIndicatorTransitionMaskImage:[backImage imageByApplyingAlpha:0.4]];

//        [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0xff/255.f green:0xff/255.f blue:0xff/255.f alpha:1]];
        [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];

        CGRect rect = CGRectMake(0, 0, [EBStyle screenWidth], 0.5);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0xe6/255.f green:0xe6/255.f blue:0xe6/255.f alpha:1].CGColor);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[UITabBar appearance] setShadowImage:img];
//        UIImage *image = [[UIImage alloc] init];
    
//        [[UITabBar appearance] setBackgroundImage:img];

        
        [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor clearColor]];

        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
                setTitleTextAttributes:@{NSForegroundColorAttributeName : [EBStyle darkBlueTextColor],
                        NSFontAttributeName : [UIFont systemFontOfSize:14.0]
                } forState:UIControlStateNormal];
    }
    else
    {
        UIImage *bImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)];
        UIImage *bHImage = [[backImage imageByApplyingAlpha:0.4]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:bImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:bHImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

//        [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:0x1d/255.f green:0x1e/255.f blue:0x23/255.f alpha:1]];
        [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:AppMainColor(1)]];
//        [EB_NAVIGATION_BAR_APPEARANCE ]
        [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];


        [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateNormal];
        [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateHighlighted];
    }

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:132/255.f green:132/255.f blue:132/255.f alpha:1.0]}
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : AppMainColor(1)}
                                             forState:UIControlStateSelected];
//    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2.0)];

    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithRed:228/255.0 green:238/255.0 blue:250/255.0 alpha:1.0];
    [[UITableViewCell appearance] setSelectedBackgroundView:backgroundView];
}

+ (void)configAppearanceForSearchBar:(UISearchBar *)searchBar
{
    if ([self isIOS7Higher])
    {
        searchBar.barTintColor = [UIColor colorWithRed:0xde/255.0f green:0xe0/255.0f blue:0xe3/255.0f alpha:1.0];
    }
    else
    {
       [searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xde/255.0f green:0xe0/255.0f blue:0xe3/255.0f alpha:1.0]]];
    }
}

+ (BOOL)isIOS7Higher
{
    //如果是ios7及以上
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
}

@end