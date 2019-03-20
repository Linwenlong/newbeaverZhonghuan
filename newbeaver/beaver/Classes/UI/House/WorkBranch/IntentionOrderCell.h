//
//  IntentionOrderCell.h
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/28.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  纯代码自定义"意向单"cell

#import <UIKit/UIKit.h>


@protocol  IntentionOrderDelegate <NSObject>

- (void)getContentViewText:(UITextView *)textView;

@end

@interface IntentionOrderCell : UITableViewCell<UITextViewDelegate>

/** 1.0 背景View */
@property (nonatomic, strong) UIView *bgView;

/** 2.0 右上角删除图标 */
@property (nonatomic, strong) UIImageView *deleteImage;

/** 3.0 下划线line1和line2 */
@property (nonatomic, strong) UIView *lineOne;
@property (nonatomic, strong) UIView *lineTwo;

/** 4.0 姓名lbl和输入textField */
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UITextField *nameField ;

/** 5.0 客源号lbl和选择客源编号btn */
@property (nonatomic, strong) UILabel *clientCodeLbl;
@property (nonatomic, strong) UIButton *chooseClientCodeBtn;

/** 6.0 情况汇报lbl和输入textView及占位lbl */
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *tipLbl;

@property (nonatomic, weak)id<IntentionOrderDelegate> orderDelegate;

@end
