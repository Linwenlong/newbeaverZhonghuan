//
//  LWLShowView.h
//  beaver
//
//  Created by 林文龙 on 2017/7/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"


@protocol LWLShowViewDelegate <NSObject>

- (void)LWLShowViewBtnClick:(UIButton *)btn;

@end

@interface LWLShowView : UIView

@property (nonatomic, strong) UICountingLabel * lable1;
@property (nonatomic, strong) UICountingLabel * lable2;
@property (nonatomic, strong) UICountingLabel * lable3;

@property (nonatomic, weak)id<LWLShowViewDelegate> lwlShowViewDelegate;

@end
