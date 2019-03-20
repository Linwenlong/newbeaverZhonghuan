//
//  ZHAreaManagerController.h
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/22.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  工作总结-区域经理模块

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ZHAreaManagerController : BaseViewController

/** 测试,不同角色传入VcTag */
@property (nonatomic, assign) NSInteger VcTag;

@property (nonatomic, strong) NSString *document_id;

@property (nonatomic, strong) NSDictionary *dayData;    //日数据
@property (nonatomic, strong) NSDictionary *monthData;  //月数据

@end
