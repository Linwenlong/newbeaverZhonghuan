//
//  FinancialDetainAndHandTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialDetainAndHandTableViewCell.h"
#import "FinancialDetainModel.h"

@interface FinancialDetainAndHandTableViewCell()

@property (nonatomic, strong)UILabel * feeType;//费用类型
@property (nonatomic, strong)UILabel * feeStatus;//费用状态
@property (nonatomic, strong)UILabel * feeName;//费用收方
@property (nonatomic, strong)UILabel * feePrice;//费用收值
@property (nonatomic, strong)UILabel * feeContent;//费用内容

@property (nonatomic, strong)UIView * line1;//费用内容

@end

@implementation FinancialDetainAndHandTableViewCell

-(void)setModel:(FinancialDetainModel *)model{
  
    _feeType.attributedText = [NSString changeString:[NSString stringWithFormat:@"%@ %@",model.price_name,model.update_time] frontLength:model.price_name.length+1 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _feeStatus.text = model.status;
    _feeName.attributedText = [NSString changeString:[NSString stringWithFormat:@"收方: %@",model.fee_user] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
  
    
    
    
    if (model.price_num.length >= 6) {
        _feePrice.attributedText = [NSString changeString:[NSString stringWithFormat:@"%@: %0.04f",model.cost_status,[model.price_num floatValue]] frontLength:model.cost_status.length+2 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor];
    }else{
        _feePrice.attributedText = [NSString changeString:[NSString stringWithFormat:@"%@: %@",model.cost_status,model.price_num] frontLength:model.cost_status.length+2 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor];
    }
    
    _feeContent.text = [NSString stringWithFormat:@"备注: %@",model.memo];
    
    _feeContent.attributedText = [NSString changeString:[NSString stringWithFormat:@"备注: %@",model.memo] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _feeType = [UILabel new];
    _feeType.textAlignment = NSTextAlignmentLeft;
    _feeType.textColor = UIColorFromRGB(0x404040);
    _feeType.font = [UIFont boldSystemFontOfSize:14.0f];
    
    _feeStatus = [UILabel new];
    _feeStatus.textAlignment = NSTextAlignmentRight;
    _feeStatus.textColor = UIColorFromRGB(0x2EB2EF);
    _feeStatus.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _feeName = [UILabel new];
    _feeName.textAlignment = NSTextAlignmentLeft;
    _feeName.textColor = UIColorFromRGB(0x404040);
    _feeName.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _feePrice = [UILabel new];
    _feePrice.textAlignment = NSTextAlignmentRight;
    _feePrice.textColor = UIColorFromRGB(0x404040);
    _feePrice.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _feeContent = [UILabel new];
    _feeContent.numberOfLines = 0;
    _feeContent.textAlignment = NSTextAlignmentLeft;
    _feeContent.textColor = UIColorFromRGB(0x404040);
    _feeContent.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _line1 = [UIView new];
    _line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    [self.contentView sd_addSubviews:@[_feeType,_feeStatus,_line1,_feeName,_feePrice,_feeContent]];
    
    [self addLayoutSubviews];
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat spcing = 5;
    CGFloat h = 15;
    
    _feeType.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _feeStatus.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _line1.sd_layout
    .topSpaceToView(_feeType,top)
    .leftSpaceToView(self.contentView,0)
    .rightSpaceToView(self.contentView,0)
    .heightIs(1);
    
    _feeName.sd_layout
    .topSpaceToView(_line1,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _feePrice.sd_layout
    .topSpaceToView(_line1,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
//    _feeContent.sd_layout
//    .topSpaceToView(_feeName,spcing)
//    .rightSpaceToView(self.contentView,right)
//    .leftSpaceToView(self.contentView,left)
//    .heightIs(h*2+5);
    
    _feeContent.sd_layout
    .topSpaceToView(_feeName,spcing)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .autoHeightRatio(0);
    
    [self setupAutoHeightWithBottomView:_feeContent bottomMargin:top];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
