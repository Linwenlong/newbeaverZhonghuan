//
//  MyReconoitreTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyReconoitreTableViewCell.h"

@interface MyReconoitreTableViewCell ()


@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UILabel *rightDate;
@property (weak, nonatomic) IBOutlet UILabel *rightCommuity;
@property (weak, nonatomic) IBOutlet UILabel *rightAdress;

@property (weak, nonatomic) IBOutlet UILabel *leftDate;
@property (weak, nonatomic) IBOutlet UILabel *leftCommuity;
@property (weak, nonatomic) IBOutlet UILabel *leftAddress;



@end

@implementation MyReconoitreTableViewCell



- (void)awakeFromNib {
    _rightDate.textColor = UIColorFromRGB(0x808080);
    _leftDate.textColor = UIColorFromRGB(0x808080);
    _leftAddress.textColor = UIColorFromRGB(0x808080);
    _rightAdress.textColor = UIColorFromRGB(0x808080);
    
    _leftCommuity.textColor = UIColorFromRGB(0x404040);
    _rightCommuity.textColor = UIColorFromRGB(0x404040);
    
    _line1.backgroundColor = UIColorFromRGB(0xff3800);
}

#pragma mark -- 时间戳转时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

- (void)setModel:(NSInteger)num withDarrCount:(NSInteger)count withDic:(NSDictionary *)model{
    if (num % 2 == 0) {
        _rightAdress.hidden = YES;
        _rightCommuity.hidden = YES;
        _rightDate.hidden = YES;
        _leftAddress.hidden = NO;
        _leftCommuity.hidden = NO;
        _leftDate.hidden = NO;
        _leftDate.text = [self timeWithTimeIntervalString:model[@"create_time"]];
        _leftCommuity.text = model[@"house_code"];
        _leftAddress.text = model[@"community"];
    }else{
        _rightAdress.hidden = NO;
        _rightCommuity.hidden = NO;
        _rightDate.hidden = NO;
        _leftAddress.hidden = YES;
        _leftCommuity.hidden = YES;
        _leftDate.hidden = YES;
        _rightAdress.text =  model[@"community"];
        _rightCommuity.text = model[@"house_code"];
        _rightDate.text = [self timeWithTimeIntervalString:model[@"create_time"]];
    }
//    if (count>1) {
        if (num == count - 1) {
            _line1.hidden = YES;
        }else{
            _line1.hidden = NO;
        }
//    }else{
//         _line1.hidden = YES;
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
