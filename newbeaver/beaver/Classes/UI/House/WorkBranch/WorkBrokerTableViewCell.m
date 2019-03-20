//
//  WorkBrokerTableViewCell.m
//  beaver
//
//  Created by mac on 18/1/17.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkBrokerTableViewCell.h"

@interface WorkBrokerTableViewCell ()<UITextViewDelegate>



@end


@implementation WorkBrokerTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _deleteImage = [UIImageView new];
    _deleteImage.userInteractionEnabled = YES;
    _deleteImage.image = [UIImage imageNamed:@"workDelete"];

    
    _backView = [UIView new];
    _backView.clipsToBounds = YES;
    _backView.layer.borderColor = LWL_LineColor.CGColor;
    _backView.layer.borderWidth = 1.0f;
    _backView.layer.cornerRadius = 3.0f;


    UILabel *name = [UILabel new];
    name.text = @"姓名";
    name.textAlignment = NSTextAlignmentLeft;
    name.font = [UIFont systemFontOfSize:14.0f];
    name.textColor = UIColorFromRGB(0x404040);
    
    _nameField = [UILabel new];
    _nameField.font = [UIFont systemFontOfSize:14.0f];
    _nameField.textColor = UIColorFromRGB(0x404040);
    _nameField.textAlignment = NSTextAlignmentLeft;
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    UILabel *clinetCode = [UILabel new];
    clinetCode.text = @"客源号";
    clinetCode.textAlignment = NSTextAlignmentLeft;
    clinetCode.font = [UIFont systemFontOfSize:14.0f];
    clinetCode.textColor = UIColorFromRGB(0x404040);
    
    _chooseClientCode = [UIButton new];
    [_chooseClientCode setTitle:@"请选择客源编号" forState:UIControlStateNormal];
    _chooseClientCode.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_chooseClientCode setTitleColor:LWL_BlueColor forState:UIControlStateNormal];
    _chooseClientCode.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    UILabel *lable = [UILabel new];
    lable.text = @"情况汇报及下一步方案";
    lable.textAlignment = NSTextAlignmentLeft;
    lable.font = [UIFont systemFontOfSize:14.0f];
    lable.textColor = UIColorFromRGB(0x404040);
    
    CGFloat radius = 5.0f;
    _contentTextView = [UITextView new];
    _contentTextView.delegate = self;
    _contentTextView.backgroundColor = UIColorFromRGB(0xEBEBEB);
    _contentTextView.layer.cornerRadius = radius;
    _contentTextView.clipsToBounds = YES;
    
    _tipLable = [UILabel new];
    _tipLable.text = @"0/1000字";
    _tipLable.textAlignment = NSTextAlignmentRight;
    _tipLable.font = [UIFont systemFontOfSize:13.0f];
    _tipLable.textColor = UIColorFromRGB(0x808080);
    
     NSLog(@"self=%@",self.backView);
    
    [self.backView sd_addSubviews:@[name,_nameField,line,clinetCode,_chooseClientCode,line1,lable,_contentTextView,_tipLable]];
    
    [self.contentView sd_addSubviews:@[_backView,_deleteImage]];
   
   
    _deleteImage.sd_layout
    .topSpaceToView(self.contentView,0)
    .rightSpaceToView(self.contentView,8)
    .widthIs(21)
    .heightIs(21);
    
    _backView.sd_layout
    .topSpaceToView(self.contentView,8)
    .bottomSpaceToView(self.contentView,8)
    .leftSpaceToView(self.contentView,7)
    .rightSpaceToView(self.contentView,7);
    
    name.sd_layout
    .topSpaceToView(self.backView,15)
    .leftSpaceToView(self.backView,8)
    .widthIs(33)
    .heightIs(13);
    
    _nameField.sd_layout
    .topSpaceToView(self.backView,15)
    .leftSpaceToView(name,3)
    .rightSpaceToView(self.backView,8)
    .heightIs(13);

    line.sd_layout
    .topSpaceToView(name,15)
    .leftSpaceToView(self.backView,0)
    .rightSpaceToView(self.backView,0)
    .heightIs(1);
    
    clinetCode.sd_layout
    .topSpaceToView(line,15)
    .leftSpaceToView(self.backView,8)
    .widthIs(47)
    .heightIs(13);
    
    _chooseClientCode.sd_layout
    .topSpaceToView(line,15)
    .leftSpaceToView(clinetCode,8)
    .rightSpaceToView(self.backView,8)
    .heightIs(13);
    
    line1.sd_layout
    .topSpaceToView(clinetCode,15)
    .leftSpaceToView(self.backView,0)
    .rightSpaceToView(self.backView,0)
    .heightIs(1);
    
    lable.sd_layout
    .topSpaceToView(line1,15)
    .leftSpaceToView(self.backView,8)
    .widthIs(161)
    .heightIs(13);
    
    _contentTextView.sd_layout
    .topSpaceToView(lable,15)
    .leftSpaceToView(self.backView,8)
    .rightSpaceToView(self.backView,8)
    .heightIs(120);
    
    _tipLable.sd_layout
    .bottomSpaceToView(self.backView,22)
    .rightSpaceToView(self.backView,16)
    .widthIs(103)
    .heightIs(22);
    
    [self.contentView bringSubviewToFront:_deleteImage];
    
    
}

//实时监听文字改变
- (void)textViewDidChange:(UITextView *)textView {
    //NSLog(@"textViewDidChange");
    
    //实时显示字数
    self.tipLable.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.contentTextView.text.length,200];
    
    
    //字数限制操作
    if (self.contentTextView.text.length >= 200) {
        self.contentTextView.text = [self.contentTextView.text substringToIndex:200];
        self.tipLable.text = [NSString stringWithFormat:@"%d/%d",200,200];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入200个字"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)awakeFromNib {
    // Initialization code
   
    
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
