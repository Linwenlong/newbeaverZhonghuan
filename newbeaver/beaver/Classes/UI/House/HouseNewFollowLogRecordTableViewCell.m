//
//  HouseNewFollowLogRecordTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/8/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseNewFollowLogRecordTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+LWLTimestamp.h"

@interface HouseNewFollowLogRecordTableViewCell ()

@property (nonatomic, strong) UIImageView * icon;

@property (nonatomic, strong) UILabel * nameAndDeparment;

@property (nonatomic, strong) UILabel * content;

@property (nonatomic, strong) UIView * record;

@property (nonatomic, strong) UIImageView * playerIcon;

@property (nonatomic, strong) UILabel * date;

@property (nonatomic, strong) UILabel * type;

@end

@implementation HouseNewFollowLogRecordTableViewCell

- (NSString *)calculateSecond:(NSInteger)tmpSeconds{
    
    NSInteger hours;
    NSInteger minute;
    NSInteger seconds;
    
    if (tmpSeconds >= 3600) {
        
        hours = tmpSeconds / 3600;
        
        NSInteger  residueSeconds = tmpSeconds % 3600;
        
        if (residueSeconds >= 60) {
            
            minute = residueSeconds / 60;
            seconds = residueSeconds % 60;
            
        }else{
            
            minute = 0;
            seconds = residueSeconds;
            
        }
        
    }else if (tmpSeconds < 3600 && tmpSeconds >= 60){
        
        hours = 0 ;
        
        minute = tmpSeconds / 60;
        
        seconds = tmpSeconds % 60;
        
        
    }else if(tmpSeconds < 60 && tmpSeconds > 0){
        
        hours = 0 ;
        
        minute = 0;
        
        seconds = tmpSeconds;
    }else{
        hours = 0 ;
        
        minute = 0;
        
        seconds = 0;
    }
    
    NSLog(@"hour=%ld",hours);
    NSLog(@"minute=%ld",minute);
    NSLog(@"seconds=%ld",seconds);
    NSString *resultStr = @"";
    //    NSMutableString *resultStr = [[NSMutableString alloc]init];
    
    //
    resultStr = hours != 0 ? [resultStr stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"%ld:",hours]]: @"";
    resultStr = minute != 0 ? [resultStr stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"%ld:",minute]]: @"";
    resultStr = seconds != 0 ? [resultStr stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"%ld",seconds]]: @"";
    //   if (hours > 0) {
    //       [resultStr stringByAppendingString:[NSString stringWithFormat:@"%ldh",hours]];
    //   }
    //
    NSLog(@"resultStr = %@",resultStr);
    return resultStr;
}


- (void)setDic:(NSDictionary *)dic{
    [_icon sd_setImageWithURL:[NSURL URLWithString:dic[@"avatar"]] placeholderImage:[UIImage imageNamed:@"hidden_no_call"]];
    if ([dic[@"department"] isEqualToString:@"<null>"]||dic[@"department"] == nil || [dic[@"department"] isEqual:[NSNull null]]) {
        _nameAndDeparment.text = [NSString stringWithFormat:@"%@",dic[@"user"]];
    }else{
        _nameAndDeparment.text = [NSString stringWithFormat:@"%@  %@",dic[@"user"],dic[@"department"]];
    }
    _content.text = dic[@"content"];
    _durationLable.text = [NSString stringWithFormat:@"%@",[self calculateSecond:[dic[@"c_record"][@"play_time"] integerValue]]];
    
    NSString *tmpStr =[NSString stringWithFormat:@"%@",dic[@"date"]];
    
    NSString *timeStr = [NSString timeWithTimeIntervalString:tmpStr format:@"yyyy-MM-dd hh:mm:ss"];
    
    _date.text = [NSString stringWithFormat:@"%@  %@",timeStr,dic[@"way"]];
}

- (void)setModel:(HouseNewFollowLogRecordModel *)model{
    
    [_icon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:nil];
    _nameAndDeparment.text = [NSString stringWithFormat:@"%@  %@",model.user,model.department];
    _content.text = model.content;
//    _durationLable.text = [NSString stringWithFormat:@"%ld",[model.c_record[@"play_time"] integerValue]];
    
    
    _date.text = [NSString stringWithFormat:@"%@  %@",model.date,model.way];
    
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
    _content.textColor = [UIColor blackColor];
    _content.numberOfLines = 0;
    _content.textAlignment = NSTextAlignmentLeft;
    _content.font = [UIFont systemFontOfSize:14.0f];
    
    _record = [UIView new];
    _record.backgroundColor = [UIColor whiteColor];
    _record.layer.cornerRadius = 5.0f;
    _record.clipsToBounds = YES;
    _record.layer.borderWidth = 1.0f;
    _record.layer.borderColor = [UIColor blackColor].CGColor;
    _record.userInteractionEnabled = YES;
    
    _date = [UILabel new];
    _date.text = @"2018-07-03 08:30:30  房源跟进";
    _date.textColor = [UIColor blackColor];
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = [UIFont systemFontOfSize:13.0f];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
    [_record addGestureRecognizer:tap];
    
    [self.contentView sd_addSubviews:@[_icon,_nameAndDeparment,_content,_date,_record]];
    
    
    _playerIcon = [UIImageView new];
    _playerIcon.image = [UIImage imageNamed:@"hidden_noplayer"];
    //    _playerIcon.backgroundColor = [UIColor redColor];
    
    _durationLable = [UILabel new];
    _durationLable.textColor = [UIColor blackColor];
    _durationLable.text = @"01:30";
    _durationLable.layer.cornerRadius = 5.0f;
    _durationLable.textAlignment = NSTextAlignmentCenter;
    _durationLable.font = [UIFont systemFontOfSize:13.0f];
    
    _currentDuration = [UIView new];
    _currentDuration.layer.borderWidth = 1.0f;
    _currentDuration.clipsToBounds = YES;
    _currentDuration.layer.borderColor = [UIColor colorWithRed:0.75 green:1.00 blue:1.00 alpha:1.00].CGColor;
    _currentDuration.backgroundColor = [UIColor colorWithRed:0.75 green:1.00 blue:1.00 alpha:1.00];
    
    [_record sd_addSubviews:@[_currentDuration,_playerIcon,_durationLable]];
    
    
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
    
    _record.sd_layout
    .widthIs(kScreenW - 2 * x- icon_h - 5)
    .leftSpaceToView(_icon, 5)
    .topSpaceToView(_content, 0)
    .heightIs(25);
    
    _playerIcon.sd_layout
    .topSpaceToView(_record, 2.5)
    .leftSpaceToView(_record, 8)
    .widthIs(20)
    .heightIs(20);
    
    _durationLable.sd_layout
    .centerXEqualToView(_record)
    .centerYEqualToView(_record)
    .widthIs(_record.width-40)
    .heightIs(20);
    
    _date.sd_layout
    .topSpaceToView(_record,spcing)
    .leftSpaceToView(_icon,5)
    .rightSpaceToView(self.contentView, x)
    .heightIs(20);
    
//    [self setupAutoHeightWithBottomView:_date bottomMargin:y];
    //    _currentDuration.sd_layout
    //    .topSpaceToView(_record, 0)
    //    .leftSpaceToView(_record, 0)
    //    .widthIs(0)
    //    .bottomSpaceToView(_record, 0);
    NSLog(@"_record.frame=%@",NSStringFromCGRect(_record.frame));
    _currentDuration.frame = _record.frame;
    _currentDuration.mj_x = 1;
    _currentDuration.mj_y = 1;
    _currentDuration.width = 0;
    NSLog(@"_currentDuration=%@",NSStringFromCGRect(_currentDuration.frame));
    
    
}

- (void)viewClick:(UITapGestureRecognizer *)tap{
    self.playRecord(_currentDuration,_durationLable,_playerIcon);
}



@end
