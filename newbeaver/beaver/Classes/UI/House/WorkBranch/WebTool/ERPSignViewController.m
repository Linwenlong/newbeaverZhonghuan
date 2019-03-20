//
//  ERPSignViewController.m
//  chowRentAgent
//
//  Created by 凯文马 on 15/11/16.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#import "ERPSignViewController.h"
#import "PJRSignatureView.h"
#import "PJRSignatureView.h"
#import "EBStyle.h"
#import "JSONKit.h"
#import "EBHttpClient.h"
#import "EBHousePhoto.h"
#import "EBUtil.h"
#import "EBAlert.h"
#import "SDImageCache.h"
#import "EBController.h"

@interface ERPSignViewController ()<PJRSignatureDelegate>
{
    PJRSignatureView *_signatureView;
    UIBarButtonItem *_finishBtn;
}

@end

@implementation ERPSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"签名确认";
    _finishBtn = [self addRightNavigationBtnWithTitle:@"完成" target:self action:@selector(finish)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"重签"
                                                             style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
    [item setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItems = @[_finishBtn,item];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    _signatureView = [[PJRSignatureView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:_signatureView];
    _signatureView.delegate = self;
    _finishBtn.enabled = NO;
}

- (void)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PJRSignatureDelegate
- (void)PJRSignatureSign:(PJRSignatureView *)signatureView
{
    _finishBtn.enabled = YES;
}

#pragma mark - action
- (void)clear
{
    _finishBtn.enabled = NO;
    [_signatureView clearSignature];
}

- (void)finish
{
    UIImage *image = [_signatureView getSignatureImage];
    if (!image) {
        [EBAlert alertError:@"请手写您的姓名"];
        return;
    }
    [self uploadSign:image finish:^(NSString *url) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.commitAction) {
            self.commitAction(url);
        }
    }];
}

#pragma mark - photo upload
- (void)uploadSign:(UIImage *)image finish:(void(^)(NSString *url))finish
{
    [EBAlert showLoading:nil allowUserInteraction:NO];
    [[EBHttpClient sharedInstance] dataRequest:nil uploadImage:image withHandler:^(BOOL success, id result)
     {
         [EBAlert hideLoading];
         if (success)
         {
             NSDictionary *data = (NSDictionary *)result;
             NSString *url = data[@"url"];
             if (url && url.length) {
                 finish(url);
             } else {
                 [EBAlert alertError:@"上传图片失败"];
             }
         } else {
            [EBAlert alertError:@"上传图片失败"];
         }
     }];
}

#pragma mark - rotation
- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
