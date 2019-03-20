//
//  FinanceDetailModel.h
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FinanceDetailModel : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *value;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
