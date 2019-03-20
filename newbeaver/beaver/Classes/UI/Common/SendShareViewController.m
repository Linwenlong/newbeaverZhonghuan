//
//  QRScannerViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "SendShareViewController.h"
#import "EBIconLabel.h"
#import "ShareManager.h"
#import <UShareUI/UShareUI.h>

@interface SendShareViewController() <UITextViewDelegate>
@end

@implementation SendShareViewController
{
    UITextView *_contentView;
    UILabel *_countLabel;
}

- (void)loadView
{
    [super loadView];

    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_send"] target:self action:@selector(send:)];

    CGFloat yOffset = 15;

    _contentView = [[UITextView alloc] initWithFrame:CGRectMake(15, yOffset, [EBStyle screenWidth] - 30 , 165)];
    _contentView.layer.borderColor = [EBStyle grayClickLineColor].CGColor;
    _contentView.layer.borderWidth = 1.0;
    _contentView.delegate = self;
    _contentView.font = [UIFont systemFontOfSize:16];
    _contentView.textColor = [EBStyle blackTextColor];
    [self.view addSubview:_contentView];

    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 45, 160, 30, 20)];
    _countLabel.font = [UIFont systemFontOfSize:16.0];
    _countLabel.textColor = [EBStyle grayTextColor];
    [self.view addSubview:_countLabel];

    if (!_CheckLabelHidden)
    {
        yOffset += _contentView.frame.size.height + 10;
        
        EBIconLabel *checkLabel1 = [[EBIconLabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290, 30)];
        checkLabel1.iconPosition = EIconPositionLeft;
        checkLabel1.gap = 5;
        checkLabel1.imageView.image = [UIImage imageNamed:@"icon_tick"];
        checkLabel1.label.textColor = [EBStyle blackTextColor];
        checkLabel1.label.text = NSLocalizedString(@"share_with_url", nil);
        checkLabel1.label.font = [UIFont systemFontOfSize:16.f];
        checkLabel1.iconVerticalCenter = YES;
        [self.view addSubview:checkLabel1];
        
        yOffset += 20;
        EBIconLabel *checkLabel2 = [[EBIconLabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290, 30)];
        checkLabel2.iconPosition = EIconPositionLeft;
        checkLabel2.gap = 5;
        checkLabel2.imageView.image = [UIImage imageNamed:@"icon_tick"];
        checkLabel2.label.textColor = [EBStyle blackTextColor];
        checkLabel2.label.text = NSLocalizedString(@"share_with_long_weibo", nil);
        checkLabel2.label.font = [UIFont systemFontOfSize:16.f];
        checkLabel2.iconVerticalCenter = YES;
        [self.view addSubview:checkLabel2];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _contentView.text = _content[@"text"];
    [_contentView becomeFirstResponder];
}

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [image drawInRect:imageRect];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

- (void)send:(UIButton *)btn
{
    [_contentView resignFirstResponder];
    _content[@"text"] = _contentView.text;
    //分享到新浪
    
    NSDictionary * shareConfig = _content;
    NSLog(@"点击了分享按钮: %@",shareConfig);
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString *title = @"分享房源";
    NSString *desc = shareConfig[@"text"];
    
    
    UIImage *img = [self resizeImage:shareConfig[@"image"] size:CGSizeMake(15, 15)];
    
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:img];
    
    //设置网页地址
    shareObject.webpageUrl =shareConfig[@"url"];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    NSLog(@"self = %@",self);
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
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
//        [self alertWithError:error];
    }];

    
////    [[ShareManager sharedInstance] shareContent:_content
//                                       withType:self.shareType
//                                        handler:self.shareHandler];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
   _countLabel.text = [NSString stringWithFormat:@"%ld", 140 - _contentView.text.length];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{

}

- (void)textViewDidChange:(UITextView *)textView
{
    _countLabel.text = [NSString stringWithFormat:@"%ld", 140 - _contentView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (_contentView.text.length >= 140 && text.length > 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
