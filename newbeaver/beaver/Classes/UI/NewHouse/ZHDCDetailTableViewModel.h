//
//  ZHDCDetailTableViewModel.h
//  beaver
//
//  Created by mac on 17/6/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHDCDetailTableViewModel : NSObject

@property (nonatomic, strong)NSString *leftType;
@property (nonatomic, strong)NSString *leftConTent;

@property (nonatomic, strong)NSString *rightType;
@property (nonatomic, strong)NSString *rightConTent;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
