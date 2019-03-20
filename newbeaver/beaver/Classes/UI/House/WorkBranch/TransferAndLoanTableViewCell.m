//
//  TransferAndLoanTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "TransferAndLoanTableViewCell.h"

@interface TransferAndLoanTableViewCell ()

@property (nonatomic, strong)UIImageView *statusIcon;
@property (nonatomic, strong)UILabel *statusTitle;//状态
@property (nonatomic, strong)UILabel *statusContent;
@property (nonatomic, strong)UIImageView *accoryIcon;


@end

@implementation TransferAndLoanTableViewCell

- (void)setStatusTransfer:(NSDictionary *)dic isLoan:(BOOL)isLoan{
    if (isLoan == NO) {//过户
        NSDictionary *ghTradeProcess = dic[@"ghTradeProcess"];
        NSInteger time = [ghTradeProcess[@"addTime"] integerValue];
        NSString *timeStr = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",time/1000] format:@"yyyy年MM月dd日"];
        if ([ghTradeProcess[@"status"] isEqualToString:@"u"]) {//未办理
            _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
            _statusTitle.text = [NSString stringWithFormat:@"%@未办理",ghTradeProcess[@"processName"]];
            _statusContent.text =[NSString stringWithFormat:@"%@%@未办理",timeStr,ghTradeProcess[@"processName"]];
        }else if ([ghTradeProcess[@"status"] isEqualToString:@"s"]){//成功
            _statusIcon.image = [UIImage imageNamed:@"chargeSucess"];
            _statusTitle.text = [NSString stringWithFormat:@"%@成功",ghTradeProcess[@"processName"]];
            _statusContent.text =[NSString stringWithFormat:@"%@%@成功",timeStr,ghTradeProcess[@"processName"]];
        }else if ([ghTradeProcess[@"status"] isEqualToString:@"d"]){//延期
            _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
            _statusTitle.text = [NSString stringWithFormat:@"%@延期",ghTradeProcess[@"processName"]];
            _statusContent.text =[NSString stringWithFormat:@"%@%@延期",timeStr,ghTradeProcess[@"processName"]];
        }else if ([ghTradeProcess[@"status"] isEqualToString:@"f"]){//异常
            _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
            _statusTitle.text = [NSString stringWithFormat:@"%@异常",ghTradeProcess[@"processName"]];
            _statusContent.text =[NSString stringWithFormat:@"%@%@异常",timeStr,ghTradeProcess[@"processName"]];
        }
    }else{//贷款
       
        if ([dic[@"dkTradeProcess"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dkTradeProcess = dic[@"dkTradeProcess"];
            NSInteger time = [dkTradeProcess[@"addTime"] integerValue];
            NSString *timeStr = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",time/1000] format:@"yyyy年MM月dd日"];
            if ([dkTradeProcess[@"status"] isEqualToString:@"u"]) {//未办理
                _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
                _statusTitle.text = [NSString stringWithFormat:@"%@未办理",dkTradeProcess[@"processName"]];
                _statusContent.text =[NSString stringWithFormat:@"%@%@未办理",timeStr,dkTradeProcess[@"processName"]];
            }else if ([dkTradeProcess[@"status"] isEqualToString:@"s"]){//成功
                _statusIcon.image = [UIImage imageNamed:@"chargeSucess"];
                _statusTitle.text = [NSString stringWithFormat:@"%@成功",dkTradeProcess[@"processName"]];
                _statusContent.text =[NSString stringWithFormat:@"%@%@成功",timeStr,dkTradeProcess[@"processName"]];
            }else if ([dkTradeProcess[@"status"] isEqualToString:@"d"]){//延期
                _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
                _statusTitle.text = [NSString stringWithFormat:@"%@延期",dkTradeProcess[@"processName"]];
                _statusContent.text =[NSString stringWithFormat:@"%@%@延期",timeStr,dkTradeProcess[@"processName"]];
            }else if ([dkTradeProcess[@"status"] isEqualToString:@"f"]){//异常
                _statusIcon.image = [UIImage imageNamed:@"chargeFailure"];
                _statusTitle.text = [NSString stringWithFormat:@"%@异常",dkTradeProcess[@"processName"]];
                _statusContent.text =[NSString stringWithFormat:@"%@%@异常",timeStr,dkTradeProcess[@"processName"]];
            }
        }
    }
}

-(void)setDic:(NSDictionary *)dic{
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _statusIcon = [UIImageView new];
    _statusIcon.image = [UIImage imageNamed:@"chargeSucess"];
    
    _statusTitle = [UILabel new];
    _statusTitle.textAlignment = NSTextAlignmentLeft;
    _statusTitle.text = @"注销抵押已完成";
    _statusTitle.textColor = UIColorFromRGB(0x404040);
    _statusTitle.font = [UIFont systemFontOfSize:13.0f];
    
    _statusContent = [UILabel new];
    _statusContent.textAlignment = NSTextAlignmentLeft;
    _statusContent.text = @"2017年09月28日已完成注销抵押";
    _statusContent.textColor = UIColorFromRGB(0x808080);
    _statusContent.font = [UIFont systemFontOfSize:13.0f];
    
   
    _accoryIcon = [UIImageView new];
    _accoryIcon.image = [UIImage imageNamed:@"jiantou"];
    
    [self.contentView sd_addSubviews:@[_statusIcon,_statusTitle,_statusContent,_accoryIcon]];
    
    [self addLayoutSubviews];
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    
    CGFloat h = 15;
    
    _statusIcon.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(h)
    .heightIs(h);
    
    _accoryIcon.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs(7)
    .heightIs(12);
    
    _statusTitle.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(_statusIcon,3)
    .rightSpaceToView(_accoryIcon,right)
    .heightIs(h);
    
    _statusContent.sd_layout
    .topSpaceToView(_statusTitle,10)
    .leftEqualToView(_statusTitle)
    .rightSpaceToView(self.contentView,right)
    .heightIs(h);
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
