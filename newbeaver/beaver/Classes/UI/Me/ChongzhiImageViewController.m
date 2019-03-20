//
//  ChongzhiImageViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/20.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "ChongzhiImageViewController.h"
#import "UIImageView+WebCache.h"
#import "CreateQRManager.h"
#import "DiSanFangHuJiaoViewController.h"

@interface ChongzhiImageViewController ()

@property (nonatomic, strong) UIImageView * background;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, assign) BOOL isZhifu;//是否可以支付
@property (nonatomic, strong) UILabel * tip;

@end

@implementation ChongzhiImageViewController

- (void)setUI{
    
    
    _background = [UIImageView new];
    _background.userInteractionEnabled = YES;
    _background.image = [UIImage imageNamed:@"hidden_pay_background"];
    
    CGFloat x = 15;
    CGFloat y = 15;
    CGFloat h = 20;
    CGFloat img_h = (( kScreenW - 30 ) * 923.0) / 689.0;
    
    if (kScreenW == 320) {
        img_h += 30;
    }
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    
    [self.view addSubview:_background];
    _background.sd_layout
    .topSpaceToView(self.view, 30)
    .rightSpaceToView(self.view, x)
    .leftSpaceToView(self.view, x)
    .heightIs(img_h);
    
    UIImageView *icon = [UIImageView new];
    if ([_payType isEqualToString:@"支付宝"]) {
        icon.image = [UIImage imageNamed:@"hidden_zhifubao"];
    }else{
        icon.image = [UIImage imageNamed:@"hidden_weixin_finish"];
    }
    
    
    UILabel * typeLable = [UILabel new];
    typeLable.text = [NSString stringWithFormat:@"%@支付码",_payType];
    typeLable.textAlignment = NSTextAlignmentLeft;
    typeLable.font = font;
    typeLable.textColor = UIColorFromRGB(0x333333);
    [self.view addSubview:typeLable];
    
    self.imageView = [UIImageView new];
    self.imageView.layer.cornerRadius = 5.0f;
    
    UIImage *image = [CreateQRManager showQRCodeWithImageWidth:180.f andDataStr:self.imageStr];
    
    
    self.imageView.userInteractionEnabled = YES;
    self.imageView.clipsToBounds = YES;
    self.imageView.image = image;
//    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_imageStr]];
    self.imageView.centerX = self.view.centerX;
    self.imageView.mj_y = CGRectGetMaxY(typeLable.frame)+y;
    
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTouchAction:)];
   
    [self.imageView addGestureRecognizer:tap];
    
    UILabel * countLable = [UILabel new];
    countLable.text = [NSString stringWithFormat:@"%@账号: %@",_type,_payCount];
    countLable.textAlignment = NSTextAlignmentLeft;
    countLable.font = font;
    countLable.textColor = UIColorFromRGB(0x333333);
    
    UILabel * priceLable = [UILabel new];
    
    NSString *priceStr = [NSString stringWithFormat:@"%@金额: %@ 元",_type,_payNum];
    
    NSMutableAttributedString *priceAttributedStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
    [priceAttributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x333333) range:NSMakeRange(0, _type.length+4)];
    [priceAttributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(_type.length+4, _payNum.length)];
    
    [priceAttributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x333333) range:NSMakeRange(_type.length+4 + _payNum.length, priceStr.length-(_type.length+4 + _payNum.length))];
    
    [priceAttributedStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, priceStr.length)];
    priceLable.attributedText = priceAttributedStr;
    priceLable.textAlignment = NSTextAlignmentLeft;
    priceLable.font = font;
    
    //提示
    
    UILabel * tiptitle = [UILabel new];
  
    tiptitle.font = [UIFont systemFontOfSize:15.0f];
    tiptitle.textColor = UIColorFromRGB(0xff3800);
    tiptitle.textAlignment = NSTextAlignmentLeft;
    tiptitle.text = @"*充值方法（二选一）：";
    
    _tip = [UILabel new];

    _tip.font = [UIFont systemFontOfSize:15.0f];
    _tip.textColor = UIColorFromRGB(0x333333);
    _tip.textAlignment = NSTextAlignmentLeft;
    _tip.numberOfLines = 0;
    NSString *tipStr = @"";
    if ([_payType isEqualToString:@"支付宝"]) {
        tiptitle.text = @"*充值方法：";
        tipStr = @"1、长按二维码进行充值。";
    }else{
        tiptitle.text = @"*充值方法（二选一）：";
        tipStr = @"1.微信扫一扫。\n2.保存二维码图片，在微信中打开，长按二维码进行充值。";
    }
    
    
    _tip.text = tipStr;
//    [self.view addSubview:_tip];
    
    [_background sd_addSubviews:@[icon,typeLable,_imageView,countLable,priceLable,tiptitle,_tip]];
    
    icon.sd_layout
    .leftSpaceToView(_background, x)
    .topSpaceToView(_background, y-5)
    .widthIs(30)
    .heightIs(30);
    
    typeLable.sd_layout
    .leftSpaceToView(icon, x-2)
    .topSpaceToView(_background, y)
    .widthIs(150)
    .heightIs(h);
    
    
    if (kScreenW == 320) {
        _imageView.sd_layout
        .centerXEqualToView(_background)
        .topSpaceToView(typeLable, 20)
        .widthIs(180)
        .heightIs(180);
        
        countLable.sd_layout
        .leftSpaceToView(_background, x)
        .topSpaceToView(_imageView, 10)
        .widthIs(kScreenW-60)
        .heightIs(h);
        
        priceLable.sd_layout
        .leftSpaceToView(_background, x)
        .topSpaceToView(countLable, 10)
        .widthIs(kScreenW-60)
        .heightIs(h);
        
    }else{
        _imageView.sd_layout
        .centerXEqualToView(_background)
        .topSpaceToView(typeLable, 35)
        .widthIs(180)
        .heightIs(180);

        countLable.sd_layout
        .leftSpaceToView(_background, x)
        .topSpaceToView(_imageView, 15)
        .widthIs(kScreenW-60)
        .heightIs(h);
    
        priceLable.sd_layout
        .leftSpaceToView(_background, x)
        .topSpaceToView(countLable, 10)
        .widthIs(kScreenW-60)
        .heightIs(h);
    }
    
    
    if ([_payType isEqualToString:@"支付宝"]) {
        _tip.sd_layout
        .leftSpaceToView(_background, x)
        .rightSpaceToView(_background, x)
        .bottomSpaceToView(_background, x+45)
        .heightIs(20);
    }else{
        _tip.sd_layout
        .leftSpaceToView(_background, x)
        .rightSpaceToView(_background, x)
        .bottomSpaceToView(_background, x+5)
        .heightIs(60);
    }
    
    
     tiptitle.sd_layout
    .leftSpaceToView(_background, x)
    .rightSpaceToView(_background, x)
    .bottomSpaceToView(_tip, 8)
    .heightIs(20);
    
   

}

-(UIImage*)imageFromView:(UIView*)view{
    
    CGSize s = view.bounds.size;

    
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        [EBAlert alertSuccess:@"存入手机相册成功" length:2.0f];
    }else{
        [EBAlert alertError:@"存入手机相册失败" length:2.0f];
    }
    
//    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"温馨提示" message:tip preferredStyle:UIAlertControllerStyleAlert];
//    [alertControler addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSLog(@"完成");
//    }]];
//    [self presentViewController:alertControler animated:YES completion:nil];
    
}

- (void)rightClick{
    NSLog(@"保存图片");
    
    [self saveImageToPhotos:[self imageFromView:self.view]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addRightNavigationBtnWithTitle:@"保存图片" target:self action:@selector(rightClick)];
    self.isZhifu = YES;
    self.view.backgroundColor = UIColorFromRGB(0xff3800);
    self.title = [NSString stringWithFormat:@"%@",_type];
    
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

- (void)longTouchAction:(UILongPressGestureRecognizer *)sender {
    
    
    if (self.isZhifu) {
        if (![_payType isEqualToString:@"支付宝"]) {
//            [self zhifuFinish];
        }else{//微信
            self.isZhifu = NO;
            NSString *resultOfQR = [CreateQRManager touchQRImageGetStringWithImage:self.imageView.image];
            NSLog(@"识别二维码的内容为：%@",resultOfQR);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:resultOfQR]];
            [self zhifuFinish];
        }
        
    }
}

- (void)zhifuFinish{
    //弹窗
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"支付结果" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"支付完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController * vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[DiSanFangHuJiaoViewController class]]) {
                DiSanFangHuJiaoViewController *diSanVC = (DiSanFangHuJiaoViewController *)vc;
                [self.navigationController popToViewController:diSanVC animated:YES];
            }
        }
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
