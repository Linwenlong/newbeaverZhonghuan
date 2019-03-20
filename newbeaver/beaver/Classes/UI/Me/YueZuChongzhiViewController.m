//
//  YueZuChongzhiViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "YueZuChongzhiViewController.h"
#import "EBIconLabel.h"
#import "ChongzhiImageViewController.h"

@interface YueZuChongzhiViewController ()

@property (nonatomic, strong) UIView * popView;

@property (nonatomic, strong) NSString * payMonney;//充值金额

@property (nonatomic, strong) NSMutableArray * btns;

@end

@implementation YueZuChongzhiViewController

- (UIView *)popView{
    if (!_popView) {
        _popView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH, kScreenW, 300)];
        _popView.layer.borderColor = [UIColor blackColor].CGColor;
        _popView.layer.borderWidth = 1.0f;
        CGFloat x = 15;
        CGFloat y = x;
        CGFloat h = 20;
        UIFont *font = [UIFont systemFontOfSize:15.0f];
        
//        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
//        line.backgroundColor = [UIColor blackColor];
//        [_popView addSubview:line];
        
        UILabel * yue = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kScreenW/2, h)];
        yue.text = @"请选择充值方式";
        yue.textAlignment = NSTextAlignmentLeft;
        yue.font = font;
        yue.textColor = [UIColor blackColor];
        [_popView addSubview:yue];
        
        UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenW-20-x, y, h, h)];
        imageIcon.image = [UIImage imageNamed:@"hidden_chacha"];
        imageIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePopview)];
        [imageIcon addGestureRecognizer:tap];
        [_popView addSubview:imageIcon];
        
        //线3
        UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yue.frame)+15, kScreenW, 1)];
        line3.backgroundColor = [UIColor blackColor];
        [_popView addSubview:line3];
        
        //button
        UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake((kScreenW/2-120)/2, CGRectGetMaxY(line3.frame)+40, 120, 30)];
        
        btn1.tag = 1;
        btn1.titleLabel.font = font;
        btn1.layer.borderColor = [UIColor blackColor].CGColor;
        btn1.layer.borderWidth = 1.0f;
        btn1.layer.cornerRadius = 3.0f;
//        [btn1 setImage:[UIImage imageNamed:@"买卖房源"] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn1 setTitle:@"微信充值" forState:UIControlStateNormal];
        [btn1 setImage:[UIImage imageNamed:@"hidden_weixin"] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(chongzhifinish:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btn1];
        
        UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake((kScreenW/2-120)/2+kScreenW/2, CGRectGetMaxY(line3.frame)+40, 120, 30)];
        btn2.tag = 2;
        btn2.titleLabel.font = font;
        btn2.layer.borderColor = [UIColor blackColor].CGColor;
        btn2.layer.borderWidth = 1.0f;
        btn2.layer.cornerRadius = 3.0f;
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn2 setTitle:@"支付宝充值" forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:@"hidden_zhifubao"] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(chongzhifinish:) forControlEvents:UIControlEventTouchUpInside];
        [_popView addSubview:btn2];
        
        
    }
    return _popView;
}

- (void)setUI{
    
    CGFloat x = 15;
    CGFloat y = x;
    CGFloat h = 20;
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    
    UILabel * yue = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kScreenW, h)];
    yue.text = @"月租费余额: ";
    yue.textAlignment = NSTextAlignmentLeft;
    yue.font = font;
    yue.textColor = [UIColor blackColor];
    [self.view addSubview:yue];
    
    //线1
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yue.frame)+15, kScreenW, 1)];
    line.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [self.view addSubview:line];
    
    UILabel * yuechongzhi = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(line.frame)+15, 90, h)];
    yuechongzhi.text = @"月租费充值:";
    yuechongzhi.textAlignment = NSTextAlignmentLeft;
    yuechongzhi.font = font;
    yuechongzhi.textColor = [UIColor blackColor];
    [self.view addSubview:yuechongzhi];
    
    //button
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(yuechongzhi.frame), CGRectGetMaxY(line.frame)+10, 100, 30)];
    
    btn1.tag = 1;
    btn1.titleLabel.font = font;
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn1.layer.borderWidth = 1.0f;
    btn1.layer.cornerRadius = 3.0f;
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitle:@"10元/月" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(chongzhi:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn1.frame) + 5, CGRectGetMaxY(line.frame)+10, 100, 30)];
    btn2.tag = 2;
    btn2.titleLabel.font = font;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderWidth = 1.0f;
    btn2.layer.cornerRadius = 3.0f;
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setTitle:@"30元/季" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(chongzhi:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    //线2
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yuechongzhi.frame)+15, kScreenW, 1)];
    line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [self.view addSubview:line2];
    
    //button
    UIButton *btn3 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(yuechongzhi.frame), CGRectGetMaxY(line2.frame)+10, 100, 30)];
    btn3.tag = 3;
    btn3.titleLabel.font = font;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderWidth = 1.0f;
    btn3.layer.cornerRadius = 3.0f;
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn3 setTitle:@"60元/半年" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(chongzhi:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    UIButton *btn4 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn1.frame) + 5, CGRectGetMaxY(line2.frame)+10, 100, 30)];
    btn4.tag = 4;
    btn4.titleLabel.font = font;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderWidth = 1.0f;
    btn4.layer.cornerRadius = 3.0f;
    [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn4 setTitle:@"120元/年" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(chongzhi:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
    
    //线3
    UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(btn3.frame)+10, kScreenW, 1)];
    line3.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [self.view addSubview:line3];
    
    UILabel * tip = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(line3.frame)+30, kScreenW - 2*x, h*2)];
    tip.text = @"注：若月租费余额为负数，表示月租费欠费，不可以拨打电话，请及时充值！";
    tip.textAlignment = NSTextAlignmentLeft;
    tip.font = font;
    tip.numberOfLines = 0;
    tip.textColor = UIColorFromRGB(0xff3800);
    [self.view addSubview:tip];
    
    [self.btns addObject:btn1];
    [self.btns addObject:btn2];
    [self.btns addObject:btn3];
    [self.btns addObject:btn4];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"月租费充值";
    self.btns = [NSMutableArray array];
    [self setUI];
    [self.view addSubview:self.popView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)chongzhi:(UIButton *)btn{
    NSLog(@"btn = %@",btn.titleLabel.text);
    
    for (UIButton *tmpBtn in _btns) {
        tmpBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [tmpBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    btn.layer.borderColor = UIColorFromRGB(0xff3800).CGColor;
    [btn setTitleColor:UIColorFromRGB(0xff3800) forState:UIControlStateNormal];
    //获取上面的元
    NSArray *tmpArr = [btn.titleLabel.text componentsSeparatedByString:@"元"];
    _payMonney = tmpArr.firstObject;
    NSLog(@"_pa=%@",_payMonney);
    NSLog(@"popview = %f",_popView.mj_y);
    [UIView animateWithDuration:.5 animations:^{
        _popView.mj_y = kScreenH - _popView.height;
    }];

}

- (void)chongzhifinish:(UIButton *)btn{
    NSLog(@"btn = %@",btn.titleLabel.text);
    [UIView animateWithDuration:.5 animations:^{
        _popView.mj_y = kScreenH;
    }];
    NSArray *tmpArr = [btn.titleLabel.text componentsSeparatedByString:@"充值"];
    
    
    NSString *urlStr = @"call/recharge";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    NSDictionary *param = @{
                            @"token":[EBPreferences sharedInstance].token,
                            @"bind_phone":_bind_phone,
                            @"type":[NSString stringWithFormat:@"%@",@"2"],
                            @"money":_payMonney,
                            @"pay_type":tmpArr.firstObject,
                            };
    NSLog(@"param=%@",param);
    [HttpTool get:urlStr parameters:param success:^(id responseObject) {
        [EBAlert hideLoading];
        NSLog(@"responseObject=%@",responseObject);
        
        if ([responseObject[@"code"]integerValue] == 0) {
            for (UIButton *tmpBtn in _btns) {
                tmpBtn.layer.borderColor = [UIColor blackColor].CGColor;
                [tmpBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
            ChongzhiImageViewController *vc = [[ChongzhiImageViewController alloc]init];
            vc.payNum = _payMonney;
            vc.payType = tmpArr.firstObject;
            vc.type = @"账户充值";
            vc.imageStr = responseObject[@"data"][@"data"];
            [self.navigationController pushViewController:vc animated:YES];
            
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
    }];
}

- (void)hidePopview{
    [UIView animateWithDuration:.5 animations:^{
        _popView.mj_y = kScreenH;
    }];
}


@end
