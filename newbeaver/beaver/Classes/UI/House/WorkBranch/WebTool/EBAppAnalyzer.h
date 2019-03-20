//
//  EBAppAnalyzer.h
//  beaver
//  用于解析APP转APP的部分页面
//  Created by 凯文马 on 15/12/22.
//  Copyright © 2015年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBAppAnalyzer : NSObject

@property (nonatomic, copy, readonly) NSString *viewControllerKey;

@property (nonatomic, strong, readonly) NSDictionary *param;

- (instancetype)initWithJSON:(NSString *)JSON;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (UIViewController *)toViewController;

@end
