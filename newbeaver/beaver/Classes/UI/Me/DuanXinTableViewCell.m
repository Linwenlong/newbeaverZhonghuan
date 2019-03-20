//
//  DuanXinTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "DuanXinTableViewCell.h"

@interface DuanXinTableViewCell ()


@property (nonatomic, strong) UIView * backGroundView;
@property (nonatomic, strong) UILabel * homeContact;//房源编号
@property (nonatomic, strong) UIImageView * nameIcon;
@property (nonatomic, strong) UILabel * name;//接收人
@property (nonatomic, strong) UILabel * timeDate;//日期
@property (nonatomic, strong) UILabel * content;//内容

@end

@implementation DuanXinTableViewCell

- (void)setDic:(NSDictionary *)dic{
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
    
    _nameIcon = [UIImageView new];
    _nameIcon.image = [UIImage imageNamed:@"hidden_people"];
    
    _name = [UILabel new];

    _name.textAlignment = NSTextAlignmentLeft;
    _name.font = font1;
    _name.textColor = [UIColor blackColor];
    
    _homeContact = [UILabel new];

    _homeContact.textAlignment = NSTextAlignmentLeft;
    _homeContact.font = font1;
    _homeContact.textColor = [UIColor blackColor];
    
    _timeDate = [UILabel new];

    _timeDate.textAlignment = NSTextAlignmentRight;
    _timeDate.font = font1;
    _timeDate.textColor = [UIColor blackColor];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00];
    
    _content = [UILabel new];

    _content.textAlignment = NSTextAlignmentLeft;
    _content.numberOfLines = 0;
    _content.font = font2;
    _content.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_backGroundView];
    
    [_backGroundView sd_addSubviews:@[_homeContact,_nameIcon,_name,_timeDate,line,_content]];
    
//    [self.contentView sd_addSubviews:@[_homeContact,_name,_timeDate,line,_content]];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    CGFloat X = 10;
    CGFloat Y = X;
    CGFloat spcing = 8;
    CGFloat h = 20;
    CGFloat w = (kScreenW-2*X)/2.0f;
    
    _backGroundView.sd_layout
    .topSpaceToView(self.contentView, X)
    .leftSpaceToView(self.contentView, X)
    .rightSpaceToView(self.contentView, X)
    .bottomSpaceToView(self.contentView, X);
    
    _nameIcon.sd_layout
    .topSpaceToView(_backGroundView,2)
    .leftSpaceToView(_backGroundView,X-5)
    .widthIs(36)
    .heightIs(36);
    
    _name.sd_layout
    .topSpaceToView(_backGroundView,Y)
    .leftSpaceToView(_nameIcon,0)
    .widthIs(45)
    .heightIs(h);
    
    _homeContact.sd_layout
    .topSpaceToView(_backGroundView,Y)
    .leftSpaceToView(_name,0)
    .widthIs(150)
    .heightIs(h);
    
    _timeDate.sd_layout
    .topSpaceToView(_backGroundView,Y)
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
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
