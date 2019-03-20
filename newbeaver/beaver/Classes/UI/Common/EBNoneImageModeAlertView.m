//
// Created by 何 义 on 14-5-12.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBNoneImageModeAlertView.h"
#import "EBStyle.h"
#import "UIImage+ImageWithColor.h"
#import "EBPreferences.h"


@implementation EBNoneImageModeAlertView

- (id)init
{
    self = [super init];

    if (self)
    {
       self.buttonTitles = nil;

       [self buildContainerView];
    }

    return self;
}

- (void)buildContainerView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 260, 64)];
    title.numberOfLines = 0;
    title.font = [UIFont boldSystemFontOfSize:14.0];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"prompt_none_image_mode", nil);
    [containerView addSubview:title];

    UIView *line = [self lineWithFrame:CGRectMake(0, title.frame.origin.y +
            title.frame.size.height, 280, 0.5)];
    [containerView addSubview:line];

    UIButton *btnYes = [self buttonWithFrame:CGRectMake(0, line.frame.origin.y +
            line.frame.size.height, 280, 44) title:NSLocalizedString(@"prompt_none_image_mode_yes", nil) target:self action:@selector(useNoneImageMode:)];
    [containerView addSubview:btnYes];

    line = [self lineWithFrame:CGRectMake(0, btnYes.frame.origin.y + btnYes.frame.size.height, 280, 0.5)];
    [containerView addSubview:line];

    UIButton *btnNO = [self buttonWithFrame:CGRectMake(0, line.frame.origin.y + line.frame.size.height, 280, 44)
                                      title:NSLocalizedString(@"prompt_none_image_mode_no", nil) target:self action:@selector(doNotUseNoneImageMode:)];
    [containerView addSubview:btnNO];

    line = [self lineWithFrame:CGRectMake(0, btnNO.frame.origin.y +
            btnNO.frame.size.height, 280, 0.5)];
    [containerView addSubview:line];

    UIButton *btnRemember = [[UIButton alloc] initWithFrame:CGRectMake(10, btnNO.frame.origin.y + btnNO.frame.size.height, 270, 44)];
    btnRemember.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btnRemember.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    btnRemember.adjustsImageWhenHighlighted = NO;
    btnRemember.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnRemember.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btnRemember setTitleColor:[EBStyle blackTextColor] forState:UIControlStateNormal];
    [btnRemember setTitle:NSLocalizedString(@"prompt_none_image_mode_remember_choice", nil) forState:UIControlStateNormal];

    [btnRemember setImage:[UIImage imageNamed:@"btn_uncheck"] forState:UIControlStateNormal];
    [btnRemember setImage:[UIImage imageNamed:@"btn_checked"] forState:UIControlStateSelected];
    btnRemember.selected = [EBPreferences sharedInstance].rememberNoneImageChoice;
    [btnRemember addTarget:self action:@selector(rememberChoice:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:btnRemember];

    [self setContainerView:containerView];
}

- (void)rememberChoice:(UIButton *)btn
{
    btn.selected = !btn.selected;
    EBPreferences *pref = [EBPreferences sharedInstance];
    pref.rememberNoneImageChoice = btn.selected;
    [pref writePreferences];
}

- (void)useNoneImageMode:(UIButton *)btn
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    pref.allowImageDownloadViaWan = NO;
    [pref writePreferences];
    [self close];

    self.completion();
}

- (void)doNotUseNoneImageMode:(UIButton *)btn
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    pref.allowImageDownloadViaWan = YES;
    [pref writePreferences];
    [self close];

    self.completion();
}

- (UIView *)lineWithFrame:(CGRect)rect
{
    UIView *line = [[UIView alloc] initWithFrame:rect];
    line.backgroundColor = [EBStyle grayClickLineColor];

    return line;
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];

    [btn setBackgroundImage:[UIImage imageWithColor:[EBStyle grayClickLineColor]] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];

    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return btn;
}


@end