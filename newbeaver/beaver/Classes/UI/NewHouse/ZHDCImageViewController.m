//
//  ZHDCImageViewController.m
//  CentralManagerAssistant
//
//  Created by mac on 17/2/16.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//

#import "ZHDCImageViewController.h"
#import "SDAutoLayout.h"
#import "UIImageView+WebCache.h"

@interface ZHDCImageViewController ()

@end

@implementation ZHDCImageViewController




#pragma mark -- Cycle Life

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"客厅";
    [self addRightNavigationBtnWithTitle:@"保存" target:self action:@selector(save)];
    [self seToolBar];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)seToolBar{
    UILabel *leftLable = [UILabel new];
    leftLable.font = [UIFont systemFontOfSize:16.0f];
    leftLable.textColor = [UIColor whiteColor];
    leftLable.textAlignment = NSTextAlignmentLeft;
    leftLable.text = @"查看原图";
    [self.view addSubview:leftLable];
    
    UILabel *centerLable = [UILabel new];
    centerLable.font = [UIFont systemFontOfSize:16.0f];
    centerLable.textColor = [UIColor whiteColor];
    centerLable.text = [NSString stringWithFormat:@"%d/%ld",1,self.imageArray.count ];
    centerLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:centerLable];
    
//    UIImageView *rightImageView = [UIImageView new];
//    rightImageView.image = [UIImage imageNamed:@"操作"];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
//    rightImageView.userInteractionEnabled = YES;
//    [rightImageView addGestureRecognizer:tap];
//    [self.view addSubview:rightImageView];
    
    //约束
    CGFloat spacing = 10;
    CGFloat y = 15;
    CGFloat h = 20;
    leftLable.sd_layout
    .leftSpaceToView(self.view,spacing)
    .bottomSpaceToView(self.view,y)
    .widthIs(100)
    .heightIs(h);
    
    CGFloat centerLableW = 60;
    centerLable.sd_layout
    .leftSpaceToView(self.view,(kScreenW-centerLableW)/2.0)
    .bottomSpaceToView(self.view,y)
    .widthIs(centerLableW)
    .heightIs(h);
    
//    rightImageView.sd_layout
//    .rightSpaceToView(self.view,spacing)
//    .bottomSpaceToView(self.view,y)
//    .widthIs(h)
//    .heightIs(h);
    
    UIImage *image = [UIImage imageNamed:@"sy_60294738471.jpg"];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 300)];
    imageView.center  = self.view.center;
    imageView.top = imageView.top-64;
    imageView.image = image;
     imageView.userInteractionEnabled = YES;
    //添加长按手势
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
    longTap.minimumPressDuration = 1;
    [imageView addGestureRecognizer:longTap];
    [self.view addSubview:imageView];
}
//保存
- (void)save{
    [self createImage];
}

#pragma mark -- imageClick
- (void)imageClick:(id)tap{
    //弹窗提示退出
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
    UIAlertAction *sheetAction2 = [UIAlertAction actionWithTitle:@"保存图片"  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"保存图片");
        [self createImage];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:sheetAction2];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)createImage{
    //保存图片
    UIImage *image = [self imageFromView:self.view];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (UIImage*)imageFromView:(UIView*)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.layer.contentsScale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
