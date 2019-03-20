//
//  HouseNewFollowLogTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/8/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseNewFollowLogTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface HouseNewFollowLogTableViewCell ()

@property (nonatomic, strong) UIImageView * icon;

@property (nonatomic, strong) UILabel * nameAndDeparment;

@property (nonatomic, strong) UILabel * content;

@property (nonatomic, strong) UILabel * date;

@end

@implementation HouseNewFollowLogTableViewCell

- (void)setDic:(NSDictionary *)dic{
    [_icon sd_setImageWithURL:[NSURL URLWithString:dic[@"avatar"]] placeholderImage:[UIImage imageNamed:@"hidden_no_call"]];
    if ([dic[@"department"] isEqualToString:@"<null>"]||dic[@"department"] == nil || [dic[@"department"] isEqual:[NSNull null]]) {
        _nameAndDeparment.text = [NSString stringWithFormat:@"%@",dic[@"user"]];
    }else{
        _nameAndDeparment.text = [NSString stringWithFormat:@"%@  %@",dic[@"user"],dic[@"department"]];
    }
    _content.text = dic[@"content"];
    NSString *tmpStr =[NSString stringWithFormat:@"%@",dic[@"date"]];
    NSString *timeStr = [NSString timeWithTimeIntervalString:tmpStr format:@"yyyy-MM-dd hh:mm:ss"];
    
    _date.text = [NSString stringWithFormat:@"%@  %@",timeStr,dic[@"way"]];
}

- (void)setModel:(HouseNewFollowLogModel *)model{
    [_icon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:nil];
    _nameAndDeparment.text = [NSString stringWithFormat:@"%@  %@",model.user,model.department];
    _content.text = model.content;
    _date.text = [NSString stringWithFormat:@"%@  %@",model.date,model.way];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    _icon = [UIImageView new];
    _icon.layer.cornerRadius = 30.f;
    _icon.clipsToBounds = YES;
    [_icon sd_setImageWithURL:[NSURL URLWithString:@"http://nccdn.zhdclink.com/zh_nc/104/house/2015/16-03/a8e82b24-f657-403f-b6eb-3dfd3314cbba.jpg"] placeholderImage:nil];
    
    _nameAndDeparment = [UILabel new];
    _nameAndDeparment.text = @"张三 南大A店";
    _nameAndDeparment.textColor = [UIColor blackColor];
    _nameAndDeparment.textAlignment = NSTextAlignmentLeft;
    _nameAndDeparment.font = [UIFont systemFontOfSize:14.0f];
    
    _content = [UILabel new];
    _content.text = @"看房提前一天预约";
    _content.numberOfLines = 0;
    _content.textColor = [UIColor blackColor];
    _content.textAlignment = NSTextAlignmentLeft;
    _content.font = [UIFont systemFontOfSize:14.0f];
    
    
    _date = [UILabel new];
    _date.text = @"2018-07-03 08:30:30  房源跟进";
    _date.textColor = [UIColor blackColor];
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = [UIFont systemFontOfSize:13.0f];
    
 
    
    [self.contentView sd_addSubviews:@[_icon,_nameAndDeparment,_content,_date,]];
    
 
    
    
    CGFloat x = 15;
    CGFloat y = x ;
    CGFloat icon_h = 60;
    CGFloat icon_w = icon_h;
    CGFloat spcing = x;
    
    _icon.sd_layout
    .centerYEqualToView(self.contentView)
    .leftSpaceToView(self.contentView,y)
    .widthIs(icon_w)
    .heightIs(icon_h);
    
    _nameAndDeparment.sd_layout
    .topSpaceToView(self.contentView,y)
    .leftSpaceToView(_icon,5)
    .widthIs(kScreenW -x - icon_w - 5)
    .heightIs(20);
    
    _content.sd_layout
    .topSpaceToView(_nameAndDeparment,0)
    .leftSpaceToView(_icon,5)
    .widthIs(kScreenW -x - icon_w - 5)
    .heightIs(50);
    
    _date.sd_layout
    .topSpaceToView(_content,0)
    .leftSpaceToView(_icon,5)
    .rightSpaceToView(self.contentView, x)
    .heightIs(20);
    
//    [self setupAutoHeightWithBottomView:_date bottomMargin:y];
 
    
}


@end
