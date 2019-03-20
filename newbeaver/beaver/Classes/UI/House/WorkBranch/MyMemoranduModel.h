//
//  MyMemoranduModel.h
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyMemoranduModel : NSObject

@property (nonatomic, copy) NSNumber *document_id;//id
@property (nonatomic, copy) NSNumber *user_id;//user_id
@property (nonatomic, copy) NSString *username;//名字
@property (nonatomic, copy) NSString *department;//门店
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, copy) NSString *content;//内容
@property (nonatomic, copy) NSString *create_time;//创建时间

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
