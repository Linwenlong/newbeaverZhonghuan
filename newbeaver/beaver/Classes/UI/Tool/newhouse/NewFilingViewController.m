//
//  NewFilingViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "NewFilingViewController.h"
#import "EBStyle.h"
#import "EBCompatibility.h"
#import "SZTextView.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "EBPreferences.h"

@interface NewFilingViewController ()
{
    UITextField *_nameTextField;
    UITextField *_phoneTextField;
    SZTextView *_memoTextView;
    UIBarButtonItem *_commitButton;
}

@end

@implementation NewFilingViewController

- (void)loadView
{
    [super loadView];
    NSString *title = NSLocalizedString(@"new_filing_title", nil);
    self.navigationItem.title = title;
    _commitButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"commit", nil) target:self action:@selector(saveFiling:)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    if ( [EBCompatibility isIOS7Higher])
    {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    scrollView.clipsToBounds = NO;
    [self.view addSubview:scrollView];
    CGFloat yOffset = 15.0;
    UILabel *contentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 20.0)];
    contentTitleLabel.textColor = [EBStyle blackTextColor];
    contentTitleLabel.font = [UIFont systemFontOfSize:14.0];
    contentTitleLabel.text = NSLocalizedString(@"input_name_and_phone", nil);
    [scrollView addSubview:contentTitleLabel];
    yOffset += 20.0 + 10.0;
    _nameTextField = [self underLineTextFieldWithFrame:CGRectMake(15.0, yOffset, 290.0, 30.0)];
    _nameTextField.placeholder = NSLocalizedString(@"client_name_placeholder", nil);
    [scrollView addSubview:_nameTextField];
    yOffset += 30.0 + 10.0;
    _phoneTextField = [self underLineTextFieldWithFrame:CGRectMake(15.0, yOffset, 290.0, 30.0)];
    _phoneTextField.placeholder = NSLocalizedString(@"client_phone_placeholder", nil);
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [scrollView addSubview:_phoneTextField];
    yOffset += 30.0 + 40.0;
    
    _memoTextView = [[SZTextView alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 80.0)];
    _memoTextView.layer.borderWidth = 1.0;
    _memoTextView.layer.borderColor = [[EBStyle grayClickLineColor] CGColor];
    _memoTextView.textColor = [EBStyle blackTextColor];
    _memoTextView.font = [UIFont systemFontOfSize:14.0];
    _memoTextView.backgroundColor = [UIColor clearColor];
    _memoTextView.placeholder = NSLocalizedString(@"filing_memo_placeholder", nil);
    [scrollView addSubview:_memoTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_nameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_phoneTextField];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkCommitButtonEnable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_nameTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_phoneTextField];
}

- (BOOL)shouldPopOnBack
{
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_memoTextView resignFirstResponder];
    if (_memoTextView.text.length > 0
        || _nameTextField.text.length > 0
        || _phoneTextField.text.length > 0)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"alert_save_filing", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
    else
    {
        return YES;
    }
    return NO;
}

#pragma mark - UIButton Action

- (void)saveFiling:(id)sender
{
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_memoTextView resignFirstResponder];
    NSString *clientName = [_nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *clientPhone = [_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (clientName.length == 0)
    {
        [EBAlert alertError:NSLocalizedString(@"alert_input_correct_name", nil)];
    }
    else if (clientPhone.length == 0 || ![self checkPhoneNumInput:clientPhone])
    {
        [EBAlert alertError:NSLocalizedString(@"alert_input_correct_phone", nil)];
    }
    else
    {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"company_name"] = [EBPreferences sharedInstance].companyName;
        parameters[@"agent_name"] = [EBPreferences sharedInstance].userName;
        parameters[@"project_id"] = _projectId;
        parameters[@"project_name"] = _projectName;
        parameters[@"client_phone"] = clientPhone;
        parameters[@"client_name"] = clientName;
        if ([_memoTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
        {
            parameters[@"note"] = _memoTextView.text;
        }
        [[EBHttpClient sharedInstance] houseRequest:parameters addFiling:^(BOOL success, id result) {
            if (success)
            {
                [EBAlert alertSuccess:NSLocalizedString(@"alert_commit_success", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    }
}

- (void)textFieldTextChanged:(id)sender
{
    [self checkCommitButtonEnable];
}

#pragma mark - Private Method

- (UITextField *)underLineTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont systemFontOfSize:14.0];
    textField.textColor = [EBStyle blackTextColor];
    textField.frame = frame;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [textField addSubview:line];
    return textField;
}

- (BOOL)checkPhoneNumInput:(NSString *)phoneNum
{
    NSString *Regex =@"(13[0-9]|14[57]|15[012356789]|18[02356789])\\d{8}";
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [mobileTest evaluateWithObject:phoneNum];
}

- (void)checkCommitButtonEnable
{
    if ([_nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 &&
        [_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        _commitButton.enabled = YES;
    }
    else
    {
        _commitButton.enabled = NO;
    }
}


@end
