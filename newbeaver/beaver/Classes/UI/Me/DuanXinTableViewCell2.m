//
//  DuanXinTableViewCell2.m
//  beaver
//
//  Created by 林文龙 on 2018/7/25.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "DuanXinTableViewCell2.h"

@interface DuanXinTableViewCell2 ()


@property (nonatomic, strong) UIView * backGroundView;

@property (nonatomic, strong) UILabel * countLable;//消费的条数

@property (nonatomic, strong) UILabel * homeContact;//房源编号

@property (nonatomic, strong) UIImageView * nameIcon;
@property (nonatomic, strong) UILabel * name;//接收人
@property (nonatomic, strong) UILabel * timeDate;//日期
@property (nonatomic, strong) UILabel * content;//内容

@end

@implementation DuanXinTableViewCell2

- (void)setDic:(NSDictionary *)dic andCount:(NSString *)count{
    
    NSString *countStr = [[NSString alloc]initWithFormat:@"当月消费%@条",count];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:countStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x2e2e2e) range:NSMakeRange(0, 4)];
    
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xff2c25) range:NSMakeRange(4, count.length)];
    
    [attributeStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x2e2e2e) range:NSMakeRange(4+count.length, countStr.length-4-count.length)];
    _countLable.attributedText = attributeStr;
    
    _name.text = dic[@"addressee"];
    _homeContact.text = dic[@"fk_code"];
    NSString *timeStr = [NSString timeWithTimeIntervalString:dic[@"sender_date"] format:@"MM-dd HH:mm"];
    _timeDate.text = [NSString stringWithFormat:@"%@",timeStr];
    
    _content.text = dic[@"context"];
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
    UIFont *font1 = [UIFont systemFontOfSize:13.0f];
    UIFont *font2 = [UIFont systemFontOfSize:12.0f];
    
    _backGroundView = [UIView new];
    _backGroundView.backgroundColor = [UIColor whiteColor];
    
    _countLable = [UILabel new];

    _countLable.textAlignment = NSTextAlignmentLeft;
    _countLable.font = font1;
    _countLable.textColor = [UIColor blackColor];
    UIView *countline = [UIView new];
    countline.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.00];
    
    _nameIcon = [UIImageView new];
    _nameIcon.image = [UIImage imageNamed:@"hidden_people"];
    
    _name = [UILabel new];
    

    _name.textAlignment = NSTextAlignmentLeft;
    _name.font = font1;
    _name.textColor = UIColorFromRGB(0x404040);
    
    _homeContact = [UILabel new];

    _homeContact.textAlignment = NSTextAlignmentLeft;
    _homeContact.font = font1;
    _homeContact.textColor = UIColorFromRGB(0x404040);
    
    _timeDate = [UILabel new];
 
    _timeDate.textAlignment = NSTextAlignmentRight;
    _timeDate.font = font1;
    _timeDate.textColor = UIColorFromRGB(0x404040);
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.00];
    
    _content = [UILabel new];
    _content.text = @"您好!我是刚给您电话的中环地产经纪人xx，感谢您的接听,我的分机号是xxxxx,欢迎拨打0791-888888前来咨询!祝您生活愉快!前来咨询!祝您生活愉快!";
    _content.textAlignment = NSTextAlignmentLeft;
    _content.numberOfLines = 0;
    _content.font = font2;
    _content.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_backGroundView];
    
    [_backGroundView sd_addSubviews:@[_countLable,countline,_homeContact,_nameIcon,_name,_timeDate,line,_content]];
    
    //    [self.contentView sd_addSubviews:@[_homeContact,_name,_timeDate,line,_content]];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    CGFloat X = 10;
    CGFloat Y = 15;
    CGFloat spcing = 8;
    CGFloat h = 20;
    CGFloat w = (kScreenW-2*X)/2.0f;
    
    _backGroundView.sd_layout
    .topSpaceToView(self.contentView, 0)
    .leftSpaceToView(self.contentView, X)
    .rightSpaceToView(self.contentView, X)
    .bottomSpaceToView(self.contentView, 0);
    
    _countLable.sd_layout
    .topSpaceToView(_backGroundView,Y)
    .leftSpaceToView(_backGroundView,X)
    .widthIs(100)
    .heightIs(h);
    
    countline.sd_layout
    .topSpaceToView(_countLable, Y)
    .leftSpaceToView(_backGroundView, 0)
    .rightSpaceToView(_backGroundView, 0)
    .heightIs(1);
    
    _nameIcon.sd_layout
    .topSpaceToView(countline,7)
    .leftSpaceToView(_backGroundView,X-5)
    .widthIs(36)
    .heightIs(36);
    
    _name.sd_layout
    .topSpaceToView(countline,Y)
    .leftSpaceToView(_nameIcon,0)
    .widthIs(45)
    .heightIs(h);
    
    _homeContact.sd_layout
    .topSpaceToView(countline,Y)
    .leftSpaceToView(_name,0)
    .widthIs(150)
    .heightIs(h);
    
    _timeDate.sd_layout
    .topSpaceToView(countline,Y)
    .rightSpaceToView(_backGroundView,X)
    .widthIs(100)
    .heightIs(h);
    
    line.sd_layout
    .topSpaceToView(_name, Y)
    .leftSpaceToView(_backGroundView, 0)
    .rightSpaceToView(_backGroundView, 0)
    .heightIs(1);
    
    _content.sd_layout
    .topSpaceToView(line, Y)
    .leftSpaceToView(_backGroundView, X)
    .rightSpaceToView(_backGroundView, X)
    .heightIs(45);
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
