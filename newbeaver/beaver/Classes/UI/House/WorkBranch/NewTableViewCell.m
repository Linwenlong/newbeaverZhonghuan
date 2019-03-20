//
//  NewTableViewCell.m
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewTableViewCell.h"

@interface NewTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UILabel *detailText;

@end

@implementation NewTableViewCell

- (void)setModel:(NewsModel *)model{
    _text.text = model.type;
    _detailText.text = model.title;
}

- (void)awakeFromNib {
    _text.textColor = UIColorFromRGB(0x5d5d5d);
    _detailText.textColor = UIColorFromRGB(0xa4a4a4);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (void)setIConImage:(UIImage *)image{
    _imageIcon.image = image;
}

@end
