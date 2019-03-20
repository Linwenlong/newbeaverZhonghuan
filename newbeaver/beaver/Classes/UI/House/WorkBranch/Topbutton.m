//
//  Topbutton.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "Topbutton.h"

#define image_w 12/1.5
#define image_h 14/1.5
#define spacing 10

@implementation Topbutton


- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(self.width-image_w-5, self.centerY+6, image_w, image_h);//图片的位置大小
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    //    self.height self.width
    return CGRectMake(15, 0, self.width-image_w-10-10-10, self.height);//文本的位置大小
}

@end
