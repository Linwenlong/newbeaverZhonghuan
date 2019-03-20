//
//  FunctionIntroduceTableViewCell.m
//  beaver
//
//  Created by mac on 17/11/30.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FunctionIntroduceTableViewCell.h"
#import "SDAutoLayout.h"

@interface FunctionIntroduceTableViewCell ()

@property (nonatomic, copy) UILabel *subtitle;
@property (nonatomic, copy) UILabel *date;
@property (nonatomic, copy) UILabel *content;

@end

@implementation FunctionIntroduceTableViewCell

- (void)setModel:(FunctionModel *)model{
    _subtitle.text = model.subtitle;
    _date.text = model.date;
    _content.text = model.content;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _subtitle = [UILabel new];
    _subtitle.textColor = UIColorFromRGB(0x404040);
    _subtitle.textAlignment = NSTextAlignmentLeft;
    _subtitle.font = [UIFont systemFontOfSize:15.0f];
    
    _date = [UILabel new];
    _date.textColor = UIColorFromRGB(0x808080);
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = [UIFont systemFontOfSize:14.0f];
    
    _content = [UILabel new];

    _content.textColor = UIColorFromRGB(0x808080);
    _content.textAlignment = NSTextAlignmentLeft;
    _content.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_subtitle,_date,_content]];
    
    _subtitle.sd_layout
    .topSpaceToView(self.contentView,23)
    .leftSpaceToView(self.contentView,15)
    .widthIs(200)
    .heightIs(20);
    
    _date.sd_layout
    .topSpaceToView(_subtitle,5)
    .leftSpaceToView(self.contentView,15)
    .widthIs(200)
    .heightIs(15);
    
    _content.sd_layout
    .topSpaceToView(_date,5)
    .leftSpaceToView(self.contentView,15)
    .widthIs(kScreenW-30)
    .autoHeightRatio(0);
    
    [self setupAutoHeightWithBottomView:_content bottomMargin:23];
//    [self setupAutoHeightWithBottomViewsArray:@[_leftContent,_rightContent] bottomMargin:Y];
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
