//
// Created by 何 义 on 14-2-18.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , EBPhoneUpLoadState)
{
    EBPhoneUpLoadingFail = 1,
    EBPhoneUpLoadingNormal = 2,
    EBPhoneUpLoadFail = 3,
    EBPhoneUpLoadSuccess = 4,
};

@interface MainTabViewController : UITabBarController<UITabBarControllerDelegate>

- (void)setupTabs;

/**
 *新的跳转
 */
- (void)newSetupTabs;

@end