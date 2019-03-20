//
//  EBClientFollowLog.h
//  beaver
//
//  Created by wangyuliang on 14-6-20.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBClientFollowLog : EBBaseModel
@property (nonatomic, copy) NSString *content;
@property (nonatomic)  NSInteger date;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *way;
@property (nonatomic) BOOL is_tel_record;
@property (nonatomic, copy) NSString *contractCode;
@property (nonatomic, strong) NSDictionary *record;

@end
