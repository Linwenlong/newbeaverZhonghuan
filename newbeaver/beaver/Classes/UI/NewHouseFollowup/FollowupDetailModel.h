//
//  FollowupDetailModel.h
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FollowupDetailModel : NSObject


@property (nonatomic, copy) NSString *status;//状态

@property (nonatomic, copy) NSString *memo;//新房标题

@property (nonatomic, copy) NSString *house_title;//新房标题

@property (nonatomic, copy) NSString *update_time;//更新

@property (nonatomic, copy) NSString *custom_name;//客户姓名

@property (nonatomic, copy) NSString *custom_phone;//手机号


- (instancetype)initWithDict:(NSDictionary *)dict;

@end
