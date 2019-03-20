//
//  RentChargeUnpaidTableViewCell.h
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RentChargeUnpaidTableViewCell : UITableViewCell


@property (nonatomic, strong) void(^btnClick)(NSInteger selectedIndex);

@property (nonatomic, strong)NSDictionary * dic;
@property (nonatomic, strong) UIButton * cost_btn;                      //费用btn

@end
