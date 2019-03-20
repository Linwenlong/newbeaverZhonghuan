//
//  AchievementTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "AchievementTableViewCell.h"

@interface AchievementTableViewCell ()

@property (nonatomic, strong)UILabel * dept_name;//分成人
@property (nonatomic, strong)UILabel * reason;//分成缘由

@property (nonatomic, strong)UILabel * proportionNum;//分成数值
@property (nonatomic, strong)UILabel * proportionType;//分成比例

@property (nonatomic, strong)UILabel * achievementNum;//业绩数值

@property (nonatomic, strong)UILabel * achievementType;//实收业绩

@end

@implementation AchievementTableViewCell

-(void)setDic:(NSDictionary *)dic{
    _dept_name.attributedText = [NSString changeString:[NSString stringWithFormat:@"分成人: %@-%@",dic[@"department"],dic[@"username"]] frontLength:5 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    _reason.attributedText = [NSString changeString:[NSString stringWithFormat:@"分成缘由: %@",dic[@"commission_type"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
    NSString *proportionNum = [NSString stringWithFormat:@"%@",dic[@"proportion"]];
    [proportionNum stringByAppendingString:@"%"];
    _proportionNum.text = proportionNum;
    NSLog(@"floatValue=%f",[dic[@"proportion"] floatValue]/100.0f);
    NSLog(@"_paid_money=%f",_paid_money);
    CGFloat achievementNum = ([dic[@"proportion"] floatValue]/100.0f) * _paid_money;
    _achievementNum.text =  [NSString stringWithFormat:@"%0.2f",achievementNum];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _dept_name = [UILabel new];
    _dept_name.textAlignment = NSTextAlignmentLeft;
    _dept_name.text = @"分成人: 阳光嘉园－林文龙";
    _dept_name.textColor = UIColorFromRGB(0x404040);
    _dept_name.font = [UIFont systemFontOfSize:13.0f];
    
    _reason = [UILabel new];
    _reason.textAlignment = NSTextAlignmentLeft;
    _reason.text = @"分成缘由: 责任盘人";
    _reason.textColor = UIColorFromRGB(0x404040);
    _reason.font = [UIFont systemFontOfSize:13.0f];
    
    _proportionNum = [UILabel new];
    _proportionNum.textAlignment = NSTextAlignmentCenter;
    _proportionNum.text = @"3%";
    _proportionNum.textColor = UIColorFromRGB(0xff3800);
    _proportionNum.font = [UIFont systemFontOfSize:13.0f];
    
    _proportionType = [UILabel new];
    _proportionType.textAlignment = NSTextAlignmentCenter;
    _proportionType.text = @"分成比例";
    _proportionType.textColor = UIColorFromRGB(0x404040);
    _proportionType.font = [UIFont systemFontOfSize:13.0f];
    
    _achievementNum = [UILabel new];
    _achievementNum.textAlignment = NSTextAlignmentCenter;
    _achievementNum.text = @"134.65";
    _achievementNum.textColor = UIColorFromRGB(0xff3800);
    _achievementNum.font = [UIFont systemFontOfSize:13.0f];
    
    _achievementType = [UILabel new];
    _achievementType.textAlignment = NSTextAlignmentCenter;
    _achievementType.text = @"实收业绩(元)";
    _achievementType.textColor = UIColorFromRGB(0x404040);
    _achievementType.font = [UIFont systemFontOfSize:13.0f];
    
    [self.contentView sd_addSubviews:@[_dept_name,_reason,_proportionNum,_proportionType,_achievementNum,_achievementType]];
    
    [self addLayoutSubviews];
    
}

- (void)addLayoutSubviews{
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat spcing = 5;
    CGFloat h = 15;
    
    _dept_name.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _reason.sd_layout
    .topSpaceToView(_dept_name,spcing)
    .leftEqualToView(_dept_name)
    .widthIs(kScreenW/2.0f)
    .heightIs(h);
    
    _achievementNum.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:13.0f] content:@"实收业绩(元)"])
    .heightIs(h);
    
    _achievementType.sd_layout
    .topSpaceToView(_achievementNum,spcing)
    .rightEqualToView(_achievementNum)
    .widthRatioToView(_achievementNum,1)
    .heightIs(h);
    
    _proportionNum.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(_achievementNum,right)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:13.0f] content:@"分成比例"])
    .heightIs(h);
    
    _proportionType.sd_layout
    .topSpaceToView(_proportionNum,spcing)
    .rightEqualToView(_proportionNum)
    .widthRatioToView(_proportionNum,1)
    .heightIs(h);
    
}


- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
