//
//  MySeeDetailModel.h
//  beaver
//
//  Created by mac on 17/8/31.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySeeDetailModel : NSObject

@property (nonatomic, copy)NSString *client_code;
@property (nonatomic, copy)NSNumber *house_num;
@property (nonatomic, copy)NSString *client_name;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, copy)NSString *tel;

@property (nonatomic, copy)NSString *create_time;
@property (nonatomic, copy)NSString *house_ids;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
