//
//  FinanceDetailTableViewCell.m
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinanceDetailTableViewCell.h"

@interface FinanceDetailTableViewCell ()

@property (nonatomic, strong)UILabel *left;

@property (nonatomic, strong)UILabel *right;

@property (nonatomic, strong)UIImageView *icon;

@end

@implementation FinanceDetailTableViewCell

- (void)setModel:(FinanceDetailModel *)model isContactDetail:(BOOL)isDetail{
    if ([model.name containsString:@"元"]) {
        _right.textColor = UIColorFromRGB(0xff3800);
    }else{
        _right.textColor = UIColorFromRGB(0x808080);
    }
   
    _icon.hidden = YES;
    _right.sd_resetLayout.topSpaceToView(self.contentView,15)
    .rightSpaceToView(self.contentView,15)
    .leftSpaceToView(_left,30)
    .autoHeightRatio(0);
  

    _left.text = model.name;
    _right.text = model.value;
}

- (void)setModel:(FinanceDetailModel *)model{
    if ([model.name containsString:@"元"]) {
        _right.textColor = UIColorFromRGB(0xff3800);
    }else{
        _right.textColor = UIColorFromRGB(0x808080);
    }
    if ([model.name isEqualToString:@"合同编号"]) {
        _icon.hidden = NO;
    }else{
        _icon.hidden = YES;
        _right.sd_resetLayout.topSpaceToView(self.contentView,15)
        .rightSpaceToView(self.contentView,15)
        .leftSpaceToView(_left,30)
        .autoHeightRatio(0);
    }
    
    _left.text = model.name;
    _right.text = model.value;
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
    CGFloat X = 15;
    CGFloat Y = X;
    _left = [UILabel new];
    _left.textAlignment = NSTextAlignmentLeft;
    _left.font = [UIFont systemFontOfSize:13.0f];
    _left.textColor = UIColorFromRGB(0x404040);

    
    _right = [UILabel new];
    _right.textAlignment = NSTextAlignmentRight;
    _right.font = [UIFont systemFontOfSize:13.0f];
    _right.textColor = UIColorFromRGB(0x808080);
 
    CGFloat iconH = 11;
    CGFloat iconW = 7;
    _icon = [UIImageView new];
    _icon.image = [UIImage imageNamed:@"jiantou"];
   
    [self.contentView sd_addSubviews:@[_left,_right,_icon]];
    
    _left.sd_layout
    .topSpaceToView(self.contentView,Y)
    .leftSpaceToView(self.contentView,X)
    .widthIs(80)
    .autoHeightRatio(0);
    
    _icon.sd_layout
    .topSpaceToView(self.contentView,(self.contentView.height-iconH+2)/2.0f)
    .rightSpaceToView(self.contentView,15)
    .widthIs(iconW)
    .heightIs(iconH);
    
    _right.sd_layout
    .topSpaceToView(self.contentView,Y)
    .rightSpaceToView(_icon,4)
    .leftSpaceToView(_left,30)
    .autoHeightRatio(0);
    
    [self setupAutoHeightWithBottomViewsArray:@[_left,_right] bottomMargin:Y];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
