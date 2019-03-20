//
//  MySeeTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySeeTableViewCell.h"
#import "ZFChart.h"

#define Colors  @[[UIColor colorWithRed:1.00 green:0.38 blue:0.21 alpha:1.00],[UIColor colorWithRed:0.91 green:0.69 blue:0.22 alpha:1.00],[UIColor colorWithRed:0.54 green:0.62 blue:1.00 alpha:1.00]]

@interface MySeeTableViewCell ()<ZFGenericChartDataSource, ZFBarChartDelegate>

@property (nonatomic, strong) ZFBarChart * barChart;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSArray *countArr;

@property (weak, nonatomic) IBOutlet UILabel *typeName;
@property (weak, nonatomic) IBOutlet UIView *lineBack;
@property (weak, nonatomic) IBOutlet UILabel *myNum;
@property (weak, nonatomic) IBOutlet UILabel *myNumCount;
@property (weak, nonatomic) IBOutlet UIView *BarChartView;

@property (nonatomic, assign)CGFloat maxFloat;//最大的
@property (weak, nonatomic) IBOutlet UIImageView *jiantou;

@end


@implementation MySeeTableViewCell

- (void)awakeFromNib {
    
    _typeName.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.00];
    _myNum.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.00];
    _lineBack.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.00];
    _myNumCount.textColor = [UIColor colorWithRed:1.00 green:0.32 blue:0.23 alpha:1.00];
    _BarChartView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    
    self.barChart = [[ZFBarChart alloc] initWithFrame:self.BarChartView.bounds];
    self.barChart.width = kScreenW-38;
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
    self.barChart.unit = @"次数";
    self.barChart.isResetAxisLineMaxValue = YES;
    [self.BarChartView addSubview:self.barChart];

}

- (void)setModel:(NSDictionary *)dic withType:(NSString *)str{
    
    _typeName.text = str;
    if ([str isEqualToString:@"带看房"]) {
        _myNumCount.text = [NSString stringWithFormat:@"%@",dic[@"house_sort"]];
        
        NSString *house_num = @"";
        if ([dic[@"house_num"] isEqualToString:@""]) {
            house_num = @"0";
        }else{
            house_num = dic[@"house_num"];
        }
        
        _countArr = @[[NSString stringWithFormat:@"%@",house_num],[NSString stringWithFormat:@"%@",dic[@"average"]],[NSString stringWithFormat:@"%@",dic[@"max"]]];
    }else if([str isEqualToString:@"带看客"]){
        _myNumCount.text = [NSString stringWithFormat:@"%@",dic[@"client_sort"]];
        
        NSString *client_num = @"";
        if ([dic[@"client_num"] isEqualToString:@""]) {
            client_num = @"0";
        }else{
            client_num = dic[@"client_num"];
        }
        
        _countArr = @[[NSString stringWithFormat:@"%@",client_num],[NSString stringWithFormat:@"%@",dic[@"average"]],[NSString stringWithFormat:@"%@",dic[@"max"]]];
    }else{
        _jiantou.hidden = YES;
        _myNumCount.text = [NSString stringWithFormat:@"%@",dic[@"suvey_sort"]];
        _countArr = @[[NSString stringWithFormat:@"%@",dic[@"surveynum"]],[NSString stringWithFormat:@"%@",dic[@"average"]],[NSString stringWithFormat:@"%@",dic[@"max"]]];

    }
    _maxFloat = [dic[@"max"]floatValue];
    if (_maxFloat == 0) {
        _maxFloat = 1;
    }
    [self.barChart strokePath];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
}

#define Bar_W 30

#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return _countArr;
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return @[@"我的带看", @"平均值", @"最大值"];
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return Colors;
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return _maxFloat;
}


#pragma mark - ZFBarChartDelegate

- (CGFloat)barWidthInBarChart:(ZFBarChart *)barChart{
    return Bar_W;
}

- (CGFloat)paddingForGroupsInBarChart:(ZFBarChart *)barChart{

    return 44;
}

- (id)valueTextColorArrayInBarChart:(ZFGenericChart *)barChart{
    return UIColorFromRGB(0xff3800);
}


- (void)barChart:(ZFBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex bar:(ZFBar *)bar popoverLabel:(ZFPopoverLabel *)popoverLabel{
    bar.barColor = Colors[barIndex];
    bar.isAnimated = YES;
    
    [bar strokePath];
}

- (void)barChart:(ZFBarChart *)barChart didSelectPopoverLabelAtGroupIndex:(NSInteger)groupIndex labelIndex:(NSInteger)labelIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)labelIndex);
}



@end
