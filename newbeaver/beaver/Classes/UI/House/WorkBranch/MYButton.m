//
//  MYButton.m
//  beaver
//
//  Created by mac on 17/7/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MYButton.h"
#import "SDAutoLayout.h"

@implementation MYButton

- (void)layoutSubviews{
    // 设置button的图片的约束
    self.imageView.sd_layout
    .widthRatioToView(self, 0.8)
    .topSpaceToView(self, 10)
    .centerXEqualToView(self)
    .heightRatioToView(self, 0.6);
    
    // 设置button的label的约束
    self.titleLabel.sd_layout
    .topSpaceToView(self.imageView, 10)
    .leftEqualToView(self.imageView)
    .rightEqualToView(self.imageView)
    .bottomSpaceToView(self, 10);
}

@end
