//
//  FinancialTableViewCell.m
//  beaver
//
//  Created by mac on 17/11/26.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialTableViewCell.h"

@interface FinancialTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *house_address;
@property (weak, nonatomic) IBOutlet UILabel *contract_code;
@property (weak, nonatomic) IBOutlet UILabel *complete_date;
@property (weak, nonatomic) IBOutlet UILabel *owner_name;
@property (weak, nonatomic) IBOutlet UILabel *client_name;

@end

@implementation FinancialTableViewCell

- (void)setDic:(NSDictionary *)dic{
    _house_address.text = dic[@"house_address"];
    _contract_code.text = dic[@"contract_code"];
    _complete_date.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"complete_date"]]];//时间错
    _owner_name.text = dic[@"owner_name"];
    _client_name.text = dic[@"client_name"];
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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
