//
//  PublishPortLoginViewController.m
//  beaver
//
//  Created by LiuLian on 8/29/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "PublishPortLoginViewController.h"
#import "EBElementStyle.h"
#import "EBInputElement.h"
#import "EBInputView.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "FSImageLoader.h"
#import "EBController.h"

@interface PublishPortLoginViewController () <UIScrollViewDelegate, EBInputViewDelegate>
{
    UIScrollView *_scrollView;
    
    EBInputView *_nameView;
    EBInputView *_pwdView;
    EBInputView *_codeView;
    UIImageView *_codeImageView;
    NSMutableArray *_inputViews;
    EBElementView *_currentElementView;
    
    UIToolbar *_toolbar;
    UIBarButtonItem *_previousBarButton;
    UIBarButtonItem *_nextBarButton;
    
    BOOL _needVerifyCode;
    NSString *_codeUrl;
    
    NSTimer *_resendTimer;
    NSInteger _resendCount;
    NSString *_checkId;
    
    EBPortOperateType _processType;
    BOOL _modifyMark;
}
@end

@implementation PublishPortLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = _isEdit ? _port[@"port_name"] : _port[@"name"];
    [self addRightNavigationBtnWithTitle:@"登录" target:self action:@selector(login)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [self.view addSubview:_scrollView];
    _scrollView.delegate = self;
    _scrollView.alwaysBounceVertical = YES;
    [self initToolbar];
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_nameView onSelect:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_resendTimer != nil)
    {
        [_resendTimer invalidate];
        _resendTimer = nil;
    }
}

- (void)initViews
{
//    for (UIView *view in _scrollView.subviews)
//    {
//        [view removeFromSuperview];
//    }
    _inputViews = [NSMutableArray new];
    CGFloat dx = 15, dy = 10;
    
    EBElementStyle *style = [EBElementStyle defaultStyle];
    EBInputElement *nameInputElement = [EBInputElement new];
    nameInputElement.prefix = @"用户名";
    _nameView = [[EBInputView alloc] initWithStyle:CGRectMake(dx, dy, self.view.width-dx, 44.0) element:nameInputElement style:style];
    _nameView.delegate = self;
    [_nameView drawView];
    _nameView.toolbar = _toolbar;
    [_scrollView addSubview:_nameView];
    [_inputViews addObject:_nameView];
    if (_isEdit) {
        [_nameView setValueOfView:_port[@"account"]];
    }
//    [_nameView showInView:_scrollView];
    
    EBInputElement *pwdInputElement = [EBInputElement new];
    pwdInputElement.prefix = @"密码";
    pwdInputElement.inputType = EBElementInputTypePassword;
    _pwdView = [[EBInputView alloc] initWithStyle:CGRectMake(dx, _nameView.bottom, self.view.width-dx, 44.0) element:pwdInputElement style:style];
    _pwdView.delegate = self;
    [_pwdView drawView];
    _pwdView.toolbar = _toolbar;
    [_scrollView addSubview:_pwdView];
    [_inputViews addObject:_pwdView];
    if (_isEdit) {
        [_pwdView setValueOfView:_port[@"password"]];
    }
    
    EBInputElement *codeInputElement = [EBInputElement new];
    codeInputElement.prefix = @"验证码";
    _codeView = [[EBInputView alloc] initWithStyle:CGRectMake(dx, _pwdView.bottom, self.view.width-dx, 44.0) element:codeInputElement style:style];
    _codeView.delegate = self;
    [_codeView drawView];
    _codeView.toolbar = _toolbar;
    [_scrollView addSubview:_codeView];
    [_inputViews addObject:_codeView];
//    if (_needVerifyCode)
//    {
//        _codeView.hidden = NO;
//        [[FSImageLoader sharedInstance] loadImageForURL:[NSURL URLWithString:_codeUrl] image:^(UIImage *image, NSError *error) {
//            if (!error) {
//                codeInputElement.suffixImg = image;
//                [_codeView drawView];
//                image = nil;
//                if (_codeView.sufImageView)
//                {
//                    UITapGestureRecognizer *codeTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(codeRefresh:)];
//                    [_codeView.sufImageView addGestureRecognizer:codeTapGes];
//                }
//            }
//        }];
//    }
//    else
//    {
//        _codeView.hidden = YES;
//    }
    _codeView.hidden = YES;
    [self codeHiddenChanged];
}

- (void)initToolbar
{
    _toolbar = [[UIToolbar alloc] init];
    _toolbar.frame = CGRectMake(0, 0, self.view.width, 44);
    // set style
    [_toolbar setBarStyle:UIBarStyleDefault];
    
    _previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_previous", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    _nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_next", nil)
                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[_previousBarButton, _nextBarButton, flexBarButton, doneBarButton];
    
    _toolbar.items = barButtonItems;
}

#pragma mark - item action
- (void)cancel
{
    if (_modifyMark)
    {
        [EBAlert confirmWithTitle:nil message:@"您确定要放弃添加么？" yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self stopTimer];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }
    else
    {
        [self stopTimer];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)login
{
    [_currentElementView deSelect:nil];
    NSString *name = [_nameView valueOfView];
    NSString *pwd = [_pwdView valueOfView];
    NSString *code = @"";
    if (!name || [name isEqualToString:@""]) {
        [EBAlert alertError:@"请输入用户名"];
        return;
    }
    if (!pwd || [pwd isEqualToString:@""]) {
        [EBAlert alertError:@"请输入密码"];
        return;
    }
    if (!_codeView.hidden) {
        code = [_codeView valueOfView];
        if ([code isEqualToString:@""]) {
            [EBAlert alertError:@"请输入验证码"];
            return;
        }
    }
    NSDictionary *params = nil;
    if (_isEdit) {
        params = @{@"id": _port[@"id"], @"port_id": _port[@"port_id"], @"account": name, @"password": pwd, @"checkcode": code};
    } else {
        params = @{@"port_id": _port[@"id"], @"account": name, @"password": pwd, @"checkcode": code};
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [EBAlert showLoading:nil];
    _processType = EBPortOperateLogin;
    [[EBHttpClient sharedInstance] gatherPublishRequest:params portEditAuth:^(BOOL success, id result) {
        if (success)
        {
            _checkId = _isEdit ? _port[@"id"] : result[@"id"];
            if (result[@"status"])
            {
               [self handleLoginResult:result[@"status"]];
            }
            else
            {
                [EBAlert showLoading:nil];

                if (_resendTimer && _resendTimer.isValid)
                {
                    [_resendTimer invalidate];
                }
                _resendCount = 10;
                _resendTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getLoginState) userInfo:nil repeats:YES];
            }
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}

- (void)getLoginState
{
    _resendCount--;
    if (_resendCount < 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self stopTimer];
        [EBAlert alertError:@"登录超时，请重新登录"];
    }
    else
    {
        __weak PublishPortLoginViewController *weakSelf = self;
        NSDictionary *params = @{@"id": _checkId};
        [[EBHttpClient sharedInstance] gatherPublishRequest:params portAuthStatus:^(BOOL success, id result) {
            if (success)
            {
                [weakSelf handleLoginResult:result];
            }
            else
            {
                [weakSelf stopTimer];
            }
        }];
    }
}

- (void)doneButtonIsClicked:(id)sender
{
    [_currentElementView deSelect:nil];
}

- (void)nextButtonIsClicked:(id)sender
{
    NSInteger tagIndex = [_inputViews indexOfObject:_currentElementView];
    EBElementView *textField =  [_inputViews objectAtIndex:++tagIndex];
    
    [textField onSelect:nil];
}

- (void)previousButtonIsClicked:(id)sender
{
    NSInteger tagIndex = [_inputViews indexOfObject:_currentElementView];
    EBElementView *textField =  [_inputViews objectAtIndex:--tagIndex];
    
    [textField onSelect:nil];
}

- (void)setBarButtonNeedsDisplayAtIndex:(NSInteger)index
{
    if (index == 0) {
        _previousBarButton.enabled = NO;
        _nextBarButton.enabled = YES;
    } else if (index == _inputViews.count-1) {
        _previousBarButton.enabled = YES;
        _nextBarButton.enabled = NO;
    } else {
        _previousBarButton.enabled = YES;
        _nextBarButton.enabled = YES;
    }
}

- (void)handleLoginResult:(NSDictionary *)result
{
    [EBAlert showLoading:nil];

    NSString *state = result[@"state"];
    NSLog(@"state:%@", state);
    if ([state isEqualToString:@"1"])
    {
        if (_isEdit) {
            [self stopTimer];
            [EBAlert alertSuccess:@"修改成功"];
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.editSuccess) {
                    NSMutableDictionary *port = [NSMutableDictionary dictionaryWithDictionary:_port];
                    port[@"account"] = [_nameView valueOfView];
                    port[@"password"] = [_pwdView valueOfView];
                    self.editSuccess(port);
                }
            }];
            return;
        }
//                    if (_processType == EBPortOperateLogin)
//                    {
        [self stopTimer];
        [EBAlert alertSuccess:NSLocalizedString(@"publish_port_auth_success", nil) length:1.0 allowUserInteraction:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
//            [[EBController sharedInstance].currentNavigationController popViewControllerAnimated:NO];
            [self dismissViewControllerAnimated:YES completion:^{
                [[EBController sharedInstance].currentNavigationController popViewControllerAnimated:NO];
            }];
        });
//                    }
    }
    else if ([state isEqualToString:@"3"])
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self stopTimer];
        _needVerifyCode = YES;
        _codeUrl = result[@"url"];
//                    [self initViews];
        [self showCode];
    }
    else if ([state isEqualToString:@"5"])
    {
        //
    }
    else if ([state isEqualToString:@"-3"] || [state isEqualToString:@"-2"] || [state isEqualToString:@"-1"])
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self stopTimer];
        [EBAlert alertError:result[@"desc"]];
    }
}

- (void)stopTimer
{
    [EBAlert hideLoading];
    if (_resendTimer && _resendTimer.isValid)
    {
        [_resendTimer invalidate];
        _resendTimer = nil;
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_nameView deSelect:nil];
    [_pwdView deSelect:nil];
    if (_codeView) {
        [_codeView deSelect:nil];
    }
}

#pragma mark - authcode load
-(void)codeRefresh:(UITapGestureRecognizer*)sender
{
    [EBAlert showLoading:nil];
    _processType = EBPortOperateRefresh;
    NSDictionary *params = @{@"id": _checkId};
    [[EBHttpClient sharedInstance] gatherPublishRequest:params portRefreshCaptcha:^(BOOL success, id result) {
        if (success)
        {
            if (result[@"state"])
            {
                [self handleLoginResult:result];
            }
            else
            {
                [EBAlert showLoading:nil];

                if (_resendTimer && _resendTimer.isValid)
                {
                    [_resendTimer invalidate];
                }
                _resendCount = 10;
                _resendTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getLoginState) userInfo:nil repeats:YES];
            }
        }
    }];
}

- (void)showCode
{
    if (_needVerifyCode) {
        [[FSImageLoader sharedInstance] loadImageForURL:[NSURL URLWithString:_codeUrl] image:^(UIImage *image, NSError *error) {
            if (!error) {
                _codeView.hidden = NO;
                [self codeHiddenChanged];
                if (!_codeImageView) {
                    _codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.width-80, _codeView.top+5, 75, _codeView.height-10)];
                    [_scrollView addSubview:_codeImageView];
                    _codeImageView.userInteractionEnabled = YES;
                    
                    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(codeRefresh:)];
                    tapGes.numberOfTapsRequired = 1;
                    [_codeImageView addGestureRecognizer:tapGes];
                }
                _codeImageView.image = image;
            } else {
                [EBAlert alertError:@"加载验证码失败，请重新登录"];
            }
        }];
    }
}

- (void)hideCode
{
    _codeView.hidden = YES;
}

- (void)codeHiddenChanged
{
    if (_codeView.hidden)
    {
        [_inputViews removeObject:_codeView];
    }
    else
    {
        [_inputViews addObject:_codeView];
    }
}

#pragma mark - EBInputViewDelegate
- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    _modifyMark = YES;
    _currentElementView = inputView;
    [self setBarButtonNeedsDisplayAtIndex:[_inputViews indexOfObject:inputView]];
}

@end
