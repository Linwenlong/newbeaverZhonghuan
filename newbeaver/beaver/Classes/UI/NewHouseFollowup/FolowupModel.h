//
//  FolowupModel.h
//  beaver
//
//  Created by mac on 17/6/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolowupModel : NSObject

@property (nonatomic, copy) NSString *document_id;//客户id
@property (nonatomic, copy) NSString *house_title;//新房标题
@property (nonatomic, copy)NSString *house_id;
@property (nonatomic, copy) NSString *custom_detail;//客户姓名+客服手机号

@property (nonatomic, copy) NSString *create_time;//xin
@property (nonatomic, copy) NSString *status;//状态
@property (nonatomic, copy) NSString *custom_remarks;//@"备注"+状态

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
