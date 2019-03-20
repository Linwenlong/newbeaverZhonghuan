//
//  ZHDCDetailTableViewCell.m
//  beaver
//
//  Created by mac on 17/4/30.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCDetailTableViewCell.h"
#import "SDAutoLayout.h"
@interface ZHDCDetailTableViewCell ()

@property (nonatomic, strong)UILabel *leftTitle;
@property (nonatomic, strong)UILabel *leftContent;

@property (nonatomic, strong)UILabel *rightTitle;
@property (nonatomic, strong)UILabel *rightContent;

@end

@implementation ZHDCDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setModel:(ZHDCDetailTableViewModel *)model{
    _leftTitle.text = model.leftType;
    _rightTitle.text = model.rightType;
    if (self.tag == 3) {
        _leftContent.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",model.leftConTent]]];
        _rightContent.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",model.rightConTent]]];
    }else{
        _leftContent.text =model.leftConTent;
        _rightContent.text = model.rightConTent;
    }
}

//- (void)setDic:(NSDictionary *)dic{
//
//    _leftTitle.text = dic[@"leftType"];
//    _rightTitle.text = dic[@"rightType"];
//    if (self.tag == 3) {
//        _leftContent.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"leftContent"]]]];
//        _rightContent.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"rightContent"]]]];
//    }else{
//        _leftContent.text = dic[@"leftContent"];
//        _rightContent.text = dic[@"rightContent"];
//    }
//}

//获取高度
- (CGFloat)sizeToHeight:(UIFont *)font content:(NSString *)content{
    CGFloat  W =  (kScreenW-40)/2.0-10;
    CGSize size = CGSizeMake(W,80);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    return actualsize.height;
}


#pragma mark -- 时间戳转时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    CGFloat X = 20;
    CGFloat Y = 10;
    _leftTitle = [UILabel new];
    _leftTitle.textAlignment = NSTextAlignmentLeft;
    _leftTitle.font = TitleFont;
    _leftTitle.textColor = TitleColor;
    _leftContent = [UILabel new];
     _leftContent.textAlignment = NSTextAlignmentLeft;
    _leftContent.font = ContentFont;
    _leftContent.numberOfLines = 0;
    _leftContent.textColor = [UIColor blackColor];
  
    _rightTitle = [UILabel new];
    _rightTitle.textAlignment = NSTextAlignmentLeft;
    _rightTitle.text = @"单套售价";
    _rightTitle.font = TitleFont;
    _rightTitle.textColor = TitleColor;
    _rightContent = [UILabel new];
    _rightContent.textAlignment = NSTextAlignmentLeft;
    _rightContent.numberOfLines = 0;
    _rightContent.font = ContentFont;
    _rightContent.textColor = [UIColor blackColor];
 
    
    [self.contentView sd_addSubviews:@[_leftTitle,_leftContent,_rightTitle,_rightContent] ];
    
    _leftTitle.sd_layout
    .topSpaceToView(self.contentView,Y)
    .leftSpaceToView(self.contentView,X)
    .widthIs((kScreenW-40)/2.0-20)
    .heightIs(30);
 
    _leftContent.sd_layout
    .topSpaceToView(_leftTitle,0)
    .leftSpaceToView(self.contentView,X)
    .widthIs((kScreenW-40)/2.0-20)
    .autoHeightRatio(0);
    
    _rightTitle.sd_layout
    .topSpaceToView(self.contentView,Y)
    .rightSpaceToView(self.contentView,X)
    .widthIs((kScreenW-40)/2.0-10)
    .heightIs(30);

    _rightContent.sd_layout
    .topSpaceToView(_rightTitle,0)
    .rightSpaceToView(self.contentView,X)
    .widthIs((kScreenW-40)/2.0-10)
    .autoHeightRatio(0);
    
//    [self setupAutoHeightWithBottomView:_leftContent bottomMargin:Y];
    
    [self setupAutoHeightWithBottomViewsArray:@[_leftContent,_rightContent] bottomMargin:Y];
}

@end
