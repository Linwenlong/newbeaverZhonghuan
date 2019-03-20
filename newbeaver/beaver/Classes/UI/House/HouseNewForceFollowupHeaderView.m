//
//  HouseNewForceFollowupHeaderView.m
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HouseNewForceFollowupHeaderView.h"

@interface HouseNewForceFollowupHeaderView ()

@property (nonatomic, weak)UIButton * currentBtn;

@end

@implementation HouseNewForceFollowupHeaderView

-(instancetype)initWithFrame:(CGRect)frame name:(NSString *)name phones:(NSArray *)phones{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI:name phones:phones];
    }
    return self;
}

- (void)setUI:(NSString *)name phones:(NSArray *)phones{
    CGFloat x = 15;
    CGFloat y = 15;
    UILabel *yezhuType = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 80, 21)];
    yezhuType.text = @"业主";
    yezhuType.font = [UIFont systemFontOfSize:14.0f];
    yezhuType.textColor = UIColorFromRGB(0x404040);
    yezhuType.textAlignment = NSTextAlignmentLeft;
    [self addSubview:yezhuType];
    
    UILabel *yezhuName = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 80, 21)];
    yezhuName.text = name;
    yezhuName.font = [UIFont systemFontOfSize:14.0f];
    yezhuName.textColor = UIColorFromRGB(0x808080);
    yezhuName.textAlignment = NSTextAlignmentRight;
    [self addSubview:yezhuName];
    
    UILabel *phoneType = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 80, 21)];
    phoneType.text = @"电话";
    phoneType.font = [UIFont systemFontOfSize:14.0f];
    phoneType.textColor = UIColorFromRGB(0x404040);
    phoneType.textAlignment = NSTextAlignmentLeft;
    [self addSubview:phoneType];
    
    yezhuType.sd_layout
    .topSpaceToView(self,y)
    .leftSpaceToView(self,x)
    .widthIs(80)
    .heightIs(21);
    
    yezhuName.sd_layout
    .topSpaceToView(self,y)
    .rightSpaceToView(self,x)
    .widthIs(80)
    .heightIs(21);
    
    phoneType.sd_layout
    .topSpaceToView(yezhuType,y)
    .leftSpaceToView(self,x)
    .widthIs(80)
    .heightIs(21);
    
    //phone name
    for (int i=0; i < phones.count; i++) {
        NSDictionary *dic = phones[i];
        NSString *phone = dic[@"phone"];
        NSString *str = [NSString stringWithFormat:@"%@  %@",phone,dic[@"name"]];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:str];
        [attribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x0873ED) range:NSMakeRange(0, phone.length)];
        [attribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSMakeRange(phone.length, str.length-phone.length)];
        
        UIButton *btn = [UIButton new];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setAttributedTitle:attribute forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:btn];
        btn.sd_layout
        .topSpaceToView(yezhuName,y+(y+21)*i)
        .rightSpaceToView(self,x)
        .widthIs(250)
        .heightIs(21);
    }

}

- (void)btnClick:(UIButton *)btn{
    if (self.headerViewDelegate && [self.headerViewDelegate respondsToSelector:@selector(phoneNumberClick:)]) {
        [self.headerViewDelegate phoneNumberClick:btn.titleLabel.text];
    }
}


@end
