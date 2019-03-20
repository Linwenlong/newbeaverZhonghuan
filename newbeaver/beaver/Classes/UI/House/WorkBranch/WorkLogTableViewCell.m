//
//  WorkLogTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "WorkLogTableViewCell.h"

@interface WorkLogTableViewCell ()

@property (nonatomic, strong)UILabel *logDate;
@property (nonatomic, strong)UILabel *logType;
@property (nonatomic, strong)UILabel *logName;

@property (nonatomic, strong)UILabel *logTept;
@property (nonatomic, strong)UILabel *logContent;

@end

@implementation WorkLogTableViewCell

- (void)setModel:(WorkLogModel *)model{
    
    _logDate.text = model.logDate;
    _logType.text = model.logType;
    _logName.text = model.logName;
    _logTept.text = model.logDept;
    _logContent.text = model.logContent;
    
    _logDate.attributedText = [NSString changeString:model.logDate frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _logType.attributedText = [NSString changeString:model.logType frontLength:4 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
//
    _logName.attributedText = [NSString changeString:model.logName frontLength:5 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
//
    _logTept.attributedText = [NSString changeString:model.logDept frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
//
    _logContent.attributedText = [NSString changeString:model.logContent frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _logDate = [UILabel new];
    _logDate.textAlignment = NSTextAlignmentLeft;
    _logDate.font = [UIFont systemFontOfSize:13.0f];
    _logDate.textColor = UIColorFromRGB(0x404040);
    
    _logType = [UILabel new];
    _logType.textAlignment = NSTextAlignmentLeft;
    _logType.font = [UIFont systemFontOfSize:13.0f];
    _logType.textColor = UIColorFromRGB(0x404040);
    
    _logName = [UILabel new];
    _logName.textAlignment = NSTextAlignmentLeft;
    _logName.font = [UIFont systemFontOfSize:13.0f];
    _logName.textColor = UIColorFromRGB(0x404040);
    
    _logTept = [UILabel new];
    _logTept.textAlignment = NSTextAlignmentLeft;
    _logTept.font = [UIFont systemFontOfSize:13.0f];
    _logTept.textColor = UIColorFromRGB(0x404040);
    
    _logContent = [UILabel new];
    _logContent.numberOfLines = 0;
    _logContent.textAlignment = NSTextAlignmentLeft;
    _logContent.font = [UIFont systemFontOfSize:13.0f];
    _logContent.textColor = UIColorFromRGB(0x404040);
    
    [self.contentView sd_addSubviews:@[_logDate,_logType,_logName,_logTept,_logContent]];
    
    [self addLayoutSubviews];
    
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;

    CGFloat h = 15;
    
    _logDate.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _logType.sd_layout
    .topSpaceToView(_logDate,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _logName.sd_layout
    .topSpaceToView(_logType,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _logTept.sd_layout
    .topSpaceToView(_logName,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
    _logContent.sd_layout
    .topSpaceToView(_logTept,top)
    .leftSpaceToView(self.contentView,left)
    .rightSpaceToView(self.contentView,right)
    .autoHeightRatio(0);
    
    [self setupAutoHeightWithBottomView:_logContent bottomMargin:top];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
