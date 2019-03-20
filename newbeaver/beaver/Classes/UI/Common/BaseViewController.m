                                                                                                                //
//  BaseViewController.m
//  qrcode
//
//  Created by 何 义 on 13-11-17.
//  Copyright (c) 2013年 crazyant. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImage+Alpha.h"
#import "XMPPElement.h"
#import "EBSearch.h"
#import "EBController.h"
#import "EBCompatibility.h"
#import "CustomBadge.h"
#import "UIImage+Resize.h"
#import "SDImageCache.h"

@interface BaseViewController ()
{
    NSMutableArray *_leftButtons;
    NSMutableArray *_rightButtons;
}

@end

@implementation BaseViewController
- (void)beaverStatistics:(NSString *)modular{
    NSString *urlStr = @"http://218.65.86.92:8003/Customer/addCount";
    NSDictionary *dic = @{
                            @"user_id":[EBPreferences sharedInstance].userAccount,
                            @"city":[EBPreferences sharedInstance].city,
                            @"platform":@"iOS",
                            @"modular":modular,
                            @"type":@"beaver",
                            @"c_v":@"2.6",
                            @"c_p":@"android",
                            @"c_u":@"ad07c5df-9473-38b3-89a5-e6039c963237",
                            @"c_s":@"5c5356d8"
                            };
    NSLog(@"statisticsDic=%@",dic);
    [HttpTool get:urlStr parameters:dic success:^(id responseObject) {
        NSLog(@"responseObject=%@",responseObject);
        NSLog(@"modular - %@",modular);
    } failure:^(NSError *error) {
        NSLog(@"error=%@",error);
            
    }];
    
}


/**
 *  验证文本
 *
 *  @param texts 验证的数组
 *
 *  @return bool
 */
- (BOOL)verifyText:(NSArray<UIView *> *)texts{
    for (UIView *view in texts) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            if (field.text.length == 0) return NO;
        }else if ([view isKindOfClass:[UITextView class]]){
            UITextView *textView = (UITextView *)view;
            if (textView.text.length == 0) return NO;
        }else if ([view isKindOfClass:[UIButton class]]){
            UIButton *button = (UIButton *)view;
            if (button.titleLabel.text.length == 0) return NO;
        }else if ([view isKindOfClass:[UILabel class]]){
            UILabel *lable = (UILabel *)view;
            if (lable.text.length == 0) return NO;
        }
    }
    return YES;
}

/**
 *  验证文本
 *
 *  @param texts 验证的数组
 *
 *  @return 对应的view
 */
- (UIView *)verifyTextOfView:(NSArray<UIView *> *)texts{
    for (UIView *view in texts) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            if (field.text.length == 0) return view;
        }else if ([view isKindOfClass:[UITextView class]]){
            UITextView *textView = (UITextView *)view;
            if (textView.text.length == 0) return view;
        }else if ([view isKindOfClass:[UIButton class]]){
            UIButton *button = (UIButton *)view;
            if (button.titleLabel.text.length == 0) return view;
        }else if ([view isKindOfClass:[UILabel class]]){
            UILabel *lable = (UILabel *)view;
            if (lable.text.length == 0) return view;
        }
    }
    return nil;
}


- (void)post:(NSDictionary *)parm{
    
    NSLog(@"parm = %@",parm);
    NSString *urlStr = @"jobsummary/jobSummaryOperated";//新增工作总结
    [EBAlert showLoading:@"提交中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:parm success:^(id responseObject) {
        [EBAlert hideLoading];
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"currentDic=%@",currentDic);
        if ([currentDic[@"code"] integerValue] != 0) {
            [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            return ;
        }else{
            [EBAlert alertSuccess:@"提交成功" length:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
    }];
}

- (void)loadView
{
    [super loadView];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];

   [self setNavigationBackTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *backImage = [[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *buttonback =[[UIBarButtonItem alloc]initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = buttonback;
}

- (UIButton *)addLeftNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    btn.adjustsImageWhenHighlighted = NO;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButtonItems:btn];
    return btn;
}

- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action badge:(NSString *)reminder  imageSize:(CGSize)size{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    btn.adjustsImageWhenHighlighted = NO;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    
    if (reminder)
    {
        CustomBadge *badge = [CustomBadge customBadgeWithString:reminder
                                                withStringColor:[UIColor whiteColor]
                                                 withInsetColor:[EBStyle redTextColor]
                                                 withBadgeFrame:NO
                                            withBadgeFrameColor:[UIColor whiteColor]
                                                      withScale:10.0/13.5
                                                    withShining:NO];
        CGRect badgeFrame = badge.frame;
        CGRect btnFrame = btn.bounds;
        badge.tag = 87;
        badge.frame = CGRectOffset(badgeFrame, btnFrame.size.width - badgeFrame.size.width + 5, -5);
        [btn addSubview:badge];
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    if (_rightButtons == nil)
    {
        _rightButtons = [[NSMutableArray alloc] init];
    }
    
    //    NSMutableArray *rightButtons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    if (_rightButtons.count == 0 && [EBCompatibility isIOS7Higher])
    {
        UIBarButtonItem *itemFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemFix.width = -6;
        //        [rightButtons addObject:itemFix];
        [_rightButtons addObject:@{@"button":itemFix, @"hidden":@0}];
    }
    [_rightButtons addObject:@{@"button":itemBtn, @"hidden":@0}];
    [self setRightBarButtonItems];
    //    [rightButtons addObject:itemBtn];
    //    [self.navigationItem setRightBarButtonItems:_rightButtons animated:YES];
    
    return btn;

}

- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    return [self addRightNavigationBtnWithImage:image target:target action:action badge:nil];
}
- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action imageSize:(CGSize)size
{
    return [self addRightNavigationBtnWithImage:image target:target action:action badge:nil imageSize:size];
}


- (UIButton *)addRightNavigationBtnWithImage:(UIImage *)image target:(id)target action:(SEL)action badge:(NSString *)reminder
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];

    btn.adjustsImageWhenHighlighted = NO;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];

    if (reminder)
    {
        CustomBadge *badge = [CustomBadge customBadgeWithString:reminder
                                                withStringColor:[UIColor whiteColor]
                                                 withInsetColor:[EBStyle redTextColor]
                                                 withBadgeFrame:NO
                                            withBadgeFrameColor:[UIColor whiteColor]
                                                      withScale:10.0/13.5
                                                    withShining:NO];
        CGRect badgeFrame = badge.frame;
        CGRect btnFrame = btn.bounds;
        badge.tag = 87;
        badge.frame = CGRectOffset(badgeFrame, btnFrame.size.width - badgeFrame.size.width + 5, -5);
        [btn addSubview:badge];
    }

    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];

    if (_rightButtons == nil)
    {
        _rightButtons = [[NSMutableArray alloc] init];
    }

//    NSMutableArray *rightButtons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    if (_rightButtons.count == 0 && [EBCompatibility isIOS7Higher])
    {
        UIBarButtonItem *itemFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemFix.width = -12;
//        [rightButtons addObject:itemFix];
        [_rightButtons addObject:@{@"button":itemFix, @"hidden":@0}];
    }
    [_rightButtons addObject:@{@"button":itemBtn, @"hidden":@0}];
    [self setRightBarButtonItems];
//    [rightButtons addObject:itemBtn];
//    [self.navigationItem setRightBarButtonItems:_rightButtons animated:YES];

    return btn;
}

- (UIButton *)addRightNavigationBtnWithDynamicImage:(UIImage *)image checkedImage:checkedImage target:(id)target action:(SEL)action badge:(NSString *)reminder
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    btn.adjustsImageWhenHighlighted = NO;
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:checkedImage forState:UIControlStateSelected];
    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    [btn setImage:[checkedImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    if (reminder)
    {
        CustomBadge *badge = [CustomBadge customBadgeWithString:reminder
                                                withStringColor:[UIColor whiteColor]
                                                 withInsetColor:[EBStyle redTextColor]
                                                 withBadgeFrame:NO
                                            withBadgeFrameColor:[UIColor whiteColor]
                                                      withScale:10.0/13.5
                                                    withShining:NO];
        CGRect badgeFrame = badge.frame;
        CGRect btnFrame = btn.bounds;
        badge.tag = 87;
        badge.frame = CGRectOffset(badgeFrame, btnFrame.size.width - badgeFrame.size.width + 5, -5);
        [btn addSubview:badge];
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    if (_rightButtons == nil)
    {
        _rightButtons = [[NSMutableArray alloc] init];
    }
//    [_rightButtons addObject:itemBtn];
    
//    NSMutableArray *rightButtons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    if (_rightButtons.count == 0 && [EBCompatibility isIOS7Higher])
    {
        UIBarButtonItem *itemFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemFix.width = -12;
        [_rightButtons addObject:@{@"button":itemFix, @"hidden":@0}];
//        [_rightButtons addObject:itemFix];
    }
    [_rightButtons addObject:@{@"button":itemBtn, @"hidden":@0}];
//    [_rightButtons addObject:itemBtn];
//    [self.navigationItem setRightBarButtonItems:_rightButtons animated:YES];
    [self setRightBarButtonItems];
    
    return btn;
}

- (UIBarButtonItem *)addRightNavigationBtnWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:UIBarButtonItemStylePlain target:target action:action];
    [item setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = item;

    return item;
}

//- (UIBarButtonItem *)addRightNavigationBtnWithTitleIcon:(NSString *)title icon:(UIImage *)image target:(id)target action:(SEL)action
//{
////    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@""
////                                                             style:UIBarButtonItemStylePlain target:target action:action];
////    [item setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
////    [item setImage:image];
//    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
//    btn.enabled = YES;
//    UIView *view = [[UIView alloc] initWithFrame:btn.bounds];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12.5, 25, 25)];
//    imageView.image = image;
//    [view addSubview:imageView];
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, 40, 30)];
//    titleLabel.textAlignment = NSTextAlignmentRight;
//    titleLabel.text = title;
//    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
//    titleLabel.textColor = [EBStyle grayTextColor];
//    [view addSubview:titleLabel];
//    [btn addSubview:view];
//    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    itemBtn.enabled = YES;
//    [itemBtn setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//    [btn addTarget:target action:action forControlEvents:UIControlStateNormal];
//    
//    self.navigationItem.rightBarButtonItem = itemBtn;
//    
//    return itemBtn;
//}

- (void)setNavigationBackTitle:(NSString*)title
{
    UIBarButtonItem* back = [[UIBarButtonItem alloc]
            initWithTitle:title
                    style:UIBarButtonItemStyleBordered
                   target:nil
                   action:nil];

    self.navigationItem.backBarButtonItem = back;
}

- (void)setRightNavigationButtonBadge:(NSString *)badge atIndex:(NSInteger)buttonIndex
{
    NSMutableArray *nowButtons = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    if (buttonIndex < nowButtons.count)
    {
        NSInteger idx = [EBCompatibility isIOS7Higher] ? 1 : 0 + buttonIndex;
        UIButton *btn = (UIButton *)[nowButtons[idx] customView];

        CustomBadge *badgeView = (CustomBadge *)[btn viewWithTag:87];
        if (badgeView == nil && badge)
        {
            badgeView = [CustomBadge customBadgeWithString:badge
                                                    withStringColor:[UIColor whiteColor]
                                                     withInsetColor:[EBStyle redTextColor]
                                                     withBadgeFrame:NO
                                                withBadgeFrameColor:[UIColor whiteColor]
                                                          withScale:10.0/13.5
                                                        withShining:NO];
            badgeView.tag = 87;
            [btn addSubview:badgeView];
        }

        if (badge)
        {
            [badgeView autoBadgeSizeWithString:badge];
            CGRect badgeFrame = badgeView.frame;
            CGRect btnFrame = btn.bounds;
            badgeView.frame = CGRectOffset(badgeFrame, btnFrame.size.width - badgeFrame.size.width + 5, -5);
        }
        else if (!badge && badgeView)
        {
            badgeView.hidden = YES;
        }
    }
}

- (void)setNavigationBackTitle
{
    [self setNavigationBackTitle:@" "];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[SDImageCache sharedImageCache] clearMemory];
    NSLog(@"MemoryWarning image cache clear...");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [EBTrack beginLogPageView:[NSString stringWithFormat:@"%@", [self class]]];

    if (self.searchHelper.displayController.isActive)
    {
        [[EBController sharedInstance] hideTabBar];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [EBAlert hideLoading];//lwl
    
    [EBTrack endLogPageView:[NSString stringWithFormat:@"%@", [self class]]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//基类注销通知
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRightButtonsHidden:(BOOL)rightButtonsHidden
{
    NSArray *rightButtonItems = self.navigationItem.rightBarButtonItems;

    for (UIBarButtonItem *item in rightButtonItems)
    {
        item.customView.hidden = rightButtonsHidden;
    }
}

- (void)setRightButton:(NSInteger)buttonIndex hidden:(BOOL)hidden
{
    if (buttonIndex < _rightButtons.count)
    {
        NSInteger idx = [EBCompatibility isIOS7Higher] ? 1 : 0;

        NSDictionary *temp = _rightButtons[buttonIndex + idx];
        if (temp)
        {
            [_rightButtons replaceObjectAtIndex:buttonIndex + idx withObject:@{@"button":temp[@"button"], @"hidden":hidden ? @1 : @0}];
        }
//        if (hidden)
//        {
//            if ((buttonIndex + idx < nowButtons.count) && (nowButtons[buttonIndex + idx] == _rightButtons[buttonIndex]))
//            {
//                [nowButtons removeObjectAtIndex:(buttonIndex + idx)];
//            }
//        }
//        else
//        {
//            if (buttonIndex + idx == nowButtons.count)
//            {
//                [nowButtons addObject:_rightButtons[buttonIndex]];
//            }
//            else if ((buttonIndex + idx < nowButtons.count) && (nowButtons[buttonIndex + idx] != _rightButtons[buttonIndex]))
//            {
//                [nowButtons insertObject:_rightButtons[buttonIndex] atIndex:(buttonIndex + idx)];
//            }
//        }

        [self setRightBarButtonItems];
    }
}

- (void)setRightBarButtonItems
{
    [self.navigationItem setRightBarButtonItems:nil];
    NSMutableArray *nowButtons = [[NSMutableArray alloc] init];
    [_rightButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *temp = obj;
        if (![temp[@"hidden"] boolValue]) {
            [nowButtons addObject:temp[@"button"]];
        }
    }];
    [self.navigationItem setRightBarButtonItems:nowButtons animated:NO];
}

- (void)setLeftBarButtonItems:(UIButton *)btn
{
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    if (_leftButtons == nil) {
        _leftButtons = [[NSMutableArray alloc] init];
    }
    
    if (_leftButtons.count == 0 && [EBCompatibility isIOS7Higher]) {
        UIBarButtonItem *itemFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemFix.width = -12;
        //        [rightButtons addObject:itemFix];
        [_leftButtons addObject:@{@"button":itemFix, @"hidden":@0}];
    }
    [_leftButtons addObject:@{@"button":itemBtn, @"hidden":@0}];
    
    [self.navigationItem setLeftBarButtonItems:nil];
    NSMutableArray *nowButtons = [[NSMutableArray alloc] init];
    [_leftButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *temp = obj;
        if (![temp[@"hidden"] boolValue]) {
            [nowButtons addObject:temp[@"button"]];
        }
    }];
    [self.navigationItem setLeftBarButtonItems:nowButtons animated:NO];
}

- (EBSearch *)searchHelper
{
    return nil;
}

- (BOOL)shouldPopOnBack
{
   return YES;
}

- (void)backAction:(id)sender
{
    
    if (_isShowEdit) {
        [EBAlert confirmWithTitle:@"温馨提示" message:@"是否放弃编辑?"
                              yes:@"确定" action:^{
            [self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                                      
                                  }];
        }];
    }else{
        NSLog(@"%@",[self class]);
        if ([NSStringFromClass([self class]) isEqualToString:@"ZHDCWebViewController"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
        
            }];
        }
    }
}

#pragma mark - rotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
