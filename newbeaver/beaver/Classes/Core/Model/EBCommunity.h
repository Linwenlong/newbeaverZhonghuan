//
//  EBCommunity.h
//  beaver
//
//  Created by wangyuliang on 15/5/7.
//  Copyright (c) 2015年 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBCommunity : EBBaseModel

@property (nonatomic, copy) NSString *communityId;
@property (nonatomic, copy) NSString *community;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *district_id;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *region_id;
@property (nonatomic, copy) NSString *if_start;
@property (nonatomic, copy) NSString *open_page_url;

@end
