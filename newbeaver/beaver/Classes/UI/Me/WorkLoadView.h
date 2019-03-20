//
//  WorkLoadView.h
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorkLoadViewDelegate <NSObject>

- (void)WorkLoadViewClick:(UIButton*)button andAnthorButtons:(NSArray<UIButton *>*)buttonArray andSilderView:(UIView *)view;

@end

@interface WorkLoadView : UIView

@property (nonatomic, weak) UIView *sliderView;
@property (nonatomic, strong)NSMutableArray  *buttonArray;
@property (nonatomic, weak) id<WorkLoadViewDelegate> titleViewDelegate;

@end
