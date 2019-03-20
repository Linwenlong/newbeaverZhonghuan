//
//  PublicNoticeTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "PublicNoticeTableViewCell.h"

@interface PublicNoticeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detailContent;
@property (weak, nonatomic) IBOutlet UILabel *pulishDate;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@end

@implementation PublicNoticeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _title.textColor = UIColorFromRGB(0x5d5d5d);
    _detailContent.textColor = UIColorFromRGB(0xa4a4a4);
    _pulishDate.textColor = UIColorFromRGB(0xa4a4a4);
}

- (void)setModel:(PublicNoticeModel *)model{
    _title.text = model.type;
    _detailContent.text  = model.title;
    _pulishDate.text = model.create_time;
}

- (void)setIConImage:(UIImage *)image{
    _iconImage.image = image;
}

@end
