//
//  HouseNewFollowLogRecordModel.h
//  beaver
//
//  Created by 林文龙 on 2018/8/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HouseNewFollowLogRecordModel : NSObject

@property (nonatomic, strong)NSString *date;//时间
@property (nonatomic, strong)NSString *department;//部门
@property (nonatomic, strong)NSString *user;//名字
@property (nonatomic, strong)NSString *way;//跟进方式
@property (nonatomic, assign)BOOL is_tel_record;//是否是录音
@property (nonatomic, strong)NSDictionary *c_record;//跟进录音
@property (nonatomic, strong)NSString *avatar;//头像url
@property (nonatomic, strong)NSString *content;//跟进内容

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
