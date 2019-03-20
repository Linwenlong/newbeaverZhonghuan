//
//  InputOrScanViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "InputOrScanViewController.h"
#import "UIImage+Alpha.h"
#import "MHTextField.h"
#import "QRScannerViewController.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "QRScannerView.h"

@interface InputOrScanViewController () <UITextFieldDelegate>

@end

@implementation InputOrScanViewController

#define SIZE_SCAN_BTN 55.0

- (void)loadView
{
    [super loadView];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.alwaysBounceVertical = YES;

    UIButton *scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SIZE_SCAN_BTN, SIZE_SCAN_BTN)];
    [scanBtn addTarget:self action:@selector(scanQRCode:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *btnImageN = [UIImage imageNamed:@"btn_scan"];
    UIImage *btnImageP = [btnImageN imageByApplyingAlpha:0.4];
    scanBtn.adjustsImageWhenHighlighted = NO;
    [scanBtn setImage:btnImageN forState:UIControlStateNormal];
    [scanBtn setImage:btnImageP forState:UIControlStateHighlighted];
    scanBtn.frame = CGRectOffset(scanBtn.frame, CGRectGetWidth(self.view.frame) / 2 - SIZE_SCAN_BTN / 2, 43);
    [scrollView addSubview:scanBtn];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, scanBtn.frame.origin.y + SIZE_SCAN_BTN + 10, [EBStyle screenWidth], 30)];
    label.textColor = [EBStyle blackTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0];
    [scrollView addSubview:label];

//    MHTextField *textField = [[MHTextField alloc] initWithFrame:CGRectMake(25, label.frame.origin.y + label.frame.size.height + 50, 270, 22)];
//    textField.textAlignment = NSTextAlignmentCenter;
//    textField.hideToolBar = YES;
//    textField.font = [UIFont systemFontOfSize:14.0];
//    textField.textColor = [EBStyle blackTextColor];
//    textField.returnKeyType = UIReturnKeyDone;
//    textField.placeholderColor = [EBStyle grayTextColor];
//    [scrollView addSubview:textField];
//
//    textField.delegate = self;
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, textField.frame.origin.y + textField.frame.size.height + 5, 280, 0.5)];
//    line.backgroundColor = [EBStyle blueBorderColor];
//    [scrollView addSubview:line];

    if ([_filters[0] isEqualToString:@"client"])
    {
        self.title = NSLocalizedString(@"input_code_title_client", nil);
        label.text = NSLocalizedString(@"input_code_scan_client", nil);
//        textField.placeholder = NSLocalizedString(@"input_code_input_client", nil);
    }
    else if ([_filters[0] isEqualToString:@"house"])
    {
        self.title = NSLocalizedString(@"input_code_title_house", nil);
        label.text = NSLocalizedString(@"input_code_scan_house", nil);
//        textField.placeholder = NSLocalizedString(@"input_code_input_house", nil);
    }

}

- (void)scanQRCode:(UIButton *)btn
{
    QRScannerViewController *scannerViewController = [[QRScannerViewController alloc] init];

    scannerViewController.infoFetched = ^(id result)
    {
        [self.navigationController popViewControllerAnimated:NO];
        self.outputBlock(@{@"data":result});
    };

    __block QRScannerViewController *weakScanner = scannerViewController;
    scannerViewController.shouldFetchInfo = ^BOOL(NSArray *info)
    {
        NSString *targetType = _filters[0];
        NSString *subType = _filters[1];

        if (![targetType isEqualToString:info[0]])
        {
            NSString *key = [NSString stringWithFormat:@"qr_hint_%@_mismatch", targetType];
            [weakScanner.scannerView
                    showHint:NSLocalizedString(key, nil) duration:5.0];
            return NO;
        }
        else if (![subType isEqualToString:info[1]])
        {
            NSString *key = [NSString stringWithFormat:@"qr_hint_%@_mismatch_%@", targetType, subType];
            [weakScanner.scannerView showHint:NSLocalizedString(key, nil) duration:5.0];
            return NO;
        }
        else
        {
            return YES;
        }
    };

    [self.navigationController pushViewController:scannerViewController animated:YES];
}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return NO;
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if (textField.text.length > 0)
//    {
//        _outputBlock(textField.text);
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
