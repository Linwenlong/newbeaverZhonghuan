//
//  HouseDetailCountDownView.m
//  dev-beaver
//
//  Created by 林文龙 on 2018/12/20.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseDetailCountDownView.h"

@interface HouseDetailCountDownView()


@property (nonatomic, strong) UIButton * callBtn;
@property (nonatomic, strong) UIImageView * img_chacha;

@property (nonatomic, strong) NSString * phoneNumber;

@end

@implementation HouseDetailCountDownView

- (instancetype)initWithFrame:(CGRect)frame withPhone:(NSString *)phone{
    self = [super initWithFrame:frame];
    if (self) {
        _phoneNumber = phone;
        [self setUI:phone];
    }
    return self;
}


#pragma mark -- phone
#pragma mark -

- (void)setUI:(NSString *)phone{
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 270)];
    backGroundView.backgroundColor = [UIColor whiteColor];
    backGroundView.layer.cornerRadius = 5.0f;
    [self addSubview:backGroundView];
    
    UILabel *tip = [UILabel new];
    tip.textAlignment = NSTextAlignmentCenter;
    tip.text=  @"提示";
    tip.textColor = UIColorFromRGB(0x000000);
    tip.font = [UIFont systemFontOfSize:18.0f];
    
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xe9e5e5);
    
    UILabel *countPhone = [UILabel new];
    countPhone.textAlignment = NSTextAlignmentCenter;
    countPhone.text=  [NSString stringWithFormat:@"请拨打%@",phone];
    countPhone.textColor = UIColorFromRGB(0x000000);
    countPhone.font = [UIFont systemFontOfSize:20.0f];
    
    UILabel *tip1 = [UILabel new];
    tip1.textAlignment = NSTextAlignmentCenter;
    tip1.text=  @"30秒后将重新获取新号码!";
    tip1.textColor = UIColorFromRGB(0x9c9c9c);
    tip1.font = [UIFont systemFontOfSize:14.0f];
    
    
    _countMintus = [UILabel new];
    _countMintus.textAlignment = NSTextAlignmentCenter;
    NSString *mintus = @"30秒";
    NSMutableAttributedString *mintusAttribute = [[NSMutableAttributedString alloc]initWithString:mintus];
    
    [mintusAttribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xcc0515) range:NSMakeRange(0, mintus.length - 1)];
    [mintusAttribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x000000) range:NSMakeRange(mintus.length - 1, 1)];
    
    [mintusAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:40.0f] range:NSMakeRange(0, mintus.length - 1)];
    [mintusAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(mintus.length - 1, 1)];
    _countMintus.attributedText = mintusAttribute;
    
    _callBtn = [UIButton new];
    [_callBtn setTitleColor:UIColorFromRGB(0xcc0515) forState:UIControlStateNormal];
    [_callBtn setTitle:@"立即拨打" forState:UIControlStateNormal];
    _callBtn.clipsToBounds = YES;
    _callBtn.layer.cornerRadius = 20.0f;
    _callBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    _callBtn.layer.borderColor = UIColorFromRGB(0xcc0515).CGColor;
    _callBtn.layer.borderWidth = 1.0f;
    [_callBtn addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _img_chacha = [UIImageView new];
    _img_chacha.image = [UIImage imageNamed:@"隐号呼叫叉叉"];
    _img_chacha.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgClick:)];
    [_img_chacha addGestureRecognizer:tap];
    
    [backGroundView sd_addSubviews:@[tip,line,countPhone,tip1,_countMintus,_callBtn]];
    
    CGFloat h = 20;
    
    tip.sd_layout
    .leftSpaceToView(backGroundView, 0)
    .rightSpaceToView(backGroundView, 0)
    .topSpaceToView(backGroundView, 20)
    .heightIs(h);
    
    line.sd_layout
    .leftSpaceToView(backGroundView, 20)
    .rightSpaceToView(backGroundView, 20)
    .topSpaceToView(tip, 15)
    .heightIs(1);
    
    countPhone.sd_layout
    .leftSpaceToView(backGroundView, 0)
    .rightSpaceToView(backGroundView, 0)
    .topSpaceToView(line, 15)
    .heightIs(h);
    
    tip1.sd_layout
    .leftSpaceToView(backGroundView, 0)
    .rightSpaceToView(backGroundView, 0)
    .topSpaceToView(countPhone, 10)
    .heightIs(h);
    
    _countMintus.sd_layout
    .leftSpaceToView(backGroundView, 0)
    .rightSpaceToView(backGroundView, 0)
    .topSpaceToView(tip1, 20)
    .heightIs(h);
    
    _callBtn.sd_layout
    .centerXEqualToView(backGroundView)
    .topSpaceToView(_countMintus, 35)
    .heightIs(40)
    .widthIs(150);
    
    
    [self addSubview:_img_chacha];
    
    _img_chacha.sd_layout
    .centerXEqualToView(self)
    .bottomSpaceToView(self, 10)
    .widthIs(20)
    .heightIs(20);
}

- (void)imgClick:(UITapGestureRecognizer *)tap{
    self.img_click();
}

- (void)callClick:(UIButton *)btn{
    self.call_click(_phoneNumber);
}

@end
