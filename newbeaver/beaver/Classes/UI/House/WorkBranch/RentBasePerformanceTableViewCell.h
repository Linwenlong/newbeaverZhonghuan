//
//  RentBasePerformanceTableViewCell.h
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RentBasePerformanceTableViewCell : UITableViewCell

@property (nonatomic, strong)NSDictionary * dic;

- (void)setDic:(NSDictionary *)dic pay_money:(NSString *)payMoney expect_money:(NSString *)expect_money;

@end
