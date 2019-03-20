//
//  NewHouseListModel.h
//  beaver
//
//  Created by mac on 17/4/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NewHouseListModel : NSObject

@property (nonatomic, strong)NSNumber *house_id;//house_id
@property (nonatomic, strong)NSString *house_image;//imagecover

@property (nonatomic, strong)NSString *house_name;//title

@property (nonatomic, strong)NSString *house_area;//house_area
@property (nonatomic, strong)NSString *house_unit;//unit_pay
@property (nonatomic, strong)NSString *house_commission;//commission_text 佣金
@property (nonatomic, strong)NSString *house_Type;//purpose
@property (nonatomic, strong)NSString *house_address;//address

//房源状态
@property (nonatomic, strong)NSString *sale_status;//状态

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
