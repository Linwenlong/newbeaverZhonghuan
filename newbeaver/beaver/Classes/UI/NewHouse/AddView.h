//
//  AddView.h
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddView : UIView

//弹出动画
- (void)popView:(UIView *)containView;
//关闭动画
- (void)close:(UIView *)containView;

@end
