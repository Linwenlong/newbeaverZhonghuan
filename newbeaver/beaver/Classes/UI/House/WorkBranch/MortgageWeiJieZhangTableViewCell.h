//
//  MortgageWeiJieZhangTableViewCell.h
//  dev-beaver
//
//  Created by 林文龙 on 2019/1/8.
//  Copyright © 2019年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MortgageWeiJieZhangTableViewCell : UITableViewCell

@property (nonatomic, strong) void (^confirm)(UIButton *btn);

@property (nonatomic, strong)NSDictionary * dic;

@end
