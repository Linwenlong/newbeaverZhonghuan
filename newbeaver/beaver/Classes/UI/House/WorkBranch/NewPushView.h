//
//  NewPushView.h
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/23.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  主推房源新增View

#import <UIKit/UIKit.h>
@class NewPushView;

@protocol NewPushViewDelegate <NSObject>
- (void)NewPushViewDidClickAddButton:(NewPushView *)newPushView;

@end


@interface NewPushView : UIView

/** 标题1--套 */
@property (weak, nonatomic) IBOutlet UILabel *titleOne;
/** 标题2--房 */
@property (weak, nonatomic) IBOutlet UILabel *titleTwo;

/** 内容1--套的数据 */
@property (weak, nonatomic) IBOutlet UITextField *contentOne;
/** 内容1--房的数据 */
@property (weak, nonatomic) IBOutlet UITextField *contentTwo;

/** 新增按钮 */
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic, weak) id<NewPushViewDelegate> delegate;

+ (instancetype)initNewPushView;


@end
