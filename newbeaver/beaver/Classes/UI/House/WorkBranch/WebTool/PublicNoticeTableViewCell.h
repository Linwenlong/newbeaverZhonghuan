//
//  PublicNoticeTableViewCell.h
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PublicNoticeModel.h"

@interface PublicNoticeTableViewCell : UITableViewCell

- (void)setIConImage:(UIImage *)image;

- (void)setModel:(PublicNoticeModel *)model;

@end
