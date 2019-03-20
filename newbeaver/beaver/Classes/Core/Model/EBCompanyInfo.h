//
//  EBCompanyInfo.h
//  beaver
//
//  Created by ChenYing on 14-8-12.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBBaseModel.h"

@interface EBCompanyInfo : EBBaseModel

@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *companyId;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *cityNamePinYin;

@end
