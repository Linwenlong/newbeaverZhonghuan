//
//  HouseHiddenMessageView.h
//  beaver
//
//  Created by 林文龙 on 2018/7/24.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseHiddenMessageView : UIView

@property (nonatomic, strong) void(^imageClick)();

@property (nonatomic, strong) void(^modelClick)(UIButton *btn,UITableView *listTableView,CGFloat list_h);//选择模版

@property (nonatomic, strong) void(^submitClick)(UIButton *btn,UIButton *tempateBtn,UITextView *contentView);//提交按钮

- (instancetype)initWithFrame:(CGRect)frame withTempate:(NSArray *)temPate;

@end
