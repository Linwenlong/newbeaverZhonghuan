//
//  PerformanceTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PerformanceTableViewCell.h"
#import "PerformanceRankingModel.h"

@interface PerformanceTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *firstStar;
@property (weak, nonatomic) IBOutlet UILabel *Ranking;//排名
@property (weak, nonatomic) IBOutlet UIImageView *header;//头像
@property (weak, nonatomic) IBOutlet UILabel *name;//姓名
@property (weak, nonatomic) IBOutlet UILabel *store;//门店
@property (weak, nonatomic) IBOutlet UILabel *number;//名次



@end

@implementation PerformanceTableViewCell

- (void)setHidden:(BOOL)hidden model:(PerformanceRankingModel *)model num:(NSInteger)num{
    //头像问题
//    _header.image
    _name.text = model.deal_username;
    _store.text = [NSString stringWithFormat:@"%@-%@",model.deal_district,model.deal_department_name];
    _number.text = model.deal_count;
    if ( hidden == YES ) {
        _Ranking.hidden = YES;
        _firstStar.hidden = NO;
        _name.textColor = UIColorFromRGB(0xff3800);
    }else{
        _firstStar.hidden = YES;
        _name.textColor = [UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1.0f ];
        _Ranking.hidden = NO;
        _Ranking.text = [NSString stringWithFormat:@"%ld",num];
    }
}

- (void)awakeFromNib {
  
    UIColor *grayColor1 =[UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1.0f ];
    UIColor *greenColor1=[UIColor colorWithRed:96/255.0f green:190/255.0f blue:224/255.0f alpha:1.0f ];
    
    _Ranking.textColor = grayColor1;


    _name.textColor = grayColor1;
    

    _store.textColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.00];
    _number.textColor = greenColor1;
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
