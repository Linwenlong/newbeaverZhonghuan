//
//  NewHouseListTableViewCell.m
//  beaver
//
//  Created by mac on 17/4/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewHouseListTableViewCell.h"
#import "SDAutoLayout.h"
#import "NewHouseListModel.h"
#import "UIImageView+WebCache.h"

#define HONT_SMALL [UIFont systemFontOfSize:14]

#define HONT_BIG [UIFont systemFontOfSize:18]

@interface NewHouseListTableViewCell ()

@property (nonatomic, strong)UIImageView *house_image;//house_image
@property (nonatomic, strong)UILabel *house_name;//house_name
@property (nonatomic, strong)UILabel *house_area;//house_area
@property (nonatomic, strong)UILabel *house_unit;//house_unit
@property (nonatomic, strong)UILabel *house_commission;//house_commission 佣金
@property (nonatomic, strong)UILabel *house_Type;//house_Type
@property (nonatomic, strong)UILabel *house_address;//house_address

@end

@implementation NewHouseListTableViewCell

- (void)awakeFromNib {
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setModel:(NewHouseListModel *)model{
    CGFloat spcing = 5;
    [_house_image sd_setImageWithURL:[NSURL URLWithString:model.house_image] placeholderImage:[UIImage imageNamed:@"默认图"]];
    _house_name.text = model.house_name;
    _house_area.sd_resetLayout
    .topSpaceToView(_house_name,spcing)
    .leftSpaceToView(_house_image,10)
    .widthIs([self sizeToWith:HONT_SMALL content:model.house_area])
    .heightIs(20);
    _house_unit.sd_resetLayout
    .topSpaceToView(_house_name,spcing)
    .leftSpaceToView(_house_area,20)
    .widthIs([self sizeToWith:HONT_SMALL content:model.house_unit])
    .heightIs(20);
    _house_area.text = model.house_area;
    _house_unit.text = model.house_unit;
    
    _house_commission.sd_resetLayout
    .topSpaceToView(_house_area,spcing)
    .leftSpaceToView(_house_image,10)
    .widthIs([self sizeToWith:HONT_BIG content:model.house_commission])
    .heightIs(20);
    
    _house_Type.sd_resetLayout
    .topSpaceToView(_house_area,spcing)
    .leftSpaceToView(_house_commission,20)
    .widthIs([self sizeToWith:HONT_SMALL content:model.house_Type])
    .heightIs(20);
    
    _house_commission.text = model.house_commission;
    _house_Type.text = model.house_Type;
    
    _house_address.sd_resetLayout
    .topSpaceToView(_house_commission,spcing)
    .leftSpaceToView(_house_image,10)
    .rightSpaceToView(self,10)
    .heightIs([self sizeToHeight:HONT_SMALL content:model.house_address]);
    _house_address.text = model.house_address;
//     _house_address.text = text ;
    
}

- (void)setUI{

    _house_image = [UIImageView new];
    _house_image.clipsToBounds = YES;
    _house_image.layer.cornerRadius = 3.0F;
 
    
    _house_name = [UILabel new];
    _house_name.font = HONT_BIG;
    _house_name.textColor = UIColorFromRGB(0x5d5d5d);


    _house_area = [UILabel new];
    _house_area.textColor = UIColorFromRGB(0xf6821f);
    _house_area.font = HONT_SMALL;
    
    _house_unit = [UILabel new];
    _house_unit.textColor = UIColorFromRGB(0xf6821f);;
    _house_unit.font = HONT_SMALL;
    
    _house_commission = [UILabel new];
    _house_commission.textColor = UIColorFromRGB(0xda251c);;
    _house_commission.font = HONT_BIG;
    
    _house_Type = [UILabel new];
    _house_Type.textColor = UIColorFromRGB(0x188fd0);
    _house_Type.textAlignment = NSTextAlignmentLeft;
    _house_Type.font = HONT_SMALL;
    
    _house_address = [UILabel new];
    _house_address.numberOfLines = 0;
    _house_address.font = HONT_SMALL;
    _house_address.textColor = UIColorFromRGB(0x5d5d5d);
    _house_address.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:_house_image];
    [self addSubview:_house_name];
    [self addSubview:_house_area];
    [self addSubview:_house_unit];
    [self addSubview:_house_commission];
    [self addSubview:_house_Type];
    [self addSubview:_house_address];

    [self layoutFrame];
}

- (void)layoutFrame{
    CGFloat spcing =  5;
    CGFloat X = 20;
    CGFloat image_h = 100;
    CGFloat image_w = image_h*200/150;
    _house_image.sd_layout
    .topSpaceToView(self,X)
    .leftSpaceToView(self,10)
    .widthIs(image_w)
    .heightIs(image_h);
    
    _house_name.sd_layout
    .topSpaceToView(self,X)
    .leftSpaceToView(_house_image,10)
    .rightSpaceToView(self,0)
    .heightIs(20);
   
    _house_area.sd_layout
    .topSpaceToView(_house_name,spcing)
    .leftSpaceToView(_house_image,10)
    .widthIs(70)
    .heightIs(20);

    _house_unit.sd_layout
    .topSpaceToView(_house_name,spcing)
    .leftSpaceToView(_house_area,20)
    .widthIs(80)
    .heightIs(20);
    
    _house_commission.sd_layout
    .topSpaceToView(_house_area,spcing)
    .leftSpaceToView(_house_image,10)
    .widthIs(80)
    .heightIs(20);
    
    _house_Type.sd_layout
    .topSpaceToView(_house_area,spcing)
    .leftSpaceToView(_house_commission,20)
    .widthIs(30)
    .heightIs(20);
    
    _house_address.sd_layout
    .topSpaceToView(_house_commission,spcing)
    .leftSpaceToView(_house_image,10)
    .rightSpaceToView(self,10)
    .heightIs(40);
    
}

- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}

- (CGFloat)sizeToHeight:(UIFont *)font content:(NSString *)content{
    CGFloat image_h = 100;
    CGFloat image_w = image_h*200/150;
    CGSize size = CGSizeMake(kScreenW-30-image_w,40);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    return actualsize.height;
}

@end
