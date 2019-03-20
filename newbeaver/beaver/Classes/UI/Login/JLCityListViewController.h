//
//  JLCityListViewController.h
//  chow
//
//  Created by eall_linger on 16/4/15.
//  Copyright © 2016年 eallcn. All rights reserved.
//
//  选择城市控制器

#import "BaseViewController.h"

@protocol JLCityListViewControllerDelegate<NSObject>

- (void)seletedCity:(NSDictionary *)city;

@end

@interface JLCityListViewController : BaseViewController

@property (nonatomic, copy) NSString *current_city;//

@property (nonatomic, copy) void(^returnBlock)(NSString *company_name ,NSString *company_code);

@property (nonatomic,assign)id<JLCityListViewControllerDelegate>delegate;

@end
