//
//  ReportViewController.m
//  beaver
//
//  Created by ChenYing on 14-7-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ReportViewController.h"
#import "EBCompatibility.h"
#import "SZTextView.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "EBFilter.h"
#import "UIAlertView+Blocks.h"

#define MAX_VISIT_LOG_TEXT_LENGTH 200

@interface ReportViewController ()
{
    SZTextView *_reasonTextView;
    UILabel *_countLabel;
    UIBarButtonItem *_commitButton;
}

@end

@implementation ReportViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = _reportType;
    
    _commitButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"commit", nil) target:self action:@selector(commitReport:)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    if ( [EBCompatibility isIOS7Higher])
    {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    scrollView.clipsToBounds = NO;
    [self.view addSubview:scrollView];
    
    _reasonTextView = [[SZTextView alloc] initWithFrame:CGRectMake(15.0, 15.0, 290.0, 165.0)];
    _reasonTextView.layer.borderWidth = 1.0;
    _reasonTextView.layer.borderColor = [[EBStyle grayClickLineColor] CGColor];
    _reasonTextView.textColor = [EBStyle blackTextColor];
    _reasonTextView.font = [UIFont systemFontOfSize:16.0];
    _reasonTextView.backgroundColor = [UIColor clearColor];
    _reasonTextView.placeholder = NSLocalizedString(@"report_reason_placeholder", nil);
    _reasonTextView.delegate = self;
    [scrollView addSubview:_reasonTextView];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 158, 30, 20)];
    _countLabel.text = [NSString stringWithFormat:@"%d",MAX_VISIT_LOG_TEXT_LENGTH];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textAlignment = NSTextAlignmentRight;
    _countLabel.font = [UIFont systemFontOfSize:16.0];
    _countLabel.textColor = [EBStyle grayTextColor];
    [scrollView addSubview:_countLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self checkCommitButtonEnable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_reasonTextView becomeFirstResponder];
}

- (BOOL)shouldPopOnBack
{
    if (_reasonTextView.text.length > 0)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"alert_save_report", nil)
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length > 0)
    {
        if (_reasonTextView.text.length >= MAX_VISIT_LOG_TEXT_LENGTH)
        {
            return NO;
        }
        else
        {
            NSString *log = [NSString stringWithFormat:@"%@%@",_reasonTextView.text, text];
            if (log.length > MAX_VISIT_LOG_TEXT_LENGTH)
            {
                _reasonTextView.text = [log substringToIndex:MAX_VISIT_LOG_TEXT_LENGTH];
                [self textViewDidChange:_reasonTextView];
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView;
{
    _countLabel.text = [NSString stringWithFormat:@"%ld", MAX_VISIT_LOG_TEXT_LENGTH - _reasonTextView.text.length];
    [self checkCommitButtonEnable];
}

#pragma mark - Action Method

- (void)commitReport:(id)sender
{
    [_reasonTextView resignFirstResponder];
    NSString *reportReason = _reasonTextView.text;
    if ([reportReason stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"alert_input_report_reason", nil)];
    }
    else
    {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"house_id"] = _house.id;
        parameters[@"report_type"] = _reportType;
        parameters[@"type"] = [EBFilter typeString:_house.rentalState];
        parameters[@"reason"] = reportReason;
        [[EBHttpClient sharedInstance] houseRequest:parameters report:^(BOOL success, id result)
        {
            if (success)
            {
                [EBAlert alertSuccess:nil length:1.0 allowUserInteraction:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    }
}

- (void)checkCommitButtonEnable
{
    if ([_reasonTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        _commitButton.enabled = YES;
    }
    else
    {
        _commitButton.enabled = NO;
    }
}

@end
