//
//  NewHouseWebViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "NewHouseWebViewController.h"
#import "NewFilingViewController.h"
#import "SnsViewController.h"
#import "EBController.h"
#import "EBAlert.h"
#import "EBPreferences.h"
#import "NJKWebViewProgressView.h"
#import "EBHouse.h"
#import "EBFilter.h"

@interface NewHouseWebViewController ()
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    ENewHouseWebViewType _viewType;
    NSURL *_currentURL;
    NSString *_projectId;
    
    BOOL _canPopOnBack;
}

@end

@implementation NewHouseWebViewController

- (void)loadView
{
    [super loadView];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_refresh"] target:self action:@selector(refresh:)];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_share"] target:self action:@selector(share:)];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_add"] target:self action:@selector(addNewFiling:)];
    [self setRightButton:0 hidden:YES];
    [self setRightButton:1 hidden:YES];
    [self setRightButton:2 hidden:YES];

    _webView = [[UIWebView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [self.view addSubview:_webView];
    _webView.delegate = self;
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
   
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_requestURL]]];
    if ([_requestURL rangeOfString:NSLocalizedString(@"new_house_detail", nil)].location != NSNotFound)
    {
        _canPopOnBack = YES;
    }
    else if ([_requestURL rangeOfString:NSLocalizedString(@"new_house_list", nil)].location != NSNotFound)
    {
        self.title = NSLocalizedString(@"new_house", nil);
    }
    else if ([_requestURL rangeOfString:NSLocalizedString(@"new_house_follow_detail", nil)].location != NSNotFound)
    {
        self.title = NSLocalizedString(@"follow_detail_title", nil);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPopOnBack
{
    if (_viewType == ENewHouseWebViewTypeDeatil)
    {
        if (_canPopOnBack)
        {
            return YES;
        }
        else
        {
            [_webView goBack];
            return NO;
        }
    }
    return YES;
}

#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    CGFloat top = [EBStyle failOffsetYInListView] + 64.0;
    NSString *errorText = NSLocalizedString(@"load_failure_hint", nil);
    [_progressView setProgress:1.0 animated:YES];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.innerHTML='<div style=font-size:14px;color:#5a5a5a;position:relative;top:%fpx;><center>%@</center></div>';", top, errorText]];
//    UILabel *failureLabel = (UILabel *)[self.view viewWithTag:99];
//    if (failureLabel == nil)
//    {
//        UILabel *failureLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, [EBStyle failOffsetYInListView] + 64.0, 290.0, 20.0)];
//        failureLabel.tag = 99;
//        failureLabel.textAlignment = NSTextAlignmentCenter;
//        failureLabel.textColor = [EBStyle blackTextColor];
//        failureLabel.font = [UIFont systemFontOfSize:14.0];
//        failureLabel.text = NSLocalizedString(@"load_failure_hint", nil);
//        [self.view addSubview:failureLabel];
//    }
//    [self.view bringSubviewToFront:failureLabel];
//    failureLabel.hidden = NO;
    [self setRightButton:0 hidden:NO];
    [self setRightButton:1 hidden:YES];
    [self setRightButton:2 hidden:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self setRightButton:0 hidden:YES];
    [self setRightButton:1 hidden:YES];
    [self setRightButton:2 hidden:YES];
    _currentURL = request.URL;
    NSArray *components = [_currentURL.absoluteString componentsSeparatedByString:@"?"];
    if (components && components.count > 0)
    {
        if ([NSLocalizedString(@"new_house_detail", nil) isEqualToString:components[0]])
        {
            _viewType = ENewHouseWebViewTypeDeatil;
            NSArray *parameter = [components[1] componentsSeparatedByString:@"&"];
            _projectId = [parameter[0] componentsSeparatedByString:@"="][1];
        }
        else if ([NSLocalizedString(@"new_house_list", nil) isEqualToString:components[0]])
        {
            _viewType = ENewHouseWebViewTypeList;
            self.title = NSLocalizedString(@"new_house", nil);
        }
        else if ([components[0] rangeOfString:NSLocalizedString(@"new_house_follow_detail", nil)].location != NSNotFound)
        {
            _viewType = ENewHouseWebViewTypeFollowDetail;
            self.title = NSLocalizedString(@"follow_detail_title", nil);;
        }
    }
//    UILabel *failureLabel = (UILabel *)[self.view viewWithTag:99];
//    if (failureLabel)
//    {
//        failureLabel.hidden = YES;
//        [self.view sendSubviewToBack:failureLabel];
//    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    switch (_viewType) {
        case ENewHouseWebViewTypeList:
            [self setRightButton:0 hidden:NO];
            [self setRightButton:1 hidden:YES];
            [self setRightButton:2 hidden:YES];
            break;
        case ENewHouseWebViewTypeDeatil:
            [self setRightButton:0 hidden:YES];
            [self setRightButton:1 hidden:NO];
            [self setRightButton:2 hidden:NO];
            self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            break;
        case ENewHouseWebViewTypeFollowDetail:
            [self setRightButton:0 hidden:NO];
            [self setRightButton:1 hidden:YES];
            [self setRightButton:2 hidden:YES];
            break;
        default:
            break;
    }
}

#pragma mark - UIButton Action

- (void)refresh:(id)sender
{
    [_webView loadRequest:[NSURLRequest requestWithURL:_currentURL]];
}

- (void)share:(id)sender
{
    EBHouse *house = [[EBHouse alloc] init];
    house.id = _projectId;
    house.title = self.title;
    SnsViewController *viewController = [[EBController sharedInstance] shareNewHouses:[NSArray arrayWithObjects:house, nil] handler:^(BOOL success, NSDictionary *info)
    {
        if (success)
        {
            [EBAlert alertSuccess:nil];
        }
        else
        {
            if ([info[@"desc"] rangeOfString:@"canceled"].location == NSNotFound)
            {
                [EBAlert alertError:NSLocalizedString(info[@"desc"], nil)];
            }
        }
    }];
    EBFilter *filter = [[EBFilter alloc] init];
    [filter parseFromHouse:house withDetail:NO];
    
    viewController.extraInfo = filter;
    [EBTrack event:EVENT_CLICK_NEW_HOUSE_SHARE];
}

- (void)addNewFiling:(id)sender
{
    NewFilingViewController *desViewController = [[NewFilingViewController alloc] init];
    desViewController.projectId = _projectId;
    desViewController.projectName = self.title;
    [self.navigationController pushViewController:desViewController animated:YES];
    [EBTrack event:EVENT_CLICK_NEW_HOUSE_SUBMIT];
}

@end
