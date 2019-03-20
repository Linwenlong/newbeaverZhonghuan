//
//  HouseCreateNewGroupView.h
//  dev-beaver
//
//  Created by 林文龙 on 2018/11/26.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseCreateNewGroupView : UIView

@property (nonatomic, strong) void(^btnClick)(UIButton *btn, UITextField *groupNanme);

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)str placeholder:(NSString *)placeholder;

@end
