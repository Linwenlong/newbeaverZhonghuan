//
//  GatherHouseWebViewController.m
//  beaver
//
//  Created by wangyuliang on 14-9-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseWebViewController.h"
#import "NJKWebViewProgressView.h"

@interface GatherHouseWebViewController ()
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@end

@implementation GatherHouseWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
