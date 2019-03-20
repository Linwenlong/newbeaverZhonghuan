//
//  MyRecommendViewController.m
//  beaver
//
//  Created by mac on 17/6/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyRecommendViewController.h"
#import "SDAutoLayout.h"
#import "HWPopTool.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <UShareUI/UShareUI.h>

@interface MyRecommendViewController ()

@property (nonatomic, strong)UIImageView *top_ImageView;
@property (nonatomic, strong)UIImageView *recommend_ImageView;
@property (nonatomic, strong)UILabel *recommend_Count;

@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UIView *popView;
@property (nonatomic,strong) UIImageView *qrImageView;

@end

@implementation MyRecommendViewController



- (void)setUI{
    
    self.title = @"我要推荐";
    
    NSArray *keys = @[@"QQ",@"微信",@"面对面推荐"];
    NSArray *values = @[@"QQ",@"WeChat",@"QRcode"];

    _top_ImageView = [UIImageView new];
    _top_ImageView.image = [UIImage imageNamed:@"背景图.png"];
    [self.view addSubview:_top_ImageView];
    _containerView = [UIView new];
    [self.view addSubview:_containerView];
    
    //hidden lwl
    _recommend_ImageView = [UIImageView new];
    _recommend_ImageView.image = [UIImage imageNamed:@"Recommend.png"];
    _recommend_ImageView.hidden = YES;
    [self.view addSubview:_recommend_ImageView];
    
 
    _recommend_Count = [UILabel new];
    _recommend_Count.text = @"已成功推荐:         68人";
    _recommend_Count.hidden = YES;
    _recommend_Count.textColor = UIColorFromRGB(0x808080);
    _recommend_Count.font = [UIFont systemFontOfSize:14.0f];
    _recommend_Count.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_recommend_Count];
    
    //设置imageview
    _top_ImageView.sd_layout
    .topSpaceToView(self.view,0)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .heightIs(kScreenW*362/750);
    
    _recommend_ImageView.sd_layout
    .topSpaceToView(_top_ImageView,20)
    .leftSpaceToView(self.view,20)
    .widthIs(32/2)
    .heightIs(34/2);
    
    _recommend_Count.sd_layout
    .topSpaceToView(_top_ImageView,20)
    .leftSpaceToView(_recommend_ImageView,20)
    .widthIs(kScreenW - CGRectGetMaxX(_recommend_ImageView.frame)-20)
    .heightIs(34/2);

    
    
    //自动排列下面的三个按钮
    NSMutableArray *tmp = [NSMutableArray array];
    for (int i = 0 ; i < 3 ;  i++) {
        UIButton *button = [UIButton new];
        button.tag = i;
        [_containerView addSubview:button];
        button.sd_layout.autoHeightRatio(1.2);
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitle:keys[i] forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    
        [button setImage:[UIImage imageNamed:values[i]] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.contentMode = UIViewContentModeScaleAspectFit;
        button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
         button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        button.imageView.sd_layout
        .widthRatioToView(button, 0.6)
        .topSpaceToView(button, 10)
        .centerXEqualToView(button)
        .heightRatioToView(button, 0.6);
        
        // 设置button的label的约束
        button.titleLabel.sd_layout
        .topSpaceToView(button.imageView, 15)
        .leftEqualToView(button)
        .rightEqualToView(button)
        .bottomSpaceToView(button, 5);
        [tmp addObject:button];
    }
    
    [_containerView  setupAutoMarginFlowItems:[tmp copy] withPerRowItemsCount:3 itemWidth:90 verticalMargin:10 verticalEdgeInset:5 horizontalEdgeInset:30];
    
    //高度自适应
    _containerView.sd_layout
    .topSpaceToView(_recommend_ImageView,10)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //设置布局
    [self setUI];
}

#pragma mark -- Buttons点击

- (void)buttonAction:(UIButton *)btn{
    switch (btn.tag) {
        case 0:
            //qq
            [self qq];
            break;
        case 1:
            //微信
            [self weixin];
            break;
        case 2:
            //二维码
            [self QRCode];
            break;
        default:
            break;
    }
}

- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    NSLog(@"error = %@",error.userInfo);
  
    if (!error) {
        //result = [NSString stringWithFormat:@"Share succeed"];  //原代码
        result = [NSString stringWithFormat:@"分享成功"];
    }
    else{
        NSMutableString *str = [NSMutableString string];
        if (error.userInfo) {
            for (NSString *key in error.userInfo) {
                [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
            }
        }
        if (error) {
            //result = [NSString stringWithFormat:@"Share fail with error code: %d\n%@",(int)error.code, str];  //原代码
            
            //NSLog(@"分享出错信息: %@",error);
            if (error.code == 2009) {
                result = [NSString stringWithFormat:@"分享取消"];
            } else if(error.code == 2008){
                result = @"请检查是否安装了QQ";
            }else{
                result = [NSString stringWithFormat:@"Share fail with error code: %d\n%@",(int)error.code, str];
            }
        }
        else{
            result = [NSString stringWithFormat:@"Share fail"];
        }
    }
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"share" message:result delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"确定") otherButtonTitles:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
}


-(void)shareType:(UMSocialPlatformType)type content:(NSDictionary *)shareConfig{

    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    NSString *title = shareConfig[@"title"];
    NSString *desc = shareConfig[@"text"];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:nil];
    
    //设置网页地址
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@",shareConfig[@"url"]];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
       
        [self alertWithError:error];
    }];

}


- (void)qq{
    UIImage *image = [UIImage imageNamed:@"im_eall_logo.png"];
    NSString *url = @"http://218.65.86.92:8003/download/zheke?nsukey=q1tG2NSQDXeE4PajS61J%2FXIw2e7V3evwV1S7x50KsTE3eHCtgo%2FaBA8CaRsvc9TtOEibFMFyHj0%2FFqUVS8ZHQ2YvFqPAZHoE5F%2BZA1RQ1xfuXRis0z59097VmnAgMLxGLNQvJyLddHBvYnV%2FVnJ%2FhQ%3D%3D";
    //    NSString *url = @"https://itunes.apple.com/app?id=1114438676";
    NSDictionary *shareConfig = @{
                                    @"image":image,
                                    @"url":url,
                                    @"title":@"中环e家",
      };

    [self shareType:UMSocialPlatformType_QQ content:shareConfig];
}



- (void)weixin{
    
        UIImage *image = [UIImage imageNamed:@"im_eall_logo.png"];
        NSString *url = @"http://218.65.86.92:8003/download/zheke?nsukey=q1tG2NSQDXeE4PajS61J%2FXIw2e7V3evwV1S7x50KsTE3eHCtgo%2FaBA8CaRsvc9TtOEibFMFyHj0%2FFqUVS8ZHQ2YvFqPAZHoE5F%2BZA1RQ1xfuXRis0z59097VmnAgMLxGLNQvJyLddHBvYnV%2FVnJ%2FhQ%3D%3D";
        //    NSString *url = @"https://itunes.apple.com/app?id=1114438676";
        NSDictionary *shareConfig = @{
                                  @"image":image,
                                  @"url":url,
                                  @"title":@"中环e家",
                                  @"text":@"买房卖房就找中环e家"
                                  };
        [self shareType:UMSocialPlatformType_WechatSession content:shareConfig];
}

- (void)closePop:(UITapGestureRecognizer *)tap{
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        NSLog(@"已经关闭");
    }];
}

- (void)QRCode{
    //先生成视图
    _popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 350)];;
    _popView.backgroundColor = [UIColor whiteColor];
    _popView.layer.cornerRadius = 7.0f;
    _qrImageView = [UIImageView new];
    [_popView addSubview:_qrImageView];
    UILabel *lable = [UILabel new];
    lable.text = @"扫一扫 , 即可下载中环e家";
    lable.font = [UIFont systemFontOfSize:18.0f];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor blackColor];
    [_popView addSubview:lable];
    
    _qrImageView.sd_layout
    .topSpaceToView(_popView,30)
    .leftSpaceToView(_popView,30)
    .rightSpaceToView(_popView,30)
    .heightIs(240);
    
    lable.sd_layout
    .topSpaceToView(_qrImageView,20)
    .leftSpaceToView(_popView,0)
    .rightSpaceToView(_popView,0)
    .heightIs(40);
    
    //动画弹窗
    MyViewController *vc = [[HWPopTool sharedInstance] showWithPresentView:_popView animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop:)];
    vc.styleView.userInteractionEnabled = YES;
    [vc.styleView addGestureRecognizer:tap];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];//可能滤镜里面有之前设置的key-value，用这个来初始化key—value
//    NSString *str = @"https://itunes.apple.com/app?id=1114438676";
    NSString *str = @"http://218.65.86.92:8003/download/zheke?nsukey=q1tG2NSQDXeE4PajS61J%2FXIw2e7V3evwV1S7x50KsTE3eHCtgo%2FaBA8CaRsvc9TtOEibFMFyHj0%2FFqUVS8ZHQ2YvFqPAZHoE5F%2BZA1RQ1xfuXRis0z59097VmnAgMLxGLNQvJyLddHBvYnV%2FVnJ%2FhQ%3D%3D";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    NSLog(@"w = %f",_qrImageView.frame.size.width);
    UIImage *image = [self changeImageSizeWithCIImage:[filter outputImage] andSize:240];
    NSLog(@"image = %@",[UIImage imageWithCIImage:[filter outputImage]]);
    if (image) {
        _qrImageView.image = image;
    }
}

- (UIImage *)changeImageSizeWithCIImage:(CIImage *)ciImage andSize:(CGFloat)size{
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    
    return [UIImage imageWithCGImage:scaledImage];
}


@end
