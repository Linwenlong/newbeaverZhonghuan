//
//  InspectorTableViewCell.m
//  beaver
//
//  Created by mac on 18/1/30.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "InspectorTableViewCell.h"

@implementation InspectorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}


-(void)setUI{
    
    _icon = [UIImageView new];
    _icon.image = [UIImage imageNamed:@"编辑五角星"];
    
    _nameTitle = [UILabel new];
    _nameTitle.font = [UIFont systemFontOfSize:14.0f];
    _nameTitle.text = @"一大区1区:";
    _nameTitle.textColor = UIColorFromRGB(0x404040);
    _nameTitle.textAlignment = NSTextAlignmentLeft;
    
    _textField = [UITextField new];
    _textField.textAlignment = NSTextAlignmentRight;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.font = [UIFont systemFontOfSize:14.0f];
    
    _tipLable = [UILabel new];
    _tipLable.font = [UIFont systemFontOfSize:14.0f];
    _tipLable.text = @"家";
    _tipLable.textColor = UIColorFromRGB(0x404040);
    _tipLable.textAlignment = NSTextAlignmentLeft;
    
    
    [self.contentView sd_addSubviews:@[_icon,_nameTitle,_textField,_tipLable]];
    
    _icon.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .centerYEqualToView(self.contentView)
    .widthIs(12)
    .heightIs(17);
    
    _nameTitle.sd_layout
    .topSpaceToView(self.contentView,14)
    .leftSpaceToView(self.contentView,15)
    .widthIs(150)
    .heightIs(15);
    
    _tipLable.sd_layout
    .topSpaceToView(self.contentView,15)
    .rightSpaceToView(self.contentView,8)
    .widthIs(20)
    .heightIs(15);
    
    _textField.sd_layout
    .topSpaceToView(self.contentView,0)
    .rightSpaceToView(self.tipLable,3)
    .leftSpaceToView(self.nameTitle,3)
    .heightIs(44);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
