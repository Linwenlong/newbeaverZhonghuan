//
//  ZHDCHouseDetailTitleView.m
//  CentralManagerAssistant
//
//  Created by mac on 17/1/11.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//

#import "ZHDCHouseDetailTitleView.h"

#define Btn_H 40

@interface ZHDCHouseDetailTitleView ()

@property (nonatomic, weak) UIButton *currentButton;


@end

@implementation ZHDCHouseDetailTitleView

- (NSMutableArray *)buttonArray{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *array = [NSArray arrayWithObjects:@"个人",@"全店",nil];
        CGFloat view_W = 140;
        CGFloat btnW = view_W/2.0f;
        for (int i = 0; i < array.count; i++) {
            UIButton *button = [[UIButton alloc]init];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.tag = i;
            [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            if (i == 0) {
                _currentButton = button;
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            [self addSubview:button];
            [self.buttonArray addObject:button];
            button.sd_layout
            .topEqualToView(0)
            .leftSpaceToView(self,i*btnW)
            .widthIs(btnW)
            .heightIs(Btn_H);
        }
        UIView *view = [[UIView alloc]init];
        view.backgroundColor =  [UIColor whiteColor] ;
        self.sliderView = view;
        [self addSubview:view];
        view.sd_layout
        .topSpaceToView(self,CGRectGetMaxY(_currentButton.frame)-1)
        .centerXEqualToView(_currentButton)
        .widthIs(45)
        .heightIs(3);
    }
    return self;
}

- (void)click:(UIButton *)button{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i = 0; i < self.buttonArray.count; i++) {
        if (i != button.tag) {
            [tmpArray addObject:self.buttonArray[i]];
        }
    }
    if (self.titleViewDelegate && [self.titleViewDelegate respondsToSelector:@selector(zhdcHouseDetailTitleViewClick: andAnthorButtons: andSilderView:)]) {
        [self.titleViewDelegate zhdcHouseDetailTitleViewClick:button andAnthorButtons:tmpArray andSilderView:self.sliderView];
    }
}

@end
