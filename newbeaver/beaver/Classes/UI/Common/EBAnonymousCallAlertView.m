//
//  EBAnonymousCallAlertView.m
//  beaver
//
//  Created by wangyuliang on 14-6-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBAnonymousCallAlertView.h"
#import "EBStyle.h"
#import "UIImage+ImageWithColor.h"
#import "EBPreferences.h"
#import "EBController.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBHttpClient.h"

@implementation EBAnonymousCallAlertView
{
    UILabel *_phoneCode;
    UITextField *_inputField;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.buttonTitles = nil;
        
//        [self buildContainerView];
    }
    
    return self;
}

- (void)setShowType:(NSInteger)showType
{
    _showType = showType;
    if (_showType == EAlertypeStart)
    {
        [self buildContainerViewForNav];
    }
    else if (_showType == EAlertypePhone)
    {
        [self buildContainerViewForPhone];
    }
    else if (_showType == EAlertypeInput)
    {
        [self buildContainerViewForInput];
    }
    else if (_showType == EAlertypeEnd)
    {
        [self buildContainerViewForEnd];
    }
}

- (void)buildContainerViewForNav
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 170)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 260, 64)];
    title.numberOfLines = 0;
    title.font = [UIFont boldSystemFontOfSize:14.0];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"anonymous_call_nav", nil);
    [containerView addSubview:title];
    
    UIButton *btnRemember = [[UIButton alloc] initWithFrame:CGRectMake(10, title.frame.origin.y + title.frame.size.height, 270, 44)];
    btnRemember.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btnRemember.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    btnRemember.adjustsImageWhenHighlighted = NO;
    btnRemember.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnRemember.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btnRemember setTitleColor:[EBStyle blackTextColor] forState:UIControlStateNormal];
    [btnRemember setTitle:NSLocalizedString(@"anonymous_call__remember_choice", nil) forState:UIControlStateNormal];
    
    [btnRemember setImage:[UIImage imageNamed:@"btn_uncheck"] forState:UIControlStateNormal];
    [btnRemember setImage:[UIImage imageNamed:@"btn_checked"] forState:UIControlStateSelected];
    btnRemember.selected = [EBPreferences sharedInstance].rememberAnonymousNavChoice;
    [btnRemember addTarget:self action:@selector(navRememberChoice:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:btnRemember];
    
    UIButton *btnCancel = [self buttonWithFrame:CGRectMake(0, btnRemember.frame.origin.y +
                                                        btnRemember.frame.size.height + 10, 140, 44) title:NSLocalizedString(@"anonymous_call_cancel", nil) target:self action:@selector(navCancel:)];
    [containerView addSubview:btnCancel];
    
    UIButton *btnContinue = [self buttonWithFrame:CGRectMake(140, btnRemember.frame.origin.y + btnRemember.frame.size.height + 10, 140, 44)
                                      title:NSLocalizedString(@"anonymous_call_continue", nil) target:self action:@selector(navContinue:)];
    [containerView addSubview:btnContinue];
    UIView *line = [self lineWithFrame:CGRectMake(0, btnCancel.frame.origin.y, 280, 0.5)];
    [containerView addSubview:line];
    line = [self lineWithFrame:CGRectMake(140, btnContinue.frame.origin.y, 0.5, btnContinue.frame.size.height)];
    [containerView addSubview:line];
    
//    self.buttonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"anonymous_call_cancel", nil),NSLocalizedString(@"anonymous_call_continue", nil), nil];
//    self.onButtonTouchUpInside = ^(CustomIOS7AlertView *alertView, int buttonIndex)
//    {
//        if (buttonIndex == 0)
//        {
////            [alertView show];
//        }
//        if (buttonIndex == 1)
//        {
//            [[EBController sharedInstance] showAnonymousCallAlert:self.completion type:2];
//        }
//    };
    
    [self setContainerView:containerView];
}

- (void)navRememberChoice:(UIButton *)btn
{
    btn.selected = !btn.selected;
    EBPreferences *pref = [EBPreferences sharedInstance];
    pref.rememberAnonymousNavChoice = btn.selected;
    [pref writePreferences];
}

- (void)navCancel:(UIButton *)btn
{
    [self close];
}

- (void)navContinue:(UIButton *)btn
{
    [self close];
//    [[EBController sharedInstance] showAnonymousCallAlert:self.completion type:2];
}

- (void)buildContainerViewForPhone
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 246)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 260, 30)];
    title.numberOfLines = 0;
    title.font = [UIFont boldSystemFontOfSize:14.0];
    title.textColor = [UIColor blackColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = NSLocalizedString(@"anonymous_call_phone_title", nil);
    [containerView addSubview:title];
    
    _phoneCode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, title.frame.origin.y + title.frame.size.height + 5, 260, 20)];
    _phoneCode.font = [UIFont systemFontOfSize:14.0];
    _phoneCode.textColor = [EBStyle blackTextColor];
    _phoneCode.textAlignment = NSTextAlignmentCenter;
    _phoneCode.text = [EBContactManager sharedInstance].myContact.phone;
    [containerView addSubview:_phoneCode];
    
    UIButton *btnRemember = [[UIButton alloc] initWithFrame:CGRectMake(10, _phoneCode.frame.origin.y + _phoneCode.frame.size.height, 270, 44)];
    btnRemember.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btnRemember.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    btnRemember.adjustsImageWhenHighlighted = NO;
    btnRemember.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnRemember.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btnRemember setTitleColor:[EBStyle blackTextColor] forState:UIControlStateNormal];
    [btnRemember setTitle:NSLocalizedString(@"anonymous_call__remember_choice", nil) forState:UIControlStateNormal];
    
    [btnRemember setImage:[UIImage imageNamed:@"btn_uncheck"] forState:UIControlStateNormal];
    [btnRemember setImage:[UIImage imageNamed:@"btn_checked"] forState:UIControlStateSelected];
    btnRemember.selected = [EBPreferences sharedInstance].rememberAnonymousNavChoice;
    [btnRemember addTarget:self action:@selector(phoneRememberChoice:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:btnRemember];
    
    UIButton *btnRight = [self buttonWithFrame:CGRectMake(0, btnRemember.frame.origin.y +
                                                        btnRemember.frame.size.height + 10, 280, 44) title:NSLocalizedString(@"anonymous_call_phone_right", nil) target:self action:@selector(phoneRight:)];
    [containerView addSubview:btnRight];
    UIView *line = [self lineWithFrame:CGRectMake(0, btnRight.frame.origin.y, 280, 0.5)];
    [containerView addSubview:line];
    
    UIButton *btnError = [self buttonWithFrame:CGRectMake(0, btnRight.frame.origin.y +
                                                        btnRight.frame.size.height, 280, 44) title:NSLocalizedString(@"anonymous_call_phone_error", nil) target:self action:@selector(phoneError:)];
    [containerView addSubview:btnError];
    line = [self lineWithFrame:CGRectMake(0, btnError.frame.origin.y, 280, 0.5)];
    [containerView addSubview:line];
    
    UIButton *btnNO = [self buttonWithFrame:CGRectMake(0, btnError.frame.origin.y + btnError.frame.size.height, 280, 44)
                                      title:NSLocalizedString(@"anonymous_call_phone_cancel", nil) target:self action:@selector(phoneCanel:)];
    [containerView addSubview:btnNO];
    line = [self lineWithFrame:CGRectMake(0, btnNO.frame.origin.y, 280, 0.5)];
    [containerView addSubview:line];
    
    [self setContainerView:containerView];
}

- (void)phoneRememberChoice:(UIButton *)btn
{
    btn.selected = !btn.selected;
    EBPreferences *pref = [EBPreferences sharedInstance];
    pref.rememberAnonymousNavChoice = btn.selected;
    [pref writePreferences];
}

- (void)phoneRight:(UIButton *)btn
{
    self.completion();
    [self close];
}

- (void)phoneError:(UIButton *)btn
{
    [self setHidden:YES];
//    [[EBController sharedInstance] showAnonymousCallAlert:^{
//        _phoneCode.text = [EBContactManager sharedInstance].myContact.phone;
//        [self setHidden:NO];
//    } type:3];
}

- (void)phoneCanel:(UIButton *)btn
{
    [self close];
}

- (void)buildContainerViewForInput
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 260, 34)];
    title.numberOfLines = 0;
    title.font = [UIFont boldSystemFontOfSize:14.0];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"anonymous_call_input_title", nil);
    [containerView addSubview:title];
    
    _inputField = [[UITextField alloc] initWithFrame:CGRectMake(10, title.frame.origin.y + title.frame.size.height + 10, 260, 40)];
    _inputField.keyboardType = UIKeyboardTypeNumberPad;
    _inputField.borderStyle = UITextBorderStyleLine;
//    _inputField.layer.borderColor = [[UIColor cyanColor] CGColor];
    _inputField.layer.borderColor = [[UIColor blackColor] CGColor];
    
    UIButton *btnCancel = [self buttonWithFrame:CGRectMake(0, _inputField.frame.origin.y +
                                                          _inputField.frame.size.height + 20, 140, 44) title:NSLocalizedString(@"anonymous_call_input_cancel", nil) target:self action:@selector(inputCancel:)];
    
    UIButton *btnSave = [self buttonWithFrame:CGRectMake(140, _inputField.frame.origin.y +
                                                          _inputField.frame.size.height + 20, 140, 44) title:NSLocalizedString(@"anonymous_call_input_save", nil) target:self action:@selector(inputSave:)];
    UIView *line = [self lineWithFrame:CGRectMake(0, btnSave.frame.origin.y, 280, 0.5)];
    [containerView addSubview:line];
    line = [self lineWithFrame:CGRectMake(btnSave.frame.origin.x, btnSave.frame.origin.y, 0.5, btnSave.frame.size.height)];
    [containerView addSubview:line];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
    [btn addTarget:self action:@selector(textEditEnd:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:btn];
    [containerView addSubview:btnCancel];
    [containerView addSubview:btnSave];
    [containerView addSubview:_inputField];
    
    [self setContainerView:containerView];
}

- (void)textEditEnd:(UIButton *)btn
{
    [_inputField resignFirstResponder];
}

//- (IBAction) backgroundTap:(id)sender
//{
//    [_inputField resignFirstResponder];
//}

- (void)inputCancel:(UIButton *)btn
{
    [self close];
//    self.completion();
}

- (void)inputSave:(UIButton *)btn
{
    NSDictionary *params = @{@"number":_inputField.text};
    [[EBHttpClient sharedInstance] accountRequest:params changeCallNumber:^(BOOL success, id result)
     {
         if (success)
         {
             self.completion();
             [self close];
         }
         else
         {
             [self close];
         }
     }];
//    self.completion();
}

- (void)buildContainerViewForEnd
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 130)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 260, 64)];
    title.numberOfLines = 0;
    title.font = [UIFont boldSystemFontOfSize:14.0];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"anonymous_call_end_title", nil);
    [containerView addSubview:title];
    
    UIButton *btnConfirm = [self buttonWithFrame:CGRectMake(0, title.frame.origin.y +
                                                           title.frame.size.height + 10, 280, 44) title:NSLocalizedString(@"anonymous_call_end_confirm", nil) target:self action:@selector(inputCancel:)];
    [containerView addSubview:btnConfirm];
    UIView *line = [self lineWithFrame:CGRectMake(0, btnConfirm.frame.origin.y, 280, 0.5)];
    [containerView addSubview:line];
    
    [self setContainerView:containerView];
}

- (void)endConfirm:(UIButton *)btn
{
    
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    
//    [btn setBackgroundImage:[UIImage imageWithColor:[EBStyle grayClickLineColor]] forState:UIControlStateHighlighted];
//    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    
//    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
//    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
//    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
//    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
//    
//    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (UIView *)lineWithFrame:(CGRect)rect
{
    UIView *line = [[UIView alloc] initWithFrame:rect];
    line.backgroundColor = [EBStyle grayClickLineColor];
    
    return line;
}

@end
