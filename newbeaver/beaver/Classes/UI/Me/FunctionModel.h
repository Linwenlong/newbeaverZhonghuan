//
//  FunctionModel.h
//  beaver
//
//  Created by mac on 17/11/30.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunctionModel : NSObject

@property (nonatomic, copy)NSString *subtitle;
@property (nonatomic, copy)NSString *date;
@property (nonatomic, copy)NSString *content;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
