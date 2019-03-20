//
//  ZHEditTwoController.h
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  选择费用名称two

#import <UIKit/UIKit.h>

@class ZHEditTwoController;
@protocol EditTwoControllerDelegate <NSObject>
// 点击取消按钮的时候调用
- (void)EditTwoControllerDidClickCancelBtn:(ZHEditTwoController *)pickVC;

// 点击确认按钮的时候调用
- (void)EditTwoControllerDidClickSureBtn:(ZHEditTwoController *)pickVC withProvince:(NSString *)province;

@end

@interface ZHEditTwoController : UIViewController
@property (nonatomic, weak) id<EditTwoControllerDelegate> delegate;
/** 费用类型 */
@property (nonatomic, copy) NSString *costType;
@property (nonatomic, copy) NSString *token;

@end
