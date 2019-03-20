//
//  LWLScrollView.m
//  beaver
//
//  Created by 林文龙 on 2018/11/14.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "LWLScrollView.h"

@implementation LWLScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (gestureRecognizer.state != 0) {
        return YES;
    }else{
        return NO;
    }
}

@end
