//
//  MortgageConfrimTopView.h
//  dev-beaver
//
//  Created by 林文龙 on 2019/1/8.
//  Copyright © 2019年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MortgageConfrimTopView : UIView

@property (nonatomic, strong) void(^btnClick)(UIButton *btn);

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)str;

@end
