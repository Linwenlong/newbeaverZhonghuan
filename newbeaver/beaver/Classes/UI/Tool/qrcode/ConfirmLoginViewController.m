//
//  QRScannerViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ConfirmLoginViewController.h"
#import "EBViewFactory.h"
#import "RTLabel.h"
#import "EBPreferences.h"
#import "EBAlert.h"
#import "EBHttpClient.h"

@implementation ConfirmLoginViewController

- (void)loadView
{
    [super loadView];

    self.title = NSLocalizedString(@"scan_qrcode", nil);

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [self.view addSubview:scrollView];
    scrollView.alwaysBounceVertical = YES;

    CGFloat yOffset = 25;

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 212.5)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = [UIImage imageNamed:@"erp_login"];
    [scrollView addSubview:imageView];

    yOffset += imageView.frame.size.height;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 20)];
    label.textColor = [EBStyle blackTextColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = NSLocalizedString(@"confirm_login_erp", nil);
    label.textAlignment = NSTextAlignmentCenter;

    [scrollView addSubview:label];

    yOffset += label.frame.size.height + 30;

    UIButton *confirmBtn = [EBViewFactory blueButtonWithFrame:CGRectMake(20, yOffset, 280, 36)
                                                        title:NSLocalizedString(@"confirm_login", nil) target:self
                                                       action:@selector(confirmLogin:)];
    [scrollView addSubview:confirmBtn];

    yOffset += confirmBtn.frame.size.height + 20;
    UIButton *cancelBtn = [EBViewFactory redButtonWithFrame:CGRectMake(20, yOffset, 280, 36)
                                                        title:NSLocalizedString(@"cancel", nil) target:self
                                                       action:@selector(cancelLogin:)];
    [scrollView addSubview:cancelBtn];

    yOffset += cancelBtn.frame.size.height + 20;

//    RTLabel *codeLabel = [[RTLabel alloc] initWithFrame:CGRectMake(10, yOffset, 300, 100)];
//    codeLabel.textAlignment = RTTextAlignmentCenter;
//    codeLabel.textColor = [EBStyle blackTextColor];
//    codeLabel.font = [UIFont systemFontOfSize:18.0];
//    codeLabel.text = _loginToken;

//    [scrollView addSubview:codeLabel];
}

- (void)confirmLogin:(UIButton *)btn
{
    EBPreferences *pref = [EBPreferences sharedInstance];

    [EBAlert showLoading:NSLocalizedString(@"status_processing", nil)];
    [[EBHttpClient sharedInstance] codeRequest:@{@"what":@2, @"code":self.loginToken,
            @"account":pref.userAccount, @"password":pref.userPassword} what:^(BOOL success, id result)
    {
        [EBAlert hideLoading];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)cancelLogin:(UIButton *)btn
{
    [EBAlert showLoading:NSLocalizedString(@"status_processing", nil)];
    [[EBHttpClient sharedInstance] codeRequest:@{@"what":@3, @"code":self.loginToken} what:^(BOOL success, id result)
    {
        [EBAlert hideLoading];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

@end
