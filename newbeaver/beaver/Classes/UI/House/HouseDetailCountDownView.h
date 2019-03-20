//
//  HouseDetailCountDownView.h
//  dev-beaver
//
//  Created by 林文龙 on 2018/12/20.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseDetailCountDownView : UIView


@property (nonatomic, strong) void (^call_click)(NSString *phoneNumber);

@property (nonatomic, strong) UILabel * countMintus;

@property (nonatomic, strong) void (^img_click)(void);

- (instancetype)initWithFrame:(CGRect)frame withPhone:(NSString *)phone;

@end
