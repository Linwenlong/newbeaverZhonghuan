//
//  HotModel.h
//  beaver
//
//  Created by mac on 17/6/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotModel : NSObject

@property (nonatomic, strong)NSNumber *house_id;//house_id
@property (nonatomic, strong)NSString *house_title;//house_title

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
