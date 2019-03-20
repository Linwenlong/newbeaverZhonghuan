//
//  WorkLogModel.h
//  beaver
//
//  Created by mac on 17/12/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkLogModel : NSObject

@property (nonatomic, copy) NSString *logDate;
@property (nonatomic, copy) NSString *logType;
@property (nonatomic, copy) NSString *logName;
@property (nonatomic, copy) NSString *logDept;
@property (nonatomic, copy) NSString *logContent;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
