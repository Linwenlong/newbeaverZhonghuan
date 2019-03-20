//
//  FilterCommonCollectionViewCell.m
//  ZYSideSlipFilter
//
//  Created by lzy on 16/10/15.
//  Copyright © 2016年 zhiyi. All rights reserved.
//

#import "FilterCommonCollectionViewCell.h"
#import "CommonItemModel.h"
#import "UIColor+hexColor.h"
#import "ZYSideSlipFilterConfig.h"

@interface FilterCommonCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (copy, nonatomic) NSString *itemId;
@end

@implementation FilterCommonCollectionViewCell
+ (NSString *)cellReuseIdentifier {
    return @"FilterCommonCollectionViewCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _nameButton.titleLabel.numberOfLines = 0;
    _nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.layer.cornerRadius = 6.0f;
    self.clipsToBounds = YES;
    return [[NSBundle mainBundle] loadNibNamed:@"FilterCommonCollectionViewCell" owner:nil options:nil][0];
}

- (void)updateCellWithModel:(CommonItemModel *)model {
    [_nameButton setTitle:model.itemName forState:UIControlStateNormal];
    self.itemId = model.itemId;
    [self tap2SelectItem:model.selected];
}

- (void)tap2SelectItem:(BOOL)selected {
    if (selected) {
        [self setBackgroundColor:UIColorFromRGB(0xFFEDE8)];
        [_nameButton setTitleColor:UIColorFromRGB(0xFE3800) forState:UIControlStateNormal];
    } else {
        [self setBackgroundColor:UIColorFromRGB(0xEEEEEE)];
        [_nameButton setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
