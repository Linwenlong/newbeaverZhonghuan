//
//  SwipeableSectionHeader.h
//  Test1
//
//  Created by 林文龙 on 2018/11/29.
//  Copyright © 2018年 林文龙. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SwipeableSectionHeader : UIView

@property (nonatomic, strong) void (^btnClick)(UIButton *view);

@property (nonatomic, strong) void (^sectionTapClick)(UIView *view);
@property (nonatomic, strong) void (^longTapClick)(UIView *view);

- (instancetype)initWithFrame:(CGRect)frame section:(NSInteger)section imgRatate:(BOOL)ratate title:(NSString *)titleName;

@end
