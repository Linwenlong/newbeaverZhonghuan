//
//  ZHEditOneController.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  选择费用类型one

#import <UIKit/UIKit.h>

@class ZHEditOneController;
@protocol EditOneControllerDelegate <NSObject>
// 点击取消按钮的时候调用
- (void)EditOneControllerDidClickCancelBtn:(ZHEditOneController *)pickVC;

// 点击确认按钮的时候调用
- (void)EditOneControllerDidClickSureBtn:(ZHEditOneController *)pickVC withProvince:(NSString *)province;

@end

@interface ZHEditOneController : UIViewController
@property (nonatomic, weak) id<EditOneControllerDelegate> delegate;

@end
