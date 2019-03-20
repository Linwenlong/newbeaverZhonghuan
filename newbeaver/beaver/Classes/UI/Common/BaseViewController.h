//
//  BaseViewController.h
//  qrcode
//
//  Created by 何 义 on 13-11-17.
//  Copyright (c) 2013年 crazyant. All rights reserved.
//

#import "EBStyle.h"

@class EBSearch;

@interface BaseViewController : UIViewController


- (void)beaverStatistics:(NSString *)modular;

- (BOOL)verifyText:(NSArray<UIView *> *)texts;

- (UIView *)verifyTextOfView:(NSArray<UIView *> *)texts;

- (void)post:(NSDictionary *)parm;

- (UIButton *)addLeftNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action;
- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action badge:(NSString *)reminder;
- (UIButton *)addRightNavigationBtnWithDynamicImage:(UIImage *)image checkedImage:checkedImage target:(id)target action:(SEL)action badge:(NSString *)reminder;

- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action;
- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action imageSize:(CGSize)size;

- (UIBarButtonItem *)addRightNavigationBtnWithTitle:(NSString *)title target:(id)target action:(SEL)action;
//- (UIBarButtonItem *)addRightNavigationBtnWithTitleIcon:(NSString *)title icon:(UIImage *)image target:(id)target action:(SEL)action;
- (void)setRightNavigationButtonBadge:(NSString *)badge atIndex:(NSInteger)idx;
- (void)setNavigationBackTitle:(NSString*)title;
- (void)setNavigationBackTitle;
- (BOOL)shouldPopOnBack;
- (EBSearch *)searchHelper;

@property (nonatomic, setter=setRightButtonsHidden:) BOOL rightButtonsHidden;

- (void)setRightButton:(NSInteger)buttonIndex hidden:(BOOL)hidden;

@property (nonatomic, strong) NSDictionary *userInfo;

//@property (nonatomic, strong) EBSearch *searchHelper;

//判断是否显示编辑
@property (nonatomic, assign) BOOL isShowEdit;

@end
