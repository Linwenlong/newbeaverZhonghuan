//
//  EBClientVisitLog.h
//  beaver
//
//  Created by wangyuliang on 14-5-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"


@class EBHouse;


@interface EBClientVisitLog : EBBaseModel

@property (nonatomic, copy)  NSString *visitUser;
//@property (nonatomic, copy)  NSString *visitDate;
@property (nonatomic)  NSInteger visitDate;
@property (nonatomic, copy)  NSString *visitContent;
@property (nonatomic, strong) EBHouse *house;
@property (nonatomic,strong) NSArray *images;
@end
