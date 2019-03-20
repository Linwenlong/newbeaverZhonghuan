//
//  MortgageAmendTopView.h
//  dev-beaver
//
//  Created by 林文龙 on 2019/1/8.
//  Copyright © 2019年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MortgageAmendTopView : UIView

@property (nonatomic, strong)void (^btnClick)(UITextField *textFiled1, UITextField *textFiled2,UIButton *btn);

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)str totle:(NSString *)priceNum first:(NSString *)first second:(NSString *)second;

@end
