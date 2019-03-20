//
//  CollectiveUpdataModel.h
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectiveUpdataModel : NSObject

@property (nonatomic, strong)NSString *house_id;
@property (nonatomic, strong)NSString *house_title;

- (instancetype)initWithDict:(NSDictionary *)dict;


@end
