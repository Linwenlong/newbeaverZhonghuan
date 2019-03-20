//
//  SatisfiedInvestTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SatisfiedInvestTableViewCell.h"
#import "SatisfiedInvestModel.h"

@interface SatisfiedInvestTableViewCell ()
//judge
@property (nonatomic, strong)UILabel * visitType;//回访类型
@property (nonatomic, strong)UILabel * visitObject;//回访对象
@property (nonatomic, strong)UIView  * line1;//线条1

@property (nonatomic, strong)UILabel  * deptJudge;//门店评价
@property (nonatomic, strong)UILabel  * clientJudge;//客户评价
@property (nonatomic, strong)UILabel  * warrantJudge;//权证评价
@property (nonatomic, strong)UILabel  * officeJudge;//内勤评价
@property (nonatomic, strong)UILabel  * fieldworkJudge;//外勤评价

@property (nonatomic, strong)UILabel  * isorNot;//是否可以转

@property (nonatomic, strong)UIView  * line2;//线条2

@property (nonatomic, strong)UILabel  * visitDate;//回访时间
@property (nonatomic, strong)UILabel  * keyIn;//录入
@property (nonatomic, strong)UILabel  * keyInDate;//录入时间

@property (nonatomic, strong)UILabel  * remarks;//备注

@end

@implementation SatisfiedInvestTableViewCell

- (void)setModel:(SatisfiedInvestModel *)model{

    _visitType.attributedText = [NSString changeString:[NSString stringWithFormat:@"回访类型: %@",model.visitType] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
     _visitObject.attributedText = [NSString changeString:[NSString stringWithFormat:@"回访对象: %@",model.visitObject] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _deptJudge.attributedText = [NSString changeString:[NSString stringWithFormat:@"门店评价: %@",model.deptJudge] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _clientJudge.attributedText = [NSString changeString:[NSString stringWithFormat:@"客户评价: %@",model.clientJudge] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _warrantJudge.attributedText = [NSString changeString:[NSString stringWithFormat:@"权证评价: %@",model.warrantJudge] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _officeJudge.attributedText = [NSString changeString:[NSString stringWithFormat:@"内勤评价: %@",model.officeJudge] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _fieldworkJudge.attributedText = [NSString changeString:[NSString stringWithFormat:@"外勤评价: %@",model.fieldworkJudge] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _isorNot.attributedText = [NSString changeString:[NSString stringWithFormat:@"是否愿转介绍: %@",model.isorNot] frontLength:8 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    
    NSString *visitTime = [NSString timeWithTimeIntervalString:model.visitDate];
    _visitDate.attributedText = [NSString changeString:[NSString stringWithFormat:@"回访时间: %@",visitTime] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];

    _keyIn.attributedText = [NSString changeString:[NSString stringWithFormat:@"录入人: %@",model.keyIn] frontLength:5 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
  
    NSString *keyinTime = [NSString timeWithTimeIntervalString:model.keyInDate];
    _keyInDate.attributedText = [NSString changeString:[NSString stringWithFormat:@"录入时间: %@",keyinTime] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    
    _remarks.attributedText = [NSString changeString:[NSString stringWithFormat:@"备注: %@",model.remarks] frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _visitType = [UILabel new];
    _visitType.textAlignment = NSTextAlignmentLeft;
    _visitType.textColor = UIColorFromRGB(0x404040);
    _visitType.font = [UIFont systemFontOfSize:13.0f];
    
    _visitObject = [UILabel new];
    _visitObject.textAlignment = NSTextAlignmentRight;
   
    _visitObject.textColor = UIColorFromRGB(0x404040);
    _visitObject.font = [UIFont systemFontOfSize:13.0f];
    
    _line1 = [UIView new];
    _line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _deptJudge = [UILabel new];
    _deptJudge.textAlignment = NSTextAlignmentLeft;
   
    _deptJudge.textColor = UIColorFromRGB(0x404040);
    _deptJudge.font = [UIFont systemFontOfSize:13.0f];
    
    _clientJudge = [UILabel new];
    _clientJudge.textAlignment = NSTextAlignmentLeft;
   
    _clientJudge.textColor = UIColorFromRGB(0x404040);
    _clientJudge.font = [UIFont systemFontOfSize:13.0f];
    
    _warrantJudge = [UILabel new];
    _warrantJudge.textAlignment = NSTextAlignmentLeft;
    
    _warrantJudge.textColor = UIColorFromRGB(0x404040);
    _warrantJudge.font = [UIFont systemFontOfSize:13.0f];
    
    _officeJudge = [UILabel new];
    _officeJudge.textAlignment = NSTextAlignmentLeft;
   
    _officeJudge.textColor = UIColorFromRGB(0x404040);
    _officeJudge.font = [UIFont systemFontOfSize:13.0f];
    
    _fieldworkJudge = [UILabel new];
    _fieldworkJudge.textAlignment = NSTextAlignmentLeft;
    
    _fieldworkJudge.textColor = UIColorFromRGB(0x404040);
    _fieldworkJudge.font = [UIFont systemFontOfSize:13.0f];
    
    _isorNot = [UILabel new];
    _isorNot.textAlignment = NSTextAlignmentLeft;
 
    _isorNot.textColor = UIColorFromRGB(0x404040);
    _isorNot.font = [UIFont systemFontOfSize:13.0f];
    
    _line2 = [UIView new];
    _line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _visitDate = [UILabel new];
    _visitDate.textAlignment = NSTextAlignmentLeft;
 
    _visitDate.textColor = UIColorFromRGB(0x404040);
    _visitDate.font = [UIFont systemFontOfSize:13.0f];
    
    _keyIn = [UILabel new];
    _keyIn.textAlignment = NSTextAlignmentRight;

    _keyIn.textColor = UIColorFromRGB(0x404040);
    _keyIn.font = [UIFont systemFontOfSize:13.0f];
    
    _keyInDate = [UILabel new];
    _keyInDate.textAlignment = NSTextAlignmentLeft;

    _keyInDate.textColor = UIColorFromRGB(0x404040);
    _keyInDate.font = [UIFont systemFontOfSize:13.0f];
    
    _remarks = [UILabel new];
    _remarks.textAlignment = NSTextAlignmentLeft;
 
    _remarks.textColor = UIColorFromRGB(0x404040);
    _remarks.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_visitType,_visitObject,_line1,_deptJudge,_clientJudge,_warrantJudge,_officeJudge,_fieldworkJudge,_isorNot,_line2,_visitDate,_keyIn,_keyInDate,_remarks]];

    [self addLayoutSubviews];
    
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat spcing = 5;
    CGFloat h = 15;
    
    _visitType.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _visitObject.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _line1.sd_layout
    .topSpaceToView(_visitType,top)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(1);
    
    _deptJudge.sd_layout
    .topSpaceToView(_line1,top)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .autoHeightRatio(0);
    
    _clientJudge.sd_layout
    .topSpaceToView(_deptJudge,spcing)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .autoHeightRatio(0);
    
    _warrantJudge.sd_layout
    .topSpaceToView(_clientJudge,spcing)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(h);
    
    _officeJudge.sd_layout
    .topSpaceToView(_warrantJudge,spcing)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(h);
    
    _fieldworkJudge.sd_layout
    .topSpaceToView(_officeJudge,spcing)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(h);
    
    _isorNot.sd_layout
    .topSpaceToView(_fieldworkJudge,spcing)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(h);
    
    _line2.sd_layout
    .topSpaceToView(_isorNot,top)
    .rightSpaceToView(self.contentView,right)
    .leftSpaceToView(self.contentView,left)
    .heightIs(1);
    
    
    _visitDate.sd_layout
    .topSpaceToView(_line2,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _keyIn.sd_layout
    .topSpaceToView(_line2,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    
    _keyInDate.sd_layout
    .topSpaceToView(_visitDate,spcing)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
   
    _remarks.sd_layout
    .topSpaceToView(_keyInDate,spcing)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .autoHeightRatio(0);
   
    
    [self setupAutoHeightWithBottomView:_remarks bottomMargin:top];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
