//
//  HomeViewController.h
//  FollowProject
//
//  Created by 刘海伟 on 16/9/18.
//  Copyright © 2016年 zhdc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , EMenuType)
{
    EMenuTypeNewHouse = 1,//新房报备
    EMenuTypeCostCount //费用统计
};

@interface VedioTeachViewController : UIViewController

@property (nonatomic, assign) EMenuType menuType;
@property (nonatomic, assign) NSInteger count;

@end
