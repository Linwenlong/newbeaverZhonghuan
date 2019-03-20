//
//  ZHTestViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "ZHTestViewController.h"
#import "HWPopTool.h"
#import "UIImageView+WebCache.h"
#import "ChongzhiImageViewController.h"
#import "DiSanFangHuJiaoViewController.h"

#import "CreateQRManager.h"

@interface ZHTestViewController ()

@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UIView * popView;


@property (nonatomic, strong) NSString * payMonney;//充值金额

@property (nonatomic, strong) NSMutableArray * btns;

@property (nonatomic, weak) UIButton * lastBtn;

@end

@implementation ZHTestViewController

- (UIView *)maskView{
    if (!_maskView) {
        
        _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.hidden = YES;
        _maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _popView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH, kScreenW, 240)];
        _popView.backgroundColor = [UIColor whiteColor];
        [_maskView addSubview:_popView];
        
        CGFloat x = 15;
        CGFloat y = x;
        CGFloat h = 20;
        UIFont *font = [UIFont systemFontOfSize:18.0f];
        
        UILabel * yue = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kScreenW/2, h)];
        yue.backgroundColor = [UIColor whiteColor];
        yue.centerX = _popView.centerX;
        yue.text = @"请选择付款方式";
        yue.textAlignment = NSTextAlignmentCenter;
        yue.font = font;
        yue.textColor = [UIColor blackColor];
        [_popView addSubview:yue];
        
        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, h, h)];
        imageIcon.image = [UIImage imageNamed:@"hidden_chacha"];
        imageIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePopview)];
        [imageIcon addGestureRecognizer:tap];
        [_popView addSubview:imageIcon];
        
        //线3
        UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yue.frame)+15, kScreenW, 1)];
        line3.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
        [_popView addSubview:line3];
        
        UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(line3.frame)+10, kScreenW-2*x, 40)];
        btn2.tag = 2;
        btn2.titleLabel.font = font;
        btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        NSString *zhifubaostr = @"支付宝充值(推荐支付)";
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:zhifubaostr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 5)];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(5, zhifubaostr.length-5)];
        [btn2 setAttributedTitle:attributedStr forState:UIControlStateNormal];
        
//        [btn2 setTitle:@"支付宝充值" forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:@"hidden_zhifubao"] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(chongzhifinish:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btn2];
        
        //button
//        UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(line3.frame)+10, kScreenW-2*x, 40)];
//        btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        btn1.tag = 1;
//        btn1.titleLabel.font = font;
//        
//        //        [btn1 setImage:[UIImage imageNamed:@"买卖房源"] forState:UIControlStateNormal];
//        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn1 setTitle:@"微信充值" forState:UIControlStateNormal];
//        [btn1 setImage:[UIImage imageNamed:@"hidden_weixin"] forState:UIControlStateNormal];
//        [btn1 addTarget:self action:@selector(chongzhifinish:) forControlEvents:UIControlEventTouchUpInside];
//        [_popView addSubview:btn1];
        
        //线4
        UIView *line4 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(btn2.frame)+10, kScreenW, 1)];
        line4.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
        [_popView addSubview:line4];
        
        
//        UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(line4.frame)+10, kScreenW-2*x, 40)];
//        btn2.tag = 2;
//        btn2.titleLabel.font = font;
//        btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn2 setTitle:@"支付宝充值" forState:UIControlStateNormal];
//        [btn2 setImage:[UIImage imageNamed:@"hidden_zhifubao"] forState:UIControlStateNormal];
//        [btn2 addTarget:self action:@selector(chongzhifinish:) forControlEvents:UIControlEventTouchUpInside];
//        [_popView addSubview:btn2];
        
        UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(line4.frame)+10, kScreenW-2*x, 40)];
        btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn1.tag = 1;
        btn1.titleLabel.font = font;
        
        //        [btn1 setImage:[UIImage imageNamed:@"买卖房源"] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn1 setTitle:@"微信充值" forState:UIControlStateNormal];
        [btn1 setImage:[UIImage imageNamed:@"hidden_weixin"] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(chongzhifinish:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btn1];
        
    }
    return _maskView;
}

- (void)setUI{
    
    CGFloat x = 15;
    CGFloat y = x;
    CGFloat h = 20;
    
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    
    //    if (kScreenW == 320) {
    //        font = [UIFont systemFontOfSize:16.0f];
    //    }else{
    //        font = [UIFont systemFontOfSize:18.0f];
    //    }
    
    UILabel * yue = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kScreenW/2.0f, h)];
    yue.text = @"话费余额: ";
    yue.textAlignment = NSTextAlignmentLeft;
    yue.font = font;
    yue.textColor = UIColorFromRGB(0x333333);
    [self.view addSubview:yue];
    
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW/2.0f, y, kScreenW/2.0f-15, h)];
    
    NSString *countStr = [NSString stringWithFormat:@"%@ 元",_totle_price ];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:countStr];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff3800) range:NSMakeRange(0, _totle_price.length)];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x333333) range:NSMakeRange(_totle_price.length,countStr.length - _totle_price.length)];
    count.attributedText = attributedStr;
    count.textAlignment = NSTextAlignmentRight;
    count.font = font;
    [self.view addSubview:count];
    
    //线1
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yue.frame)+15, kScreenW, 1)];
    line.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [self.view addSubview:line];
    
    UILabel * yuechongzhi = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(line.frame)+15, 90, h)];
    yuechongzhi.text = @"话费充值:";
    yuechongzhi.textAlignment = NSTextAlignmentLeft;
    yuechongzhi.font = font;
    yuechongzhi.textColor = [UIColor blackColor];
    [self.view addSubview:yuechongzhi];
    
    CGFloat btn_h = 0;
    if (kScreenW == 320) {
        btn_h = 50;
    }else{
        font = [UIFont systemFontOfSize:18.0f];
        btn_h = 60;
    }
    
//    NSArray *btns = @[@"10元",@"20元",@"50元",@"100元",@"500元"];
    NSArray *btns = @[@"10元",@"20元",@"50元",@"100元",@"200元",@"500元"];
    CGFloat btn_spcing = 5;
    CGFloat btn_w = (kScreenW - x*2 -2*btn_spcing)/3.0f;
    
    for (int i = 0; i < btns.count; i++) {
        
        CGFloat  btn_x = x + (btn_spcing+btn_w) * (i % 3);
        CGFloat btn_y = y+CGRectGetMaxY(yuechongzhi.frame) + (i/3)*(btn_spcing+btn_h);
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(btn_x, btn_y, btn_w, btn_h)];
        _lastBtn = btn;
        [self.btns addObject:btn];
        btn.tag = 1;
        btn.titleLabel.font = font;
        btn.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
        btn.layer.borderWidth = 1.0f;
        btn.layer.cornerRadius = 5.0f;
        [btn setTitleColor:UIColorFromRGB(0xff3800) forState:UIControlStateNormal];
        [btn setTitle:btns[i] forState:UIControlStateNormal];//需要改成10
        [btn addTarget:self action:@selector(chongzhi:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"话费充值";
    self.btns = [NSMutableArray array];
    [self setUI];
    [self.view addSubview:self.maskView];
}



- (void)chongzhi:(UIButton *)btn{
    NSLog(@"btn = %@",btn.titleLabel.text);
    
    for (UIButton *tmpBtn in _btns) {
        tmpBtn.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
        [tmpBtn setTitleColor:UIColorFromRGB(0xff3800) forState:UIControlStateNormal];
        tmpBtn.backgroundColor = [UIColor whiteColor];
    }
    
    btn.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = UIColorFromRGB(0xff3800);
    //获取上面的元
    NSArray *tmpArr = [btn.titleLabel.text componentsSeparatedByString:@"元"];
    _payMonney = tmpArr.firstObject;
    NSLog(@"_pa=%@",_payMonney);
    NSLog(@"popview = %f",_popView.mj_y);
    [UIView animateWithDuration:.5 animations:^{
        _maskView.hidden = NO;
        _popView.mj_y = kScreenH - _popView.height;
    }];
}

-(UIImage *) getImageFromURL:(NSString *)fileURL

{
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
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

- (void)chongzhifinish:(UIButton *)btn{
    NSLog(@"btn = %@",btn.titleLabel.text);
    [UIView animateWithDuration:.5 animations:^{
        _popView.mj_y = kScreenH;
        _maskView.hidden = YES;
    }];
    NSArray *tmpArr = nil;
    if (btn.tag == 1) {
        tmpArr = [btn.titleLabel.text componentsSeparatedByString:@"充值"];
    }else{
        tmpArr = [btn.titleLabel.attributedText.string componentsSeparatedByString:@"充值"];
    }

    if (_firstRecharge == YES) {
        if ([_payMonney integerValue] < 200) {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"您本次首次充值,充值金额需不少于200元" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return;
        }
    }
    
    NSString *urlStr = @"call/recharge";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    NSDictionary *param = @{
                            @"token":[EBPreferences sharedInstance].token,
                            @"bind_phone":_bind_phone,
                            @"type":[NSString stringWithFormat:@"%@",@"1"],
                            @"money":_payMonney,
                            @"pay_type":tmpArr.firstObject,
                            };
    
    
    
    NSLog(@"param=%@",param);
    [HttpTool get:urlStr parameters:param success:^(id responseObject) {
        [EBAlert hideLoading];
        NSLog(@"responseObject=%@",responseObject);
        
        if ([responseObject[@"code"]integerValue] == 0) {
            for (UIButton *tmpBtn in _btns) {
                tmpBtn.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
                [tmpBtn setTitleColor:UIColorFromRGB(0xff3800) forState:UIControlStateNormal];
                tmpBtn.backgroundColor = [UIColor whiteColor];
            }
            if ([tmpArr.firstObject isEqualToString:@"支付宝"]) {
                
                
                ChongzhiImageViewController *vc = [[ChongzhiImageViewController alloc]init];
                vc.payNum = _payMonney;
                vc.payType = tmpArr.firstObject;
                vc.type = @"话费充值";
                vc.imageStr = responseObject[@"data"][@"data"];
                vc.payCount = _bind_phone;
                [self.navigationController pushViewController:vc animated:YES];
                
//                NSString *imageStr = responseObject[@"data"][@"data"];
//                NSString *resultOfQR = [CreateQRManager touchQRImageGetStringWithImage:[self getImageFromURL:imageStr]];
//                NSLog(@"识别二维码的内容为：%@",resultOfQR);
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:resultOfQR]];
//                [self zhifuFinish];
            }else{
                ChongzhiImageViewController *vc = [[ChongzhiImageViewController alloc]init];
                vc.payNum = _payMonney;
                vc.payType = tmpArr.firstObject;
                vc.type = @"话费充值";
                vc.imageStr = responseObject[@"data"][@"data"];
                vc.payCount = _bind_phone;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }else{
            [EBAlert alertError:@"加载失败" length:2.0f];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"加载失败,请重新再试" length:2.0f];
    }];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:.5 animations:^{
        _popView.mj_y = kScreenH;
        _maskView.hidden = YES;
    }];
}

- (void)hidePopview{
    [UIView animateWithDuration:.5 animations:^{
        _popView.mj_y = kScreenH;
        _maskView.hidden = YES;
    }];
}

@end

