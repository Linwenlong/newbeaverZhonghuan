//
//  HomeViewController.h
//  FollowProject
//
//  Created by 刘海伟 on 16/9/18.
//  Copyright © 2016年 zhdc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , MenuType)
{
    ZHMenuTypeNewList = 1,//新房
    ZHMenuTypeContractDetailList  = 2,//合同详情
};


@interface VedioTeachViewController : UIViewController

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) MenuType menuType;


@end
