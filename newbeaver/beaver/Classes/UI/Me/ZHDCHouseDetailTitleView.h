//
//  ZHDCHouseDetailTitleView.h
//  CentralManagerAssistant
//
//  Created by mac on 17/1/11.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHDCHouseDetailTitleViewDelegate <NSObject>

- (void)zhdcHouseDetailTitleViewClick:(UIButton*)button andAnthorButtons:(NSArray<UIButton *>*)buttonArray andSilderView:(UIView *)view;

@end

@interface ZHDCHouseDetailTitleView : UIView

@property (nonatomic, weak) UIView *sliderView;
@property (nonatomic, strong)NSMutableArray  *buttonArray;
@property (nonatomic, weak) id<ZHDCHouseDetailTitleViewDelegate> titleViewDelegate;

@end
