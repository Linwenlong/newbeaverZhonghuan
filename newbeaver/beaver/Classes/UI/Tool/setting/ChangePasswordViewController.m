//
//  ChangePasswordViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "MHTextField.h"
#import "EBViewFactory.h"
#import "EBAlert.h"
#import "EBHttpClient.h"

@interface ChangePasswordViewController ()
{
     MHTextField *_oldPassword;
     MHTextField *_newPassword;
     MHTextField *_confirmPassword;
}

@end

@implementation ChangePasswordViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"change_pwd", nil);
    [self loadPasswordChangeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define PWD_Y_START 10.0
#define PWD_X_MARGIN 15.0
#define PWD_FIELD_HEIGHT 34.0
#define PWD_FIELD_GAP 10.0
#define PWD_BTN_GAP 24.0
#define PWD_BTN_HEIGHT 36

- (void)loadPasswordChangeView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scrollView];

    CGFloat yOffset = PWD_Y_START;
    // password
    _oldPassword = [self addTextFieldWithOffsetY:yOffset
                                     placeholder:NSLocalizedString(@"placeholder_current_pwd", nil) superView:scrollView];

    // new password
    yOffset += PWD_FIELD_GAP + PWD_FIELD_HEIGHT;
    _newPassword = [self addTextFieldWithOffsetY:yOffset
                                     placeholder:NSLocalizedString(@"placeholder_new_pwd", nil) superView:scrollView];

    // password confirm
    yOffset += PWD_FIELD_GAP + PWD_FIELD_HEIGHT;
    _confirmPassword = [self addTextFieldWithOffsetY:yOffset
                                         placeholder:NSLocalizedString(@"placeholder_confirm_pwd", nil) superView:scrollView];

    // to adjust the keyboard tool bar.
    [_oldPassword markTextFieldsWithTagInView:scrollView];
    [_newPassword markTextFieldsWithTagInView:scrollView];
    [_confirmPassword markTextFieldsWithTagInView:scrollView];

    yOffset += PWD_BTN_GAP + PWD_FIELD_HEIGHT;
    [scrollView addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(PWD_X_MARGIN, yOffset,
            self.view.frame.size.width - 2 * PWD_X_MARGIN, PWD_BTN_HEIGHT) title:NSLocalizedString(@"btn_change", nil)
            target:self action:@selector(changeClicked:)]];

    scrollView.alwaysBounceVertical = YES;
//    [scrollView setContentOffset:CGPointMake(0, 100)];
}

- (MHTextField *)addTextFieldWithOffsetY:(CGFloat)yOffset placeholder:(NSString *)placeholder superView:(UIView *)superView
{
    CGFloat fieldWidth = self.view.frame.size.width - PWD_X_MARGIN;
    MHTextField *textField = [[MHTextField alloc] initWithFrame:CGRectMake(PWD_X_MARGIN, yOffset,
            fieldWidth, PWD_FIELD_HEIGHT)];
    textField.placeholder = placeholder;
    textField.textColor = [EBStyle blackTextColor];
    textField.font = [UIFont systemFontOfSize:14.0f];
    textField.backgroundColor = self.view.backgroundColor;
    textField.placeholderColor = [EBStyle grayTextColor];
    [textField setRequired:YES];
    [textField setSecureTextEntry:YES];

    [superView addSubview:textField];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(PWD_X_MARGIN, yOffset + PWD_FIELD_HEIGHT, fieldWidth, 0.5f)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [superView addSubview:line];

    return textField;
}

- (void)changeClicked:(UIButton *)btn
{
    if (!_oldPassword.validate)
    {
        [EBAlert alertWithTitle:self.title message:NSLocalizedString(@"alert_input_old_pwd", nil)];
    }
    else if (!_newPassword.validate)
    {
        [EBAlert alertWithTitle:self.title message:NSLocalizedString(@"alert_input_new_pwd", nil)];
    }
    else if (!_confirmPassword.validate)
    {
        [EBAlert alertWithTitle:self.title message:NSLocalizedString(@"alert_input_confirm_pwd", nil)];
    }
    else if (_newPassword.text.length < 6 || _newPassword.text.length > 20)
    {
        [EBAlert alertWithTitle:self.title message:NSLocalizedString(@"alert_input_length_wrong", nil)];
    }
    else if (![_newPassword.text isEqualToString:_confirmPassword.text])
    {
        [EBAlert alertWithTitle:self.title message:NSLocalizedString(@"alert_input_confirm_wrong", nil)];
    }
    else
    {
        NSDictionary *params = @{@"old_password":_oldPassword.text, @"new_password":_newPassword.text};
        [[EBHttpClient sharedInstance] accountRequest:params changePassword:^(BOOL success, id result)
        {
            if (success)
            {
                [EBAlert alertWithTitle:self.title message:NSLocalizedString(@"alert_change_success", nil) confirm:^(){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
            else
            {

            }
        }];
    }
}

@end
