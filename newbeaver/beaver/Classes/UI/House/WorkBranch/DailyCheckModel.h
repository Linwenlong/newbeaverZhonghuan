//
//  DailyCheckModel.h
//  beaver
//
//  Created by mac on 17/8/30.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyCheckModel : NSObject

@property (nonatomic, copy) NSNumber *document_id;//id
@property (nonatomic, copy) NSNumber *user_id;//user_id
@property (nonatomic, copy)NSString *username;//名字
@property (nonatomic, copy)NSString *department_name;//部门
@property (nonatomic, copy)NSString *status;//状态
@property (nonatomic, copy)NSString *comment;//内容
@property (nonatomic, copy)NSString *update_time;//创建时间

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
