//
//  DeleteGroupPopView.h
//  dev-beaver
//
//  Created by 林文龙 on 2018/12/5.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeleteGroupPopView : UIView

@property (nonatomic, strong) void(^btnClick)(UIButton *btn);

- (instancetype)initWithFrame:(CGRect)frame;

@end
