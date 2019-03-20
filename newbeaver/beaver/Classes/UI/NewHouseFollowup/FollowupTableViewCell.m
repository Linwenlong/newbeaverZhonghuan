//
//  FollowupTableViewCell.m
//  beaver
//
//  Created by mac on 17/6/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FollowupTableViewCell.h"
#import "SDAutoLayout.h"
//#import <AVFoundation/AVFoundation.h>


@interface FollowupTableViewCell ()

@property (nonatomic, strong)UILabel *custom_view;//客户
@property (nonatomic, strong)UILabel *house_title_view;//房源标题
@property (nonatomic, strong)UILabel *create_time_view;//创建时间
@property (nonatomic, strong)UILabel *status_view;//状态
@property (nonatomic, strong)UILabel *custom_remarks_view;//报备备注
@property (nonatomic, strong)UIButton *updataPhoto;//上传图片

@property (nonatomic,strong) NSString *document_id;//客户id

@property (nonatomic, strong)NSString *house_id;//新房

@end

@implementation FollowupTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addUI];
    }
    return self;
}

- (void)addUI{
    _custom_view = [UILabel new];
    _custom_view.textAlignment = NSTextAlignmentLeft;
    _custom_view.textColor = UIColorFromRGB(0x00618D);
    _custom_view.font = [UIFont boldSystemFontOfSize:17.f];
    _house_title_view = [UILabel new];
    _house_title_view.font = [UIFont systemFontOfSize:15.0f];
    _house_title_view.textAlignment = NSTextAlignmentLeft;
    _house_title_view.textColor  = UIColorFromRGB(0x747476);
    
    _create_time_view = [UILabel new];
  
    _create_time_view.font = [UIFont systemFontOfSize:15.0f];
    _create_time_view.textAlignment = NSTextAlignmentLeft;
    _create_time_view.textColor  = UIColorFromRGB(0x747476);
    
    _status_view = [UILabel new];

    _status_view.font = [UIFont systemFontOfSize:15.0f];
    _status_view.textAlignment = NSTextAlignmentLeft;
    _status_view.textColor  = UIColorFromRGB(0x747476);
    
    _custom_remarks_view = [UILabel new];
  
    _custom_remarks_view.font = [UIFont systemFontOfSize:15.0f];
    _custom_remarks_view.textAlignment = NSTextAlignmentLeft;
    _custom_remarks_view.textColor  = UIColorFromRGB(0x747476);
    
    _updataPhoto = [UIButton new];
    _updataPhoto.backgroundColor=  [UIColor orangeColor];
    [_updataPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _updataPhoto.tag = self.tag;
    [_updataPhoto addTarget:self action:@selector(updataphotos:) forControlEvents:UIControlEventTouchUpInside];
    [_updataPhoto setTitle:@"上传图片" forState:UIControlStateNormal];
    _updataPhoto.layer.cornerRadius = 5.0f;
    _updataPhoto.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [self.contentView sd_addSubviews:@[_custom_view,_house_title_view,_create_time_view,_status_view,_custom_remarks_view,_updataPhoto]];
    
    CGFloat mid_margin = 5;
    CGFloat top_margin = 20;
    CGFloat lable_H = 30;
    CGFloat maxW = 200;
    if (kScreenW == 320) {
      maxW = 150;
      _custom_view.font = [UIFont boldSystemFontOfSize:14.f];
    }
   
    //设置约束
    _custom_view.sd_layout
    .leftSpaceToView(self.contentView,top_margin)
    .topSpaceToView(self.contentView,top_margin)
    .heightIs(lable_H);
    //宽度自适应
    [_custom_view setSingleLineAutoResizeWithMaxWidth:maxW];
    
    _house_title_view.sd_layout
    .leftEqualToView(_custom_view)
    .topSpaceToView(_custom_view,mid_margin)
    .heightIs(lable_H);
    [_house_title_view setSingleLineAutoResizeWithMaxWidth:maxW];
    
    _create_time_view.sd_layout
    .leftEqualToView(_custom_view)
    .topSpaceToView(_house_title_view,mid_margin)
    .heightIs(lable_H);
    
     [_create_time_view setSingleLineAutoResizeWithMaxWidth:maxW];
    
    _status_view.sd_layout
    .leftEqualToView(_custom_view)
    .topSpaceToView(_create_time_view,mid_margin)
    .heightIs(lable_H);
     [_status_view setSingleLineAutoResizeWithMaxWidth:maxW];
    
    _custom_remarks_view.sd_layout
    .leftEqualToView(_custom_view)
    .topSpaceToView(_status_view,mid_margin)
    .rightSpaceToView(self.contentView,top_margin)
    .autoHeightRatio(0);
    
    _updataPhoto.sd_layout
    .topSpaceToView(self.contentView,top_margin)
    .rightSpaceToView(self.contentView,top_margin);
    [_updataPhoto setupAutoSizeWithHorizontalPadding:20 buttonHeight:35];
    
    [self setupAutoHeightWithBottomView:_custom_remarks_view bottomMargin:top_margin];
}

-(void)setModel:(FolowupModel *)model{
    _custom_view.text = model.custom_detail;
    _house_title_view.text = model.house_title;
    _create_time_view.text= model.create_time;
    _status_view.text = model.status;
    _custom_remarks_view.text = model.custom_remarks;
    _document_id = model.document_id;
    _house_id = model.house_id;
}

- (void)awakeFromNib {
   
}

- (void)updataphotos:(UIButton *)btn{

    self.btnBack(_custom_view.text,_house_title_view.text,_document_id,_house_id);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}




@end
