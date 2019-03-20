//
//  FinanceTableViewCell1.m
//  beaver
//
//  Created by mac on 17/11/13.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinanceTableViewCell1.h"

@interface FinanceTableViewCell1 ()
@property (weak, nonatomic) IBOutlet UILabel *deptType;

@property (weak, nonatomic) IBOutlet UILabel *deptContent;

@property (weak, nonatomic) IBOutlet UILabel *CommissionType;
@property (weak, nonatomic) IBOutlet UILabel *CommissionDate;
@property (weak, nonatomic) IBOutlet UILabel *checkType;
@property (weak, nonatomic) IBOutlet UILabel *checkContent;
@property (weak, nonatomic) IBOutlet UILabel *confireType;
@property (weak, nonatomic) IBOutlet UILabel *confireContent;
@property (weak, nonatomic) IBOutlet UIView *line1;

@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *price_count;
@end

@implementation FinanceTableViewCell1


- (void)setDic:(NSDictionary *)dic isTranManager:(BOOL)tranManager{
    _deptContent.text = dic[@"dept_name"];
    
    if (tranManager == NO) {
        _CommissionDate.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"commission_date"]]];
    }else{
        _CommissionType.text = @"申请日期";
        _CommissionDate.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"create_time"]]];
    }
    
    _checkContent.text = [NSString stringWithFormat:@"%@-%@",dic[@"verify_dept"],dic[@"verify_username"]];
    if ([dic[@"check_dept"] isEqualToString:@""]) {
        _confireContent.text = @"暂无";
    }else{
        _confireContent.text = [NSString stringWithFormat:@"%@-%@",dic[@"check_dept"],dic[@"check_username"]];
    }
    
    _price_count.text = [NSString stringWithFormat:@"¥%0.2f",[dic[@"price"] floatValue]];
}

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
    _deptType.textColor = UIColorFromRGB(0x404040);
    _CommissionType.textColor = UIColorFromRGB(0x404040);
    _checkType.textColor = UIColorFromRGB(0x404040);
    _confireType.textColor = UIColorFromRGB(0x404040);
    
    _deptContent.textColor = UIColorFromRGB(0x808080);
    _CommissionDate.textColor = UIColorFromRGB(0x808080);
    _checkContent.textColor = UIColorFromRGB(0x808080);
    _confireContent.textColor = UIColorFromRGB(0x808080);
    
    _price.textColor = UIColorFromRGB(0x404040);
    _price.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _price_count.textColor = UIColorFromRGB(0xfe3800);
    _price_count.font = [UIFont boldSystemFontOfSize:13.0f];
    _line1.backgroundColor =  [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
