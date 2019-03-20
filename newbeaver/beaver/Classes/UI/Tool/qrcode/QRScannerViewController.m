//
//  QRScannerViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "QRScannerViewController.h"
#import "QRScannerView.h"
#import "ConfirmLoginViewController.h"
#import "EBCrypt.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "ERPWebViewController.h"

#import "NewQRScannerViewController.h"
@interface QRScannerViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>


@end

@implementation QRScannerViewController

- (UIBarButtonItem *)addRightNavigationBtnWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:UIBarButtonItemStylePlain target:target action:action];
    [item setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = item;
    
    return item;
}


- (void)loadView
{
    [super loadView];
   
    [self newSQ];
}

- (void)newSQ
{
    //创建参数对象
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    
    //矩形区域中心上移，默认中心点为屏幕中心点
    style.centerUpOffset = 44;
    
    //扫码框周围4个角的类型,设置为外挂式
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    
    //扫码框周围4个角绘制的线条宽度
    style.photoframeLineW = 6;
    
    //扫码框周围4个角的宽度
    style.photoframeAngleW = 24;
    
    //扫码框周围4个角的高度
    style.photoframeAngleH = 24;
    
    //扫码框内 动画类型 --线条上下移动
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //线条上下移动图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    
    //SubLBXScanViewController继承自LBXScanViewController
    //添加一些扫码或相册结果处理
    NewQRScannerViewController  *vc = [NewQRScannerViewController new];
    
    if (_is_JuhePay == YES) {
        [self addRightNavigationBtnWithTitle:@"跳过扫码" target:vc action:@selector(juhePayItem:)];
    }

    vc.is_JuhePay = _is_JuhePay;
    
    vc.style = style;
    vc.isOpenInterestRect = YES;
    [self addChildViewController:vc];
    [self.view addSubview: vc.view];
 
}

@end
