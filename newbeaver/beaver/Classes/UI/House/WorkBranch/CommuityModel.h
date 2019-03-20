//
//  CommuityModel.h
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommuityModel : NSObject<NSCoding>

@property (nonatomic, copy) NSNumber *commuity_id;//id
@property (nonatomic, copy) NSString *commuity_name;//小区名字
@property (nonatomic, copy)NSString *pname;//片区
@property (nonatomic, copy)NSString *ppname;//行政区
@property (nonatomic, copy)NSString *spell;//拼音
@property (nonatomic, copy)NSString *address;//地址

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
