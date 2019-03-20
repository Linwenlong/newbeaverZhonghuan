//
//  IntentionOrderCell.m
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/28.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  纯代码自定义"意向单"cell

#import "IntentionOrderCell.h"


@implementation IntentionOrderCell

#pragma mark - 重写initWithStyle:方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 创建这个cell中的6 个子控件
        
        //1.0 背景bgView
        UIView *bgView = [[UIView alloc] init];
        [self.contentView addSubview:bgView];
        self.bgView = bgView;
        bgView.layer.borderWidth = 0.6f;
        bgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bgView.layer.cornerRadius = 3.0f;
        bgView.clipsToBounds = YES;
        
        //2.0 右上角删除图标
        UIImageView *deleteImage = [[UIImageView alloc] init];
        [self.contentView addSubview:deleteImage];
        self.deleteImage = deleteImage;
        deleteImage.image = [UIImage imageNamed:@"workDelete"];
        deleteImage.userInteractionEnabled = YES;
        
        //3.0 下划线line1和line2
        UILabel *lineOne = [[UILabel alloc] init];
        [self.contentView addSubview:lineOne];
        self.lineOne = lineOne;
        lineOne.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *lineTwo = [[UILabel alloc] init];
        [self.contentView addSubview:lineTwo];
        self.lineTwo = lineTwo;
        lineTwo.backgroundColor = [UIColor lightGrayColor];
        
        //4.0 姓名lbl和输入textField
        UILabel *nameLbl = [[UILabel alloc] init];
        [self.contentView addSubview:nameLbl];
        self.nameLbl = nameLbl;
        nameLbl.text = @"姓名：";
        nameLbl.textAlignment = NSTextAlignmentLeft;
        nameLbl.font = FontSys14;
        nameLbl.textColor = RGB64;
        //nameLbl.backgroundColor = [UIColor yellowColor];
        
        UITextField *nameField = [[UITextField alloc] init];
        [self.contentView addSubview:nameField];
        self.nameField = nameField;
        self.nameField.enabled = NO;
        nameField.font = FontSys14;
        nameField.textColor = RGB64;
        nameField.textAlignment = NSTextAlignmentLeft;
        nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //nameField.backgroundColor = [UIColor yellowColor];
        
        //5.0 客源号lbl和选择客源编号btn
        UILabel *clientCodeLbl = [[UILabel alloc] init];
        [self.contentView addSubview:clientCodeLbl];
        self.clientCodeLbl = clientCodeLbl;
        clientCodeLbl.text = @"客源号：";
        clientCodeLbl.textAlignment = NSTextAlignmentLeft;
        clientCodeLbl.font = FontSys14;
        clientCodeLbl.textColor = RGB64;
        //clientCodeLbl.backgroundColor = [UIColor yellowColor];
        
        UIButton *chooseClientCodeBtn = [[UIButton alloc] init];
        [self.contentView addSubview:chooseClientCodeBtn];
        self.chooseClientCodeBtn = chooseClientCodeBtn;
        [chooseClientCodeBtn setTitle:@"选择客源编号" forState:UIControlStateNormal];
        chooseClientCodeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        chooseClientCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        chooseClientCodeBtn.titleLabel.font = FontSys14;
        [chooseClientCodeBtn setTitleColor:RGB156 forState:UIControlStateNormal];
        //chooseClientCodeBtn.backgroundColor = [UIColor yellowColor];
        
        //6.0 情况汇报lbl和输入textView及占位lbl
        UILabel *titleLbl = [[UILabel alloc] init];
        [self.contentView addSubview:titleLbl];
        self.titleLbl = titleLbl;
        titleLbl.text = @"情况汇报及下一步方案";
        titleLbl.textAlignment = NSTextAlignmentLeft;
        titleLbl.font = FontSys14;
        titleLbl.textColor = RGB64;
        //titleLbl.backgroundColor = [UIColor yellowColor];
        
        UITextView *contentTextView = [[UITextView alloc] init];
        [self.contentView addSubview:contentTextView];
        self.contentTextView = contentTextView;
        contentTextView.font = FontSys14;
        contentTextView.textColor = [UIColor blackColor];
        contentTextView.backgroundColor = RGB238;
        contentTextView.layer.cornerRadius = 3.0f;
        contentTextView.clipsToBounds = YES;
        contentTextView.delegate = self;
        
        UILabel *tipLbl = [[UILabel alloc] init];
        [self.contentView addSubview:tipLbl];
        self.tipLbl = tipLbl;
        tipLbl.text = @"0/200字";
        tipLbl.textAlignment = NSTextAlignmentRight;
        tipLbl.font = FontSys12;
        tipLbl.textColor = RGB128;
        //tipLbl.backgroundColor = [UIColor yellowColor];
        
    }


    return self;
}

//实时监听文字改变
- (void)textViewDidChange:(UITextView *)textView {
    //NSLog(@"textViewDidChange");
    
    //实时显示字数
    self.tipLbl.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.contentTextView.text.length,200];
    
    [self.orderDelegate getContentViewText:textView];
    
    //字数限制操作
    if (self.contentTextView.text.length >= 200) {
        self.contentTextView.text = [self.contentTextView.text substringToIndex:200];
        self.tipLbl.text = [NSString stringWithFormat:@"%d/%d",200,200];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入200个字"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

//子控件布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //1.0 背景View的frame
    self.bgView.frame = CGRectMake(10, 10, self.bounds.size.width -20, self.bounds.size.height -20);
    
    //2.0 右上角删除图标
    self.deleteImage.frame = CGRectMake(self.bounds.size.width -25, 5, 20, 20);
    
    //3.0 下划线line1和line2
    self.lineOne.frame = CGRectMake(10, self.bgView.top+44, self.bgView.width, 0.6);
    self.lineTwo.frame = CGRectMake(10, CGRectGetMaxY(self.lineOne.frame) +44, self.bgView.width, 0.6);
    
    //4.0 姓名lbl和输入textField
    self.nameLbl.frame = CGRectMake(20, self.lineOne.top -30, 50, 20);
    self.nameField.frame = CGRectMake(CGRectGetMaxX(self.nameLbl.frame) +3, self.nameLbl.centerY -15, self.bgView.width -CGRectGetMaxX(self.nameLbl.frame) -20, 30);
    
    //5.0 客源号lbl和选择客源编号btn
    self.clientCodeLbl.frame = CGRectMake(20, self.lineTwo.top -30, 60, 20);
    self.chooseClientCodeBtn.frame = CGRectMake(CGRectGetMaxX(self.clientCodeLbl.frame) +10, self.clientCodeLbl.centerY -15, self.bgView.width -CGRectGetMaxX(self.clientCodeLbl.frame) -20, 30);
    
    //6.0 情况汇报lbl和输入textView及占位lbl
    self.titleLbl.frame = CGRectMake(20, self.lineTwo.top +10, 200, 20);
    self.contentTextView.frame = CGRectMake(20, CGRectGetMaxY(self.titleLbl.frame) +10, self.bgView.width -20, 108);
    self.tipLbl.frame = CGRectMake(self.bgView.width -80, CGRectGetMaxY(self.bgView.frame) -40, 80, 20);
    
}



@end










