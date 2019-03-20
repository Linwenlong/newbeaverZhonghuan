//
//  NewsModel.h
//  beaver
//
//  Created by mac on 17/7/25.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property (nonatomic, copy) NSString *detail;//客户id
@property (nonatomic, copy) NSString *title;//新房标题
@property (nonatomic, copy)NSString *type;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
