//
//  AddView.m
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "AddView.h"


@implementation AddView

//弹出动画
- (void)popView:(UIView *)containView{
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = 1;
    }];
    containView.layer.shouldRasterize = YES;
    containView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
    [UIView animateWithDuration:0.2 animations:^{
        containView.alpha = 1;
        containView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            containView.alpha = 1;
            containView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                containView.alpha = 1;
                containView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            } completion:^(BOOL finished2) {
                containView.layer.shouldRasterize = NO;
            }];
        }];
    }];

}

- (void)close:(UIView *)containView{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }];
    containView.layer.shouldRasterize = YES;
    [UIView animateWithDuration:0.2 animations:^{
        containView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containView.alpha = 0;
            containView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
        } completion:^(BOOL finished2){
            [self removeFromSuperview];
        }];
    }];
}

@end
