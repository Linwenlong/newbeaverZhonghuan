//
//  MortgageAmendTopView.m
//  dev-beaver
//
//  Created by 林文龙 on 2019/1/8.
//  Copyright © 2019年 eall. All rights reserved.
//

#import "MortgageAmendTopView.h"

@interface MortgageAmendTopView ()


@property (nonatomic, strong) UILabel * groupTitle;

@property (nonatomic, strong) UIView * line;

@property (nonatomic, strong) UIButton * cancle;
@property (nonatomic, strong) UIButton * submit;

@property (nonatomic, weak) UITextField * textField1;
@property (nonatomic, weak) UITextField * textField2;

@property (nonatomic, assign) CGFloat totlePrice;

@end

@implementation MortgageAmendTopView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)str totle:(NSString *)priceNum first:(NSString *)first second:(NSString *)second{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        _totlePrice = [priceNum floatValue];
        [self setUI:str totle:priceNum first:first second:second];
    }
    return self;
}

- (void)setUI:(NSString *)str totle:(NSString *)priceNum first:(NSString *)first second:(NSString *)second{
    
    _groupTitle = [UILabel new];
    _groupTitle.textAlignment = NSTextAlignmentCenter;
    _groupTitle.font = [UIFont boldSystemFontOfSize:16.0f];
    _groupTitle.textColor = RGBA(0, 0, 0, 1);
    _groupTitle.text = str;
    
   
    _line = [UIView new];
    _line.backgroundColor = RGBA(220, 220, 220, 1);
    
    UILabel *lable1 = [UILabel new];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.font = [UIFont systemFontOfSize:15.0f];
    lable1.textColor = RGBA(0, 0, 0, 1);
    lable1.text = @"签约门店:";
    
    UITextField *textField1 = [UITextField new];
    textField1.keyboardType = UIKeyboardTypeDecimalPad;
    textField1.placeholder = @"请输入";
    textField1.text = first;
    _textField1 = textField1;
    [textField1 addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    textField1.textAlignment = NSTextAlignmentRight;
    textField1.font = [UIFont systemFontOfSize:15.0f];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = RGBA(220, 220, 220, 1);
    
    UILabel *lable2 = [UILabel new];
    lable2.textAlignment = NSTextAlignmentCenter;
    lable2.font = [UIFont systemFontOfSize:15.0f];
    lable2.textColor = RGBA(0, 0, 0, 1);
   
    lable2.text = @"公   司:";
    
    UITextField *textField2 = [UITextField new];
    _textField2 = textField2;
    textField2.text = second;
    textField2.placeholder = @"请输入";
    [textField2 addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    textField2.textAlignment = NSTextAlignmentRight;
    textField2.font = [UIFont systemFontOfSize:15.0f];
    
    UIView * line2 = [UIView new];
    line2.backgroundColor = RGBA(220, 220, 220, 1);
    
    UILabel *lable3 = [UILabel new];
    lable3.textAlignment = NSTextAlignmentCenter;
    lable3.font = [UIFont systemFontOfSize:15.0f];
    lable3.textColor = RGBA(0, 0, 0, 1);
    lable3.text = @"总   和:";
    
    UITextField *textField3 = [UITextField new];
    textField3.enabled = NO;
    textField3.text = priceNum;
    textField3.textAlignment = NSTextAlignmentRight;
    textField3.font = [UIFont systemFontOfSize:15.0f];
    
    
    
    
    UIView * line3 = [UIView new];
    line3.backgroundColor = RGBA(220, 220, 220, 1);
    
    
    
    UIView * line4 = [UIView new];
    line4.backgroundColor = RGBA(220, 220, 220, 1);
    
    _cancle = [UIButton new];
    _cancle.tag = 1;
    _cancle.backgroundColor = [UIColor clearColor];
    [_cancle setTitleColor:RGBA(73, 73, 73, 1) forState:UIControlStateNormal];
    [_cancle setTitle:@"取消" forState:UIControlStateNormal];
    _cancle.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [_cancle addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _submit = [UIButton new];
    _submit.tag = 2;
    _submit.backgroundColor = [UIColor clearColor];
    [_submit setTitleColor:RGBA(218, 37, 29, 1)  forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_submit setTitle:@"确定" forState:UIControlStateNormal];
    _submit.titleLabel.font = [UIFont systemFontOfSize:18.f];
    
    [self sd_addSubviews:@[_groupTitle,_line,lable1,textField1,line1,lable2,textField2,line2,lable3,textField3,line3,line4,_cancle,_submit]];
    
    
    _groupTitle.sd_layout
    .centerXEqualToView(self)
    .topSpaceToView(self, 15)
    .widthIs(120)
    .heightIs(16);
    
    _line.sd_layout
    .leftSpaceToView(self, 0)
    .topSpaceToView(_groupTitle, 14)
    .rightSpaceToView(self, 0)
    .heightIs(1);
    
    lable1.sd_layout
    .leftSpaceToView(self, 15)
    .topSpaceToView(_line, 26)
    .widthIs(68)
    .heightIs(15);
    
    textField1.sd_layout
    .rightSpaceToView(self, 19)
    .centerYEqualToView(lable1)
    .widthIs(154)
    .heightIs(20);
    
    line1.sd_layout
    .topSpaceToView(textField1, 1)
    .leftEqualToView(textField1)
    .rightEqualToView(textField1)
    .heightIs(1);
    
    
    lable2.sd_layout
    .leftSpaceToView(self, 15)
    .topSpaceToView(lable1, 32)
    .widthIs(70)
    .heightIs(15);
    
    textField2.sd_layout
    .rightSpaceToView(self, 19)
    .centerYEqualToView(lable2)
    .widthIs(154)
    .heightIs(20);
    
    line2.sd_layout
    .topSpaceToView(textField2, 1)
    .leftEqualToView(textField2)
    .rightEqualToView(textField2)
    .heightIs(1);
    
    lable3.sd_layout
    .leftSpaceToView(self, 15)
    .topSpaceToView(lable2, 32)
    .widthIs(70)
    .heightIs(15);
    
    textField3.sd_layout
    .rightSpaceToView(self, 19)
    .centerYEqualToView(lable3)
    .widthIs(154)
    .heightIs(20);
    
    line3.sd_layout
    .topSpaceToView(textField3, 24)
    .rightEqualToView(self)
    .leftEqualToView(self)
    .heightIs(1);
    
    line4.sd_layout
    .centerXEqualToView(self)
    .topSpaceToView(line3, 0)
    .bottomSpaceToView(self, 0)
    .widthIs(1);
    
    _cancle.sd_layout
    .leftSpaceToView(self, 1)
    .topSpaceToView(line3, 1)
    .rightSpaceToView(line4, 1)
    .bottomSpaceToView(self, 1);
    
    _submit.sd_layout
    .leftSpaceToView(line4, 1)
    .topSpaceToView(line3, 1)
    .rightSpaceToView(self, 1)
    .bottomSpaceToView(self, 1);
    
}

- (void)changedTextField:(UITextField *)textField{
    if (textField == _textField1) {
        if ([_textField1.text floatValue] <= _totlePrice) {
            _textField2.text = [NSString stringWithFormat:@"%@",[self stringDisposeWithFloat:_totlePrice - [_textField1.text floatValue]]];
        }else{
            _textField1.text = [NSString stringWithFormat:@"%@",[self stringDisposeWithFloat:_totlePrice]];
            _textField2.text = @"0";
            [EBAlert alertError:@"输入的大于总和"];
            
        }
    }else{
        if ([_textField2.text floatValue] <= _totlePrice) {
            _textField1.text = [NSString stringWithFormat:@"%@",[self stringDisposeWithFloat:_totlePrice - [_textField2.text floatValue]]];
        }else{
            _textField2.text = [NSString stringWithFormat:@"%@",[self stringDisposeWithFloat:_totlePrice]];
            _textField1.text = @"0";
            [EBAlert alertError:@"输入的大于总和"];
        }
    }
}

- (void)btnClick:(UIButton *)btn{
    self.btnClick(_textField1,_textField2,btn);
}

-(NSString *)stringDisposeWithFloat:(float)floatValue
{
    NSString *str = [NSString stringWithFormat:@"%f",floatValue];
    long len = str.length;
    for (int i = 0; i < len; i++)
    {
        if (![str  hasSuffix:@"0"])
            break;
        else
            str = [str substringToIndex:[str length]-1];
    }
    if ([str hasSuffix:@"."])//避免像2.0000这样的被解析成2.
    {
        //s.substring(0, len - i - 1);
        return [str substringToIndex:[str length]-1];
    }
    else
    {
        return str;
    }
}


@end
