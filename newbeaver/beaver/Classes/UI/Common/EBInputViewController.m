//
// Created by 何 义 on 14-4-10.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBInputViewController.h"
#import "MHTextField.h"
#import "NSString+DDXML.h"


@interface EBInputViewController()<UITextFieldDelegate>
{
    MHTextField *_textField;
}
@end

@implementation EBInputViewController

- (void)loadView
{
    [super loadView];

    UIView *scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];

    CGFloat fieldWidth = self.view.frame.size.width - 15;
    _textField = [[MHTextField alloc] initWithFrame:CGRectMake(15, 10,
            fieldWidth, 45)];
    _textField.placeholder = self.placeholder;
    _textField.textColor = [EBStyle blackTextColor];
//    _textField.tintColor = [EBStyle blueTextColor];
    _textField.font = [UIFont systemFontOfSize:14.0f];
    _textField.backgroundColor = self.view.backgroundColor;
    _textField.placeholderColor = [EBStyle grayTextColor];
    _textField.text = self.value;
    _textField.hideToolBar = YES;
    [_textField setRequired:YES];
    [scrollView addSubview:_textField];

    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;

    _textField.enablesReturnKeyAutomatically = YES;

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 46, fieldWidth, 0.5f)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [scrollView addSubview:line];

    [self.view addSubview:scrollView];

    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(confirmInput:)];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)confirmInput:(UIButton *)btn
{
    if (_textField.text && [_textField.text stringByTrimming].length > 0)
    {
        self.confirmInputBlock(_textField.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self confirmInput:nil];
    return NO;
}


@end