//
// Created by 何 义 on 14-3-21.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBAlert.h"
#import "SVProgressHUD.h"
#import "UIAlertView+AFNetworking.h"
#import "UIAlertView+Blocks.h"


@implementation EBAlert

+(void)alertError:(NSString *)string
{
    [SVProgressHUD showErrorWithStatus:string duration:2.0];
}

+(void)alertError:(NSString *)string length:(NSTimeInterval)length
{
    [SVProgressHUD showErrorWithStatus:string duration:length];
}

+(void)alertSuccess:(NSString *)string
{
    [SVProgressHUD showSuccessWithStatus:string duration:2.0];
}

+(void)alertSuccess:(NSString *)string length:(NSTimeInterval)length
{
    [SVProgressHUD showSuccessWithStatus:string duration:length];
}

+(void)alertSuccess:(NSString *)string allowUserInteraction:(BOOL)allowUserInteraction
{
    [SVProgressHUD showSuccessWithStatus:string maskType:allowUserInteraction ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear];
}

+(void)alertSuccess:(NSString *)string length:(NSTimeInterval)length allowUserInteraction:(BOOL)allowUserInteraction
{
    [SVProgressHUD showSuccessWithStatus:string duration:length maskType:allowUserInteraction ? SVProgressHUDMaskTypeNone : SVProgressHUDMaskTypeClear];
}

+(void)showLoading:(NSString *)string
{
    [SVProgressHUD showWithStatus:string];
}

+(void)showLoading:(NSString *)string allowUserInteraction:(BOOL)allowUserInteraction
{
    if (allowUserInteraction)
    {
        [SVProgressHUD showWithStatus:string];
    }
    else
    {
        [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeClear];
    }
}

+(void)hideLoading
{
    [SVProgressHUD dismiss];
}

+(void)hideLoading:(void(^)(BOOL finished))completion
{
    [SVProgressHUD dismiss:completion];
}

+(void)confirmWithTitle:(NSString *)title message:(NSString *)message yes:(NSString *)yes action:(void(^)(void))action
{
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil) action:^
                       {

                       }]
                       otherButtonItems:[RIButtonItem itemWithLabel:yes action:^{
                           // Handle "Delete"
                           action();
                       }], nil] show];
}

+(void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"title_ok", nil) action:^
                       {

                       }]
                       otherButtonItems:nil] show];
}

+(void)alertWithTitle:(NSString *)title message:(NSString *)message confirm:(void(^)())confirm
{
    [self alertWithTitle:title message:message yes:NSLocalizedString(@"confirm_ok", nil) confirm:confirm];
}

+(void)alertWithTitle:(NSString *)title message:(NSString *)message yes:(NSString *)yes confirm:(void(^)())confirm
{
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                       cancelButtonItem:[RIButtonItem itemWithLabel:yes action:^
                       {
                           if (confirm)
                           {
                               confirm();
                           }
                       }]
                       otherButtonItems:nil] show];
}
+(void)alertWithTitle:(NSString *)title message:(NSString *)message yes:(NSString *)yes no:(NSString *)no confirm:(void(^)())confirm
{
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                       cancelButtonItem:[RIButtonItem itemWithLabel:no action:^
                                         {
                                       
                                         }]
                       otherButtonItems:[RIButtonItem itemWithLabel:yes action:^
                                         {
                                             if (confirm)
                                             {
                                                 confirm();
                                             }
                                         }],nil] show];

}



@end