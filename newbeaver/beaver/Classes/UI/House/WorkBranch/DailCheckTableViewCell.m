//
//  DailCheckTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "DailCheckTableViewCell.h"

@interface DailCheckTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *deptmentName;
@property (weak, nonatomic) IBOutlet UILabel *submitDate;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

@implementation DailCheckTableViewCell

- (void)setModel:(DailyCheckModel *)model{
   
    if ([model.status isEqualToString:@"未上报"]) {
        _backImageView.image = [UIImage imageNamed:@"Didnotreport"];
    }else if ([model.status isEqualToString:@"已上报"]){
         _backImageView.image = [UIImage imageNamed:@"Hasbeenreported"];
    }else if ([model.status isEqualToString:@"已批示"]){
        _backImageView.image = [UIImage imageNamed:@"Hasbeenforbidden"];
    }else if([model.status isEqualToString:@"已点评"]){
        _backImageView.image = [UIImage imageNamed:@"Havecomments"];
    }
    
    NSString *str = nil;
    if ([model.comment isEqualToString:@""] ||[model.comment isEqual:[NSNull null]]) {
        str =[NSString stringWithFormat:@"心得：%@",@"暂无心得"];
    }else{
        str =[NSString stringWithFormat:@"心得：%@",model.comment];
    }

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0x404040)
                    range:NSMakeRange(0, 3)];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0x808080)
                    range:NSMakeRange(3, [str length]-3)];
    _content.attributedText = attrStr;
    _deptmentName.text = model.department_name;
    _submitDate.text = model.update_time;
    _name.text = model.username;
}

- (void)awakeFromNib {
    _lineView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    _name.textColor = UIColorFromRGB(0x404040);
    _deptmentName.textColor = UIColorFromRGB(0x808080);
    _submitDate.textColor = UIColorFromRGB(0x808080);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
