//
//  HouseCallRecordTableViewCell.m
//  beaver
//
//  Created by 林文龙 on 2018/7/20.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseCallRecordTableViewCell.h"
#import "SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "MusicPlayerView.h"

@interface HouseCallRecordTableViewCell ()<VedioPlayerViewDelegate>

@property (nonatomic, strong) UIImageView * icon;
@property (nonatomic, strong) UILabel * nameAndDeparment;
@property (nonatomic, strong) UILabel * date;
@property (nonatomic, strong) UIView * record;

@property (nonatomic, strong) UIImageView * playerIcon;



@end

@implementation HouseCallRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

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
    NSString *iconStr = dic[@"user"][@"avatar"];

    [_icon sd_setImageWithURL:[NSURL URLWithString:iconStr] placeholderImage:[UIImage imageNamed:@"hidden_no_call"]];
   
    
    _nameAndDeparment.text = [NSString stringWithFormat:@"%@ %@",dic[@"username"],dic[@"dept"][@"department"]];
    _durationLable.text = [NSString stringWithFormat:@"%@",[self calculateSecond:[dic[@"play_time"] integerValue]]];
//    _durationLable.text = [NSString stringWithFormat:@"%@",[self calculateSecond:3500]];
    _date.text = [NSString timeWithTimeIntervalString:dic[@"create_time"] format:@"yyyy-MM-dd HH:mm:ss"];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)viewClick:(UITapGestureRecognizer *)tap{
    self.playRecord(_currentDuration,_durationLable,_playerIcon);
}

- (void)setUI{
    _icon = [UIImageView new];
    _icon.layer.cornerRadius = 30.f;
    _icon.clipsToBounds = YES;
    
    
    _nameAndDeparment = [UILabel new];
    _nameAndDeparment.textColor = [UIColor blackColor];
    _nameAndDeparment.textAlignment = NSTextAlignmentLeft;
    _nameAndDeparment.font = [UIFont systemFontOfSize:14.0f];
    
    _date = [UILabel new];
    _date.textColor = [UIColor blackColor];
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = [UIFont systemFontOfSize:13.0f];

//    VedioModel *model = [[VedioModel alloc]init];
//    model.musicURL = @"http://117.40.248.135:8010/call/getOnTape?record_flag=1531107266329347&token=da4d06d1700df532f1d6dbdc63e36063";
   // http://117.40.248.135:8010/call/getOnTape?record_flag=1531107266329347&token=da4d06d1700df532f1d6dbdc63e36063
    _record = [UIView new];
    _record.backgroundColor = [UIColor whiteColor];
    _record.layer.cornerRadius = 5.0f;
    _record.clipsToBounds = YES;
    _record.layer.borderWidth = 1.0f;
    _record.layer.borderColor = [UIColor blackColor].CGColor;
    _record.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
    [_record addGestureRecognizer:tap];
    
     [self.contentView sd_addSubviews:@[_icon,_nameAndDeparment,_date,_record]];


    _playerIcon = [UIImageView new];
    _playerIcon.image = [UIImage imageNamed:@"hidden_noplayer"];
//    _playerIcon.backgroundColor = [UIColor redColor];
    
    _durationLable = [UILabel new];
    _durationLable.textColor = [UIColor blackColor];
    _durationLable.text = @"";
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
    
    _icon.sd_layout
    .topSpaceToView(self.contentView,x)
    .leftSpaceToView(self.contentView,y)
    .widthIs(icon_w)
    .heightIs(icon_h);
    
    _nameAndDeparment.sd_layout
    .topSpaceToView(self.contentView,y)
    .leftSpaceToView(_icon,5)
    .widthIs(140)
    .heightIs(20);
    
    _date.sd_layout
    .topSpaceToView(self.contentView,y)
    .rightSpaceToView(self.contentView, x)
    .widthIs(kScreenW-2*x-140-icon_w-5)
    .heightIs(20);
    
    _record.sd_layout
    .widthIs(kScreenW - 2*x- icon_h - 5)
    .leftSpaceToView(_icon, 5)
    .topSpaceToView(_nameAndDeparment, 10)
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

//播放失败的代理方法
-(void)playerViewFailed:(VedioPlayerView *)player {
    NSLog(@"播放失败的代理方法");
}
//缓存中的代理方法
-(void)playerViewBuffering:(VedioPlayerView *)player {
    NSLog(@"缓存中的代理方法");
}
//播放完毕的代理方法
-(void)playerViewFinished:(VedioPlayerView *)player {
    NSLog(@"播放完毕的代理方法");
}


@end
