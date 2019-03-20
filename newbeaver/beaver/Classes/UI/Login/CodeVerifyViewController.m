//
//  CodeVerifyViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//



#import "CodeVerifyViewController.h"
#import "EBPreferences.h"
#import "EBController.h"
#import "EBHttpClient.h"
#import "EBViewFactory.h"
#import "EBAlert.h"

//短信
#define VERIFY_TYPE_SMS   @"sms"
#define VERIFY_TYPE_VOICE @"voice"

@interface CodeVerifyViewController ()
{
    UITextField *_hiddenInput;
    UIButton *_resendButton;
    NSTimer *_resendTimer;
    NSInteger _resendCount;
    
    UIButton *_rePhoneBtn;
    
    UILabel *_textLabel;
}

@end

@implementation CodeVerifyViewController

@synthesize verifyCode, userName, phoneNumber;

- (void)loadView
{
    [super loadView];
    if (_viewType == ECodeVerifyViewTypeLogin)
    {
        self.title = NSLocalizedString(@"title_verify_phone", nil);
        if (self.verifyCode.length > 0)
        {
            [self showCodeInputView];
        }
        else
        {
            [self showInvalidPhoneNumberView];
        }
    }
    else if (_viewType == ECodeVerifyViewTypeAnonymousTel)
    {
        self.title = NSLocalizedString(@"title_verify_anonynum", nil);
        [self showCodeInputView];
    }
    
    //text
//    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, [EBStyle screenWidth], 40)];
//    _textLabel.textAlignment = NSTextAlignmentCenter;
//    _textLabel.font = [UIFont systemFontOfSize:14.0];
//    _textLabel.textColor = [EBStyle redTextColor];
//    _textLabel.text = verifyCode;
//    [self.view addSubview:_textLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self beaverStatistics:@"SendNote"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_resendTimer != nil)
    {
        [_resendTimer invalidate];
        _resendTimer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define CODE_Y_START 15.0
#define CODE_X_MARGIN 15.0
#define CODE_HINT_HEIGHT 80.0
#define CODE_DISPLAY_LENGTH 49.0
#define CODE_DISPLAY_X_MARGIN 27.0
#define CODE_BTN_HEIGHT 36.0
#define CODE_DISPLAY_COUNT 4
#define CODE_BTN_TOP_MARGIN 20.0
#define CODE_BTN_TOP_MARGIN_IPHONE4 10.0
#define CODE_DISPLAY_TAG_BASE 99

#pragma mark - wrong phone number
- (void)showInvalidPhoneNumberView
{
    RTLabel *hint = [[RTLabel alloc]
            initWithFrame:CGRectMake(CODE_X_MARGIN, CODE_Y_START,
                    self.view.frame.size.width - 2 * CODE_X_MARGIN, CODE_HINT_HEIGHT)];

    hint.font = [UIFont systemFontOfSize:12.0];
    hint.textColor = [UIColor blackColor];
    hint.text = [NSString stringWithFormat:NSLocalizedString(@"verify_wrong_number", nil), self.userName, self.phoneNumber];

    [self.view addSubview:hint];
}

#pragma mark -- LWL
- (void)upKeyBoard:(UITapGestureRecognizer *)tap{
    [_hiddenInput becomeFirstResponder];
}

#pragma mark - verify code input

- (void)showCodeInputView
{
    CGFloat yOffset = CODE_Y_START;
    RTLabel *hintLabel = (RTLabel *)[self.view viewWithTag:66];
    if (hintLabel == nil)
    {
        hintLabel = [[RTLabel alloc] initWithFrame:CGRectMake(CODE_X_MARGIN, yOffset,                                                self.view.frame.size.width - 2 * CODE_X_MARGIN, CODE_HINT_HEIGHT)];
        hintLabel.font = [UIFont systemFontOfSize:12.0];
        hintLabel.textColor = [UIColor blackColor];
        hintLabel.lineSpacing = 3.0;
        hintLabel.tag = 66;
        [self.view addSubview:hintLabel];
    }

    NSString *hintText = @"";
    if (_viewType == ECodeVerifyViewTypeLogin)
    {
        if ([VERIFY_TYPE_VOICE isEqualToString:self.verifyType]) {
            hintText = [NSString stringWithFormat:NSLocalizedString(@"verify_code_hint_voice", nil), self.userName, self.phoneNumber];
        }
        else
        {
            hintText = [NSString stringWithFormat:NSLocalizedString(@"verify_code_hint_sms", nil), self.userName, self.phoneNumber];
        }
    }
    else if (_viewType == ECodeVerifyViewTypeAnonymousTel)
    {
        if ([VERIFY_TYPE_VOICE isEqualToString:self.verifyType])
        {
            hintText = [NSString stringWithFormat:NSLocalizedString(@"anonymous_call_setting_verify_voice", nil),self.phoneNumber];
        }
        else
        {
            hintText = [NSString stringWithFormat:NSLocalizedString(@"anonymous_call_setting_verify_sms", nil),self.phoneNumber];
        }
    }
    hintLabel.text = hintText;
    
    CGFloat hintLabelHeight = [EBViewFactory textSize:hintText font:hintLabel.font bounding:CGSizeMake(hintLabel.frame.size.width, MAXFLOAT)].height;
    CGRect frame = hintLabel.frame;
    frame.size.height = hintLabelHeight;
    hintLabel.frame = frame;
    
    if ([EBStyle isUnder_iPhone5])
    {
        yOffset += hintLabelHeight + CODE_BTN_TOP_MARGIN_IPHONE4;
    }
    else
    {
        yOffset += hintLabelHeight + CODE_BTN_TOP_MARGIN;
    }
    
    CGFloat xCursor = CODE_DISPLAY_X_MARGIN;
    CGFloat gap = (self.view.frame.size.width - 2 * CODE_DISPLAY_X_MARGIN -
           CODE_DISPLAY_COUNT * CODE_DISPLAY_LENGTH) /  (CODE_DISPLAY_COUNT - 1);

    for (NSInteger i = 0; i < CODE_DISPLAY_COUNT; i++)
    {
        UILabel *display = (UILabel *)[self.view viewWithTag:CODE_DISPLAY_TAG_BASE + i];
        if (display == nil)
        {
            UILabel *display = [self codeDisplayWithX:xCursor y:yOffset tag:CODE_DISPLAY_TAG_BASE + i];
            xCursor += CODE_DISPLAY_LENGTH + gap;
            UITapGestureRecognizer *tap= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(upKeyBoard:)];
            display.userInteractionEnabled = YES;
            [display addGestureRecognizer:tap];
            [self.view addSubview:display];
        }
        frame = display.frame;
        frame.origin.y = yOffset;
        display.frame = frame;
    }
    
    if ([EBStyle isUnder_iPhone5])
    {
        yOffset += CODE_DISPLAY_LENGTH + CODE_BTN_TOP_MARGIN_IPHONE4;
    }
    else
    {
        yOffset += CODE_DISPLAY_LENGTH + CODE_BTN_TOP_MARGIN;
    }
    
   // resend button
    if (_resendButton == nil)
    {
        _resendButton = [EBViewFactory blueButtonWithFrame:CGRectMake(15, yOffset,
                                                                      [EBStyle screenWidth] - 30, CODE_BTN_HEIGHT) title:NSLocalizedString(@"user_codevery_resend_active", nil) target:self action:@selector(resendVerifyCode)];
        [_resendButton setTitleColor:[UIColor grayColor]forState:UIControlStateDisabled];
        [_resendButton setBackgroundImage:[[UIImage imageNamed:@"btn_resend_disable"] stretchableImageWithLeftCapWidth:6 topCapHeight:1]
                                 forState:UIControlStateDisabled];
        [self.view addSubview:_resendButton];
        
        _rePhoneBtn = [EBViewFactory blueButtonWithFrame:CGRectMake(30 + _resendButton.width, yOffset, ([EBStyle screenWidth] - 3 * 15.0) / 2.0, CODE_BTN_HEIGHT) title:NSLocalizedString(@"user_codevery_recallsend", nil) target:self action:@selector(rephoneVerifyCode)];
        [_rePhoneBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_rePhoneBtn setBackgroundImage:[[UIImage imageNamed:@"btn_resend_disable"] stretchableImageWithLeftCapWidth:6 topCapHeight:1]
                                 forState:UIControlStateDisabled];
        [self.view addSubview:_rePhoneBtn];
        _rePhoneBtn.alpha = 0;
    }
    frame = _resendButton.frame;
    frame.origin.y = yOffset;
    _resendButton.frame = frame;
    frame = _rePhoneBtn.frame;
    frame.origin.y = yOffset;
    _rePhoneBtn.frame = frame;
    
    RTLabel *hintLabel2 = (RTLabel *)[self.view viewWithTag:88];
    
    if (![VERIFY_TYPE_VOICE isEqualToString:self.verifyType])
    {
        if ([EBStyle isUnder_iPhone5])
        {
            yOffset += CODE_BTN_HEIGHT + CODE_BTN_TOP_MARGIN_IPHONE4;
        }
        else
        {
            yOffset += CODE_BTN_HEIGHT + CODE_BTN_TOP_MARGIN;
        }
        
        if (hintLabel2 == nil)
        {
            hintLabel2 = [[RTLabel alloc] initWithFrame:CGRectMake(CODE_X_MARGIN, yOffset,
                                                                   self.view.frame.size.width - 2 * CODE_X_MARGIN, CODE_HINT_HEIGHT)];
            hintLabel2.font = [UIFont systemFontOfSize:12.0];
            hintLabel2.textColor = [UIColor blackColor];
            hintLabel2.lineSpacing = 3.0;
            hintLabel2.linkAttributes = @{@"color":@"#197add"};
            hintLabel2.selectedLinkAttributes = @{@"color":@"#197add44"};
            hintLabel2.delegate = self;
            hintLabel2.text = NSLocalizedString(@"anonymous_call_setting_verify_tel", nil);
            hintLabel2.tag = 88;
            [self.view addSubview:hintLabel2];
        }
        frame = hintLabel2.frame;
        frame.origin.y = yOffset;
        hintLabel2.frame = frame;
    }
    else
    {
        if (hintLabel2)
        {
            hintLabel2.hidden = YES;
        }
    }
    hintLabel2.hidden = YES;

    // hidden text Field
    if (_hiddenInput == nil){
        _hiddenInput = [[UITextField alloc] initWithFrame:CGRectZero];
        _hiddenInput.delegate = self;
        _hiddenInput.keyboardType = UIKeyboardTypeNumberPad;
        [self.view addSubview:_hiddenInput];
    }
    [_hiddenInput becomeFirstResponder];

    [self startResendTimer];
}

- (UILabel *)codeDisplayWithX:(CGFloat)x y:(CGFloat)y tag:(NSInteger)tag
{
    UILabel *codeDisplay = [[UILabel alloc] initWithFrame:CGRectMake(x, y,
            CODE_DISPLAY_LENGTH, CODE_DISPLAY_LENGTH)];
    codeDisplay.layer.borderColor = [self lineGrayColor].CGColor;
    codeDisplay.layer.borderWidth = 1.0;
    codeDisplay.font = [UIFont boldSystemFontOfSize:20.0];
    codeDisplay.textAlignment = NSTextAlignmentCenter;
    codeDisplay.tag = tag;
    return codeDisplay;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    DDLogDebug(@"range:%ld,%ld, content:%@", range.location, range.length, string);
    NSInteger location = range.location;
    if (location >= CODE_DISPLAY_COUNT)
    {
        return NO;
    }
    UILabel *label = (UILabel *)[self.view viewWithTag:CODE_DISPLAY_TAG_BASE + range.location];
    label.text = string;
    if (location == 3 && string.length > 0)
    {
        NSString *inputCode = [_hiddenInput.text stringByAppendingString:string];
        if (_viewType == ECodeVerifyViewTypeLogin)
        {
            if ([inputCode isEqualToString:self.verifyCode])
            {
                EBPreferences *pref = [EBPreferences sharedInstance];
                NSDictionary *parameters = @{@"ticket":pref.ticket, @"code":self.verifyCode};

                [[EBHttpClient sharedInstance] accountRequest:parameters verifyCode:^(BOOL success, id result)
                 {
//                     [EBAlert hideLoading];
                     if (success)
                     {
                         NSDictionary *token = (NSDictionary *)result[@"token"];
                         pref.token = token[@"token"];
                         pref.tokenLife = [token[@"expire"] integerValue] - [token[@"time"] integerValue];
                         pref.loginTime = [NSDate date].timeIntervalSince1970;
                         pref.ticket = nil;
                         [pref writePreferences];
                         [EBController accountLoggedIn];
                     }
                 }];
            }
            else
            {
                [EBAlert alertError:NSLocalizedString(@"wrong_verify_code", nil)];
            }
        }
        else if (_viewType == ECodeVerifyViewTypeAnonymousTel)
        {
            NSDictionary *parameters = @{@"verify_code":inputCode};
            [[EBHttpClient sharedInstance] accountRequest:parameters verifyAnonymousTel:^(BOOL success, id result) {
                if (success)
                {
                    NSDictionary *verify = result[@"verify"];
                    BOOL isVerified = [verify[@"is_verified"] boolValue];
                    if (isVerified) {
                        if (self.verifySuccess)
                        {
                            self.verifySuccess();
                        }
                    }
                    else
                    {
                        [EBAlert alertError:NSLocalizedString(@"wrong_verify_code", nil)];
                    }
                    
                }
                else
                {
                    [EBAlert alertError:NSLocalizedString(@"wrong_verify_code", nil)];
                }
            }];
        }
    }
    return YES;
}

#pragma mark - resend button

- (void)resendVerifyCode
{
    if (_viewType == ECodeVerifyViewTypeLogin)
    {
        [self startResendTimer];
        EBPreferences *pref = [EBPreferences sharedInstance];
        [EBAlert showLoading:nil];
        NSDictionary *params;
        if ([_verifyType isEqualToString:VERIFY_TYPE_VOICE]) {
            params = @{@"ticket":pref.ticket, @"sender":@"voice"};
        }
        else
        {
            params = @{@"ticket":pref.ticket};
        }
        [[EBHttpClient sharedInstance] accountRequest:params resendCode:^(BOOL success, id result)
         {
             if (success)
             {
//                             [EBAlert alertSuccess:(NSString *)string];
             }
             [EBAlert hideLoading];
         }];
    }
    else if (_viewType == ECodeVerifyViewTypeAnonymousTel)
    {
        [self startResendTimer];
        [EBAlert showLoading:nil];
        NSDictionary *params = @{@"number":self.phoneNumber,@"verify_type":self.verifyType};
        [[EBHttpClient sharedInstance] accountRequest:params setNumber:^(BOOL success, id result)
        {
            [EBAlert hideLoading];
        }];
    }
}

#pragma mark -- 手机验证码
- (void)rephoneVerifyCode
{
    if (self.viewType == ECodeVerifyViewTypeLogin) {
        self.verifyType = VERIFY_TYPE_VOICE;
        [self startResendTimer];
        EBPreferences *pref = [EBPreferences sharedInstance];
        [EBAlert showLoading:nil];
        NSDictionary *params;
        if ([_verifyType isEqualToString:VERIFY_TYPE_VOICE]) {
            params = @{@"ticket":pref.ticket, @"sender":@"voice"};
        }
        else
        {
            params = @{@"ticket":pref.ticket};
        }
        [[EBHttpClient sharedInstance] accountRequest:params resendCode:^(BOOL success, id result)
         {
             if (success)
             {
                 //            [EBAlert alertSuccess:<#(NSString *)string#>];
             }
             [self showCodeInputView];
             [EBAlert hideLoading];
         }];
    }
    else if (self.viewType == ECodeVerifyViewTypeAnonymousTel)
    {
        [self startResendTimer];
        [EBAlert showLoading:nil];
        NSDictionary *params = @{@"number":self.phoneNumber,@"verify_type":VERIFY_TYPE_VOICE};
        [[EBHttpClient sharedInstance] accountRequest:params setNumber:^(BOOL success, id result)
         {
             self.verifyType = VERIFY_TYPE_VOICE;
             [self showCodeInputView];
             [EBAlert hideLoading];
         }];
    }
}

- (void) startResendTimer
{
    if (_resendTimer.isValid)
    {
        [_resendTimer invalidate];
    }
    _resendCount = 60;

    if ([VERIFY_TYPE_VOICE isEqualToString:self.verifyType])
    {
        [_resendButton setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_resend_wait", nil),
                                 (long)_resendCount] forState:UIControlStateDisabled];
        [_resendButton setTitle:NSLocalizedString(@"user_codevery_resend_wait", nil) forState:UIControlStateNormal];
        [_rePhoneBtn setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_recallsend_active", nil),
                               (long)_resendCount] forState:UIControlStateDisabled];
        [_rePhoneBtn setTitle:NSLocalizedString(@"user_codevery_recallsend_active", nil) forState:UIControlStateNormal];
        
    }
    else
    {
        [_resendButton setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_resend_active", nil),
                                 (long)_resendCount] forState:UIControlStateDisabled];
        [_resendButton setTitle:NSLocalizedString(@"user_codevery_resend_active", nil) forState:UIControlStateNormal];
        [_rePhoneBtn setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_recallsend", nil),
                               (long)_resendCount] forState:UIControlStateDisabled];
        [_rePhoneBtn setTitle:NSLocalizedString(@"user_codevery_recallsend", nil) forState:UIControlStateNormal];
    }

    [_resendButton setEnabled:NO];
    [_rePhoneBtn setEnabled:NO];
    _resendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resendTick) userInfo:nil repeats:YES];
//    EBPreferences *pref = [EBPreferences sharedInstance];
//    [[EBHttpClient sharedInstance] accountRequest:@{@"ticket":pref.ticket} verifyCode:^(BOOL success, id result)
//    {
//
//    }];
}

- (void) resendTick
{
    _resendCount--;
    if (_resendCount <= 0)
    {
        [_resendButton setEnabled:YES];
        [_rePhoneBtn setEnabled:YES];
        [_resendTimer invalidate];
        _resendTimer = nil;
    }
    else
    {
        if ([VERIFY_TYPE_VOICE isEqualToString:self.verifyType])
        {
            [_resendButton setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_resend_wait", nil),
                                     (long)_resendCount] forState:UIControlStateDisabled];
            [_resendButton setTitle:NSLocalizedString(@"user_codevery_resend_wait", nil) forState:UIControlStateNormal];
            [_rePhoneBtn setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_recallsend_active", nil),
                                     (long)_resendCount] forState:UIControlStateDisabled];
            [_rePhoneBtn setTitle:NSLocalizedString(@"user_codevery_recallsend_active", nil) forState:UIControlStateNormal];
        }
        else
        {
            [_resendButton setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_resend_active", nil), (long)_resendCount] forState:UIControlStateDisabled];
            [_resendButton setTitle:NSLocalizedString(@"user_codevery_resend_active", nil) forState:UIControlStateNormal];
            [_rePhoneBtn setTitle:[NSString stringWithFormat:@"%@（%ld）", NSLocalizedString(@"user_codevery_recallsend", nil),
                                   (long)_resendCount] forState:UIControlStateDisabled];
            [_rePhoneBtn setTitle:NSLocalizedString(@"user_codevery_recallsend", nil) forState:UIControlStateNormal];
        }
    }
}

- (UIColor *)lineGrayColor
{
    return [UIColor colorWithRed:0xcb/255.0f green:0xcc/255.0f blue:0xdb/255.0f alpha:1.0];
}

#pragma mark - RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    if (self.viewType == ECodeVerifyViewTypeLogin) {
        self.verifyType = VERIFY_TYPE_VOICE;
        [self startResendTimer];
        EBPreferences *pref = [EBPreferences sharedInstance];
        [EBAlert showLoading:nil];
        NSDictionary *params;
        if ([_verifyType isEqualToString:VERIFY_TYPE_VOICE]) {
            params = @{@"ticket":pref.ticket, @"sender":@"voice"};
        }
        else
        {
            params = @{@"ticket":pref.ticket};
        }
        [[EBHttpClient sharedInstance] accountRequest:params resendCode:^(BOOL success, id result)
         {
             if (success)
             {
                 //            [EBAlert alertSuccess:<#(NSString *)string#>];
             }
             [self showCodeInputView];
             [EBAlert hideLoading];
         }];
    }
    else if (self.viewType == ECodeVerifyViewTypeAnonymousTel)
    {
        [self startResendTimer];
        [EBAlert showLoading:nil];
        NSDictionary *params = @{@"number":self.phoneNumber,@"verify_type":VERIFY_TYPE_VOICE};
        [[EBHttpClient sharedInstance] accountRequest:params setNumber:^(BOOL success, id result)
         {
             self.verifyType = VERIFY_TYPE_VOICE;
             [self showCodeInputView];
             [EBAlert hideLoading];
         }];
    }
}

@end
