//
//  DefaultView.m
//  PlaceHolderView
//
//  Created by yh on 17/5/16.
//  Copyright © 2017年 yh. All rights reserved.
//

#import "DefaultView.h"

@implementation DefaultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _placeView = imageView;
        imageView.image = [UIImage imageNamed:@"无详情"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.center = CGPointMake(self.center.x, self.center.y+10);
        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        _placeText = label;
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂无详情内容";
        label.center = CGPointMake(self.center.x, CGRectGetMaxY(imageView.frame)+30);
        [self addSubview:label];
    }
    return self;
}

@end
