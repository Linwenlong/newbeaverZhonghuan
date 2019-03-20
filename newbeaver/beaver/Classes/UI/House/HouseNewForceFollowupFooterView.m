//
//  HouseNewForceFollowupFooterView.m
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HouseNewForceFollowupFooterView.h"

@interface HouseNewForceFollowupFooterView ()<UITextViewDelegate>

@property (nonatomic, strong)UILabel * followUpType; //跟进内容

@end

@implementation HouseNewForceFollowupFooterView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    CGFloat x = 15;
    CGFloat y = 15;
    _followUpType = [UILabel new];
    _followUpType.text = @"跟进内容";
    _followUpType.textAlignment = NSTextAlignmentLeft;
    _followUpType.textColor = UIColorFromRGB(0x404040);
    _followUpType.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_followUpType];
    
    _followUpContent = [PINTextView new];
    _followUpContent.delegate = self;
    _followUpContent.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    _followUpContent.placeholder = @"请输入跟进内容(必填)";
    _followUpContent.placeholderColor = UIColorFromRGB(0x808080);
    _followUpContent.layer.cornerRadius = 5.0f;
    [self addSubview:_followUpContent];
    
    _countlable = [UILabel new];
    _countlable.text = @"0/500字";
    _countlable.font = [UIFont systemFontOfSize:12.0f];
    _countlable.textAlignment = NSTextAlignmentRight;
    _countlable.textColor = UIColorFromRGB(0x808080);
    [self addSubview:_countlable];
    
    _confirmBtn = [UIButton new];
    _confirmBtn.backgroundColor = UIColorFromRGB(0xff3800);
    _confirmBtn.layer.cornerRadius = 5.0f;
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_confirmBtn];
    
    //添加约束
    _followUpType.sd_layout
    .topSpaceToView(self,y)
    .leftSpaceToView(self,y)
    .widthIs(70)
    .heightIs(21);
    
    _followUpContent.sd_layout
    .topSpaceToView(_followUpType,y)
    .leftSpaceToView(self,x)
    .rightSpaceToView(self,x)
    .heightIs(150);
    
    _countlable.sd_layout
    .topSpaceToView(_followUpContent,10)
    .rightSpaceToView(self,x)
    .widthIs(120)
    .heightIs(10);
    
    _confirmBtn.sd_layout
    .topSpaceToView(_countlable,y)
    .leftSpaceToView(self,x)
    .rightSpaceToView(self,x)
    .heightIs(44);
}


#define MAX_LIMIT_NUMS 500

#pragma mark -- UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    if (caninputlen >= 0){
        return YES;
    }else{
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        if (rg.length > 0){
            NSString *s = [text substringWithRange:rg];
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > MAX_LIMIT_NUMS){
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        [textView setText:s];
    }
    self.countlable.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,existTextNum),MAX_LIMIT_NUMS];
}

@end
