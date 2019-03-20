//
//  ContractTableViewCell.m
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractTableViewCell.h"

@interface ContractTableViewCell ()

@property (nonatomic,strong)UILabel *AdultsType;//分成人类型
@property (nonatomic,strong)UILabel *AdultsContent;//分成人

@property (nonatomic,strong)UILabel *splitReasonsType;//分成缘由类型
@property (nonatomic,strong)UILabel *splitReasonsContent;//分成人

@property (nonatomic,strong)UILabel *divideType;//分成比例
@property (nonatomic,strong)UILabel *paidType;//实收业绩

@end

@implementation ContractTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _AdultsContent.text = [NSString stringWithFormat:@"%@-%@",dic[@"department_name"],dic[@"username"]];
    _splitReasonsContent.text = dic[@"commission_type"];
    
    
    NSString *divideStr = [NSString stringWithFormat:@"分成比例: %@%%",dic[@"proportion"]];
    NSLog(@"divideStr = %ld",divideStr.length);
    NSMutableAttributedString *attributeStr1 =[[NSMutableAttributedString alloc]initWithString:divideStr];
    [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 6)];
    [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0xff3800)} range:NSMakeRange(6, divideStr.length-6)];
    _divideType.attributedText = attributeStr1;
    
//    _divideType.text = [NSString stringWithFormat:@"分成比例:%@",dic[@"proportion"]];

    NSString *paidStr = [NSString stringWithFormat:@"实收业绩(元): %0.2f",[dic[@"paid_money"] floatValue]];
    NSLog(@"paidStr = %ld",paidStr.length);
    NSMutableAttributedString *attributeStr2 =[[NSMutableAttributedString alloc]initWithString:paidStr];
    [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 9)];
    [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0xff3800)} range:NSMakeRange(9, paidStr.length-9)];
    _paidType.attributedText = attributeStr2;
    
//    _paidType.text = [NSString stringWithFormat:@"实收业绩(元):%0.2f",[dic[@"paid_money"] floatValue]];
}

- (void)setUI{

    _AdultsType = [UILabel new];
    _AdultsType.text = @"分成人:";
    _AdultsType.textAlignment = NSTextAlignmentLeft;
    _AdultsType.font = [UIFont systemFontOfSize:13.0f];
    _AdultsType.textColor = UIColorFromRGB(0x404040);
    
    _AdultsContent = [UILabel new];
    _AdultsContent.textAlignment = NSTextAlignmentRight;
    _AdultsContent.font = [UIFont systemFontOfSize:13.0f];
    _AdultsContent.textColor = UIColorFromRGB(0x808080);
    
    _splitReasonsType = [UILabel new];
    _splitReasonsType.text = @"分成缘由:";
    _splitReasonsType.textAlignment = NSTextAlignmentLeft;
    _splitReasonsType.font = [UIFont systemFontOfSize:13.0f];
    _splitReasonsType.textColor = UIColorFromRGB(0x404040);
    
    _splitReasonsContent = [UILabel new];
    _splitReasonsContent.textAlignment = NSTextAlignmentRight;
    _splitReasonsContent.font = [UIFont systemFontOfSize:13.0f];
    _splitReasonsContent.textColor = UIColorFromRGB(0x808080);
    
    
    _divideType = [UILabel new];
    _divideType.textAlignment = NSTextAlignmentLeft;
    _divideType.font = [UIFont systemFontOfSize:13.0f];
    _divideType.textColor = UIColorFromRGB(0x404040);
    
    _paidType = [UILabel new];
    _paidType.textAlignment = NSTextAlignmentRight;
    _paidType.font = [UIFont systemFontOfSize:13.0f];
    _paidType.textColor = UIColorFromRGB(0x404040);

    
    
    [self.contentView sd_addSubviews:@[_AdultsType,_AdultsContent,_splitReasonsType,_splitReasonsContent,_divideType,_paidType]];
    
    CGFloat X = 15;
    CGFloat Y = X;
    CGFloat spcing = 8;
    CGFloat h = 20;
    CGFloat w = (kScreenW-2*X)/2.0f;
    _AdultsType.sd_layout
    .topSpaceToView(self.contentView,Y)
    .leftSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    _AdultsContent.sd_layout
    .topSpaceToView(self.contentView,Y)
    .rightSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    _splitReasonsType.sd_layout
    .topSpaceToView(_AdultsType,spcing)
    .leftSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    _splitReasonsContent.sd_layout
    .topSpaceToView(_AdultsContent,spcing)
    .rightSpaceToView(self.contentView,X)
    .widthIs(w)
    .autoHeightRatio(0);
    
    _divideType.sd_layout
    .topSpaceToView(_splitReasonsType,spcing)
    .leftSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    _paidType.sd_layout
    .topSpaceToView(_splitReasonsContent,spcing)
    .rightSpaceToView(self.contentView,X)
    .widthIs(w)
    .heightIs(h);
    
    [self setupAutoHeightWithBottomViewsArray:@[_paidType,_divideType] bottomMargin:Y];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
