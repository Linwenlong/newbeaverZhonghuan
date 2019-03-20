//
//  WorkSumLIstTableViewCell.m
//  beaver
//
//  Created by mac on 18/2/2.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkSumLIstTableViewCell.h"

@interface WorkSumLIstTableViewCell ()

@property (nonatomic, strong)UILabel * titleLable;
@property (nonatomic, strong)UILabel * dateLable;
@property (nonatomic, strong)UIImageView * imageIcon;

@end

@implementation WorkSumLIstTableViewCell

- (void)setModel:(WorkSumListModel *)model{
    _titleLable.text = model.title;
    _dateLable.text = model.date;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    _titleLable = [UILabel new];
    
    _titleLable.font = [UIFont systemFontOfSize:13.0];
    _titleLable.numberOfLines = 0;
    _titleLable.textColor = LWL_DarkGrayrColor;
    _titleLable.textAlignment = NSTextAlignmentLeft;
    
    
    _dateLable = [UILabel new];
    _dateLable.font = [UIFont systemFontOfSize:12.0];
    _dateLable.textAlignment = NSTextAlignmentRight;
    _dateLable.textColor = LWL_LightGrayColor;
   
    _imageIcon = [UIImageView new];
    _imageIcon.image = [UIImage imageNamed:@"jiantou"];
    
    
    [self.contentView sd_addSubviews:@[_titleLable,_dateLable,_imageIcon]];
    
    CGFloat x = 15;
    CGFloat y = x;
    CGFloat h = x;
    
    _imageIcon.sd_layout
    .topSpaceToView(self.contentView,x+2)
    .rightSpaceToView(self.contentView,y)
    .widthIs(7)
    .heightIs(11);
    
    _dateLable.sd_layout
    .topSpaceToView(self.contentView,x)
    .rightSpaceToView(_imageIcon,4)
    .widthIs(80)
    .heightIs(h);
    
    _titleLable.sd_layout
    .topSpaceToView(self.contentView,x)
    .leftSpaceToView(self.contentView,y)
    .rightSpaceToView(_dateLable,5)
    .autoHeightRatio(0);

    [self setupAutoHeightWithBottomView:_titleLable bottomMargin:y];
}


- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
