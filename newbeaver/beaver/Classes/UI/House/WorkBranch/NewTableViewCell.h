//
//  NewTableViewCell.h
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface NewTableViewCell : UITableViewCell

- (void)setIConImage:(UIImage *)image;

- (void)setModel:(NewsModel *)model;

@end
