//
//  NewHouseListModel.m
//  beaver
//
//  Created by mac on 17/4/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewHouseListModel.h"

@implementation NewHouseListModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.house_id = dict[@"id"];
        self.house_image = dict[@"imagecover"];
        self.house_name = dict[@"title"];
        self.house_area =[NSString stringWithFormat:@"%@-%@m²",dict[@"area_min"],dict[@"area_max"]] ;
        self.house_unit =[NSString stringWithFormat:@"%@元/m²",dict[@"unit_pay"]];
        self.house_commission =dict[@"commission_text"] ;
        self.house_Type =dict[@"purpose"] ;
        self.house_address =dict[@"address"] ;
        self.sale_status = dict[@"sale_status"];
    }
    return self;
}

@end
