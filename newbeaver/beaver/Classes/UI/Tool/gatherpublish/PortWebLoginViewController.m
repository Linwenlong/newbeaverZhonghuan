//
//  PortWebLoginViewController.m
//  beaver
//
//  Created by wangyuliang on 14-12-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PortWebLoginViewController.h"
#import "NJKWebViewProgressView.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "PublishPortViewController.h"

@interface PortWebLoginViewController ()
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    NSString *_loginName;
}

@end

@implementation PortWebLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_isEdit) {
//        [self addLeftNavigationBtnWithImage:[UIImage imageNamed:@"icon_note_close"] target:self action:@selector(backAction)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    }
    else
    {
        [self addLeftNavigationBtnWithImage:[UIImage imageNamed:@"icon_back"] target:self action:@selector(backAction)];
    }
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_refresh"] target:self action:@selector(refresh:)];
    
    _webView = [[UIWebView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [self.view addSubview:_webView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self loadRequest];
}

- (BOOL)shouldPopOnBack
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

-(void)loadRequest
{
    [_webView loadRequest:self.request];
}

#pragma mark - webviewdelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSString *loginName = [webView stringByEvaluatingJavaScriptFromString:@"$(\"#pptusername\").val().trim();"];
    if (_port[@"inject"]) {
        [_webView stringByEvaluatingJavaScriptFromString:_port[@"inject"]];
    }
    NSString *urlStr = [webView.request.URL absoluteString];
    if ([urlStr hasPrefix:_port[@"callback"]]) {
        NSDictionary *params = nil;
        if (_isEdit) {
            params = @{@"id": _port[@"id"], @"port_id": _port[@"port_id"], @"account": _loginName, @"password": urlStr, @"checkcode": @""};
        }
        else
        {
            params = @{@"port_id": _port[@"id"], @"account": _loginName, @"password": urlStr, @"checkcode": @""};
        }
        [EBAlert showLoading:nil];
        [[EBHttpClient sharedInstance] gatherPublishRequest:params portEditAuth:^(BOOL success, id result) {
            [EBAlert hideLoading];
            if (success) {
                if (_isEdit) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [EBAlert alertSuccess:@"修改成功"];
                    }];
                }
                else
                {
                    [EBAlert alertSuccess:NSLocalizedString(@"publish_port_auth_success", nil)];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
                        NSArray *viewCtrlArray = self.navigationController.viewControllers;
                        UIViewController *viewCtrl = nil;
                        NSInteger i = viewCtrlArray.count - 1;
                        for (; i >= 0; i --) {
                            viewCtrl = viewCtrlArray[i];
                            if ([viewCtrl isKindOfClass:[PublishPortViewController class]]) {
                                [self.navigationController popToViewController:viewCtrl animated:YES];
                                return;
                            }
                        }
                        if (i < 0) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    });
                }
            }
            else
            {
                [self loadRequest];
//                [EBAlert alertError:@"登录失败"];
            }
        }];
    }
    else
    {
        _loginName = [webView stringByEvaluatingJavaScriptFromString:_port[@"scripts"]];
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - UIButton Action

- (void)refresh:(id)sender
{
    [_webView loadRequest:self.request];
}

//返回按钮
- (void)backAction
{
    if (_isEdit) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
