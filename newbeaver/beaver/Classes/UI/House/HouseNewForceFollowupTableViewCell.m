//
//  HouseNewForceFollowupTableViewCell.m
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HouseNewForceFollowupTableViewCell.h"
#import "FinanceDetailModel.h"


@interface HouseNewForceFollowupTableViewCell ()

@property (nonatomic, strong)UILabel *left;

@property (nonatomic, strong)UILabel *right;

@end

@implementation HouseNewForceFollowupTableViewCell


- (void)setModel:(FinanceDetailModel *)model{
    if ([model.name containsString:@"编号"]) {
        _right.textColor = UIColorFromRGB(0x0873ED);
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
    _left.font = [UIFont systemFontOfSize:14.0f];
    _left.textColor = UIColorFromRGB(0x404040);
    
    
    _right = [UILabel new];
    _right.textAlignment = NSTextAlignmentRight;
    _right.font = [UIFont systemFontOfSize:14.0f];
    _right.textColor = UIColorFromRGB(0x808080);
    
    
    [self.contentView sd_addSubviews:@[_left,_right]];
    
    _left.sd_layout
    .topSpaceToView(self.contentView,Y)
    .leftSpaceToView(self.contentView,X)
    .widthIs(80)
    .autoHeightRatio(0);
    
    _right.sd_layout
    .topSpaceToView(self.contentView,Y)
    .rightSpaceToView(self.contentView,X)
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
