//
//  MortgageTableViewCell.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MortgageTableViewCell.h"

@interface MortgageTableViewCell ()

@property (nonatomic, strong)UILabel * dept_name;//分成部门
@property (nonatomic, strong)UILabel * proportionType;//分成比例
@property (nonatomic, strong)UILabel * proportionPrice;//分成金额

@property (nonatomic, strong)UILabel * first_dept_name; //第一个部门名字
@property (nonatomic, strong)UILabel * first_proportionType; //第一个分成比例
@property (nonatomic, strong)UILabel * first_proportionPrice; //第一个分成金额

@property (nonatomic, strong)UILabel * second_dept_name; //第二个部门名字
@property (nonatomic, strong)UILabel * second_proportionType; //第二个分成比例
@property (nonatomic, strong)UILabel * second_proportionPrice; //第二个分成金额

@property (nonatomic, strong)UILabel * totle_dept_name; //总合名字
@property (nonatomic, strong)UILabel * totle_proportionType; //总合分成比例
@property (nonatomic, strong)UILabel * totle_proportionPrice; //总合分成金额

@property (nonatomic, strong)UIButton * modif; //修改
@property (nonatomic, strong)UIButton * confir; //确认

@end

@implementation MortgageTableViewCell

-(void)setDic:(NSDictionary *)dic{
    NSArray *mort = dic[@"mort"];
    if ([mort isKindOfClass:[NSArray class]]) {
        NSDictionary *firstDic = mort.firstObject;
        
        _first_dept_name.text = firstDic[@"username"];
        _first_proportionType.text = [NSString stringWithFormat:@"%@%@",firstDic[@"proportion"],@"%"];
        _first_proportionPrice.text = firstDic[@"price_num"];
        
        NSDictionary *secondDic = mort.lastObject;
        
        _second_dept_name.text = secondDic[@"username"];
        _second_proportionType.text = [NSString stringWithFormat:@"%@%@",secondDic[@"proportion"],@"%"];
        _second_proportionPrice.text = secondDic[@"price_num"];
        
        _totle_proportionType.text = [NSString stringWithFormat:@"%d%@",[firstDic[@"proportion"] intValue]+[secondDic[@"proportion"] intValue],@"%"];
        _totle_proportionPrice.text = dic[@"the_sum_agency"];
    }
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}


- (void)setUI{
    
    
    
    _dept_name = [UILabel new];
    _dept_name.textAlignment = NSTextAlignmentCenter;
    _dept_name.text = @"分成部门";
    _dept_name.textColor = UIColorFromRGB(0x000000);
    _dept_name.font = [UIFont systemFontOfSize:14.0f];
    

    _proportionType = [UILabel new];
    _proportionType.textAlignment = NSTextAlignmentCenter;
    _proportionType.text = @"分成比例";
    _proportionType.textColor = UIColorFromRGB(0x000000);
    _proportionType.font = [UIFont systemFontOfSize:14.0f];
    
    _proportionPrice = [UILabel new];
    _proportionPrice.textAlignment = NSTextAlignmentCenter;
    _proportionPrice.text = @"分成金额";
    _proportionPrice.textColor = UIColorFromRGB(0x000000);
    _proportionPrice.font = [UIFont systemFontOfSize:14.0f];
    
    
    _first_dept_name = [UILabel new];
    _first_dept_name.textAlignment = NSTextAlignmentCenter;
    _first_dept_name.text = @"签约门店";
    _first_dept_name.textColor = UIColorFromRGB(0x474747);
    _first_dept_name.font = [UIFont systemFontOfSize:13.0f];
    
    _first_proportionType = [UILabel new];
    _first_proportionType.textAlignment = NSTextAlignmentCenter;
    _first_proportionType.text = @"8%";
    _first_proportionType.textColor = UIColorFromRGB(0x474747);
    _first_proportionType.font = [UIFont systemFontOfSize:13.0f];
    
    _first_proportionPrice = [UILabel new];
    _first_proportionPrice.textAlignment = NSTextAlignmentCenter;
    _first_proportionPrice.text = @"800";
    _first_proportionPrice.textColor = UIColorFromRGB(0x474747);
    _first_proportionPrice.font = [UIFont systemFontOfSize:13.0f];
    
    _second_dept_name = [UILabel new];
    _second_dept_name.textAlignment = NSTextAlignmentCenter;
    _second_dept_name.text = @"公司";
    _second_dept_name.textColor = UIColorFromRGB(0x474747);
    _second_dept_name.font = [UIFont systemFontOfSize:13.0f];
    
    _second_proportionType = [UILabel new];
    _second_proportionType.textAlignment = NSTextAlignmentCenter;
    _second_proportionType.text = @"92%";
    _second_proportionType.textColor = UIColorFromRGB(0x474747);
    _second_proportionType.font = [UIFont systemFontOfSize:13.0f];
    
    _second_proportionPrice = [UILabel new];
    _second_proportionPrice.textAlignment = NSTextAlignmentCenter;
    _second_proportionPrice.text = @"9200";
    _second_proportionPrice.textColor = UIColorFromRGB(0x474747);
    _second_proportionPrice.font = [UIFont systemFontOfSize:13.0f];
    
    _totle_dept_name = [UILabel new];
    _totle_dept_name.textAlignment = NSTextAlignmentCenter;
    _totle_dept_name.text = @"总合";
    _totle_dept_name.textColor = UIColorFromRGB(0x474747);
    _totle_dept_name.font = [UIFont systemFontOfSize:13.0f];
    
    _totle_proportionType = [UILabel new];
    _totle_proportionType.textAlignment = NSTextAlignmentCenter;
    _totle_proportionType.text = @"100%";
    _totle_proportionType.textColor = UIColorFromRGB(0x474747);
    _totle_proportionType.font = [UIFont systemFontOfSize:13.0f];
    
    _totle_proportionPrice = [UILabel new];
    _totle_proportionPrice.textAlignment = NSTextAlignmentCenter;
    _totle_proportionPrice.text = @"10000";
    _totle_proportionPrice.textColor = UIColorFromRGB(0x474747);
    _totle_proportionPrice.font = [UIFont systemFontOfSize:13.0f];
    
    _modif = [UIButton new];
    _modif.tag = 1;
    [_modif setTitle:@"修改" forState:UIControlStateNormal];
    [_modif setTitleColor:RGBA(71,71,71,1) forState:UIControlStateNormal];
    _modif.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _modif.layer.borderWidth = 1.0f;
    _modif.layer.borderColor = RGBA(71,71,71,1).CGColor;
    _modif.layer.cornerRadius = 5.0f;
    [_modif addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    
    _confir = [UIButton new];
    _confir.tag = 2;
    [_confir setTitle:@"待办费确认" forState:UIControlStateNormal];
    [_confir setTitleColor:RGBA(254,58,3,1) forState:UIControlStateNormal];
    _confir.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _confir.layer.borderWidth = 1.0f;
    _confir.layer.borderColor = RGBA(254,58,3,1).CGColor;
    _confir.layer.cornerRadius = 5.0f;
    [_confir addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView sd_addSubviews:@[_dept_name,_proportionType,_proportionPrice,_first_dept_name,_first_proportionType,_first_proportionPrice,_second_dept_name,_second_proportionType,_second_proportionPrice,_totle_dept_name,_totle_proportionType,_totle_proportionPrice,_modif,_confir]];
    
    [self addLayoutSubviews];
    
}

- (void)confirm:(UIButton *)btn{
    self.confrim(btn.tag);
}

- (void)addLayoutSubviews{
    
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat h = 15;
    
    _dept_name.sd_layout
    .topSpaceToView(self.contentView,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
   
    _proportionType.sd_layout
    .topSpaceToView(self.contentView,top)
    .centerXEqualToView(self.contentView)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _proportionPrice.sd_layout
    .topSpaceToView(self.contentView,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _first_dept_name.sd_layout
    .topSpaceToView(_dept_name,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _first_proportionType.sd_layout
    .topSpaceToView(_dept_name,top)
    .centerXEqualToView(self.contentView)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _first_proportionPrice.sd_layout
    .topSpaceToView(_dept_name,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    
    _second_dept_name.sd_layout
    .topSpaceToView(_first_dept_name,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _second_proportionType.sd_layout
    .topSpaceToView(_first_dept_name,top)
    .centerXEqualToView(self.contentView)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _second_proportionPrice.sd_layout
    .topSpaceToView(_first_dept_name,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _totle_dept_name.sd_layout
    .topSpaceToView(_second_dept_name,top)
    .leftSpaceToView(self.contentView,left)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _totle_proportionType.sd_layout
    .topSpaceToView(_second_dept_name,top)
    .centerXEqualToView(self.contentView)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _totle_proportionPrice.sd_layout
    .topSpaceToView(_second_dept_name,top)
    .rightSpaceToView(self.contentView,right)
    .widthIs([self sizeToWith:[UIFont systemFontOfSize:16.0f] content:@"分成比例"])
    .heightIs(h);
    
    _confir.sd_layout
    .topSpaceToView(_totle_dept_name, 13)
    .rightSpaceToView(self.contentView, right)
    .widthIs(100)
    .heightIs(30);
    
    _modif.sd_layout
    .topSpaceToView(_totle_dept_name, 13)
    .rightSpaceToView(_confir, 15)
    .widthIs(70)
    .heightIs(30);

}


- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
