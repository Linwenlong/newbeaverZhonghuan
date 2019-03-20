//
//  WorkLoadView.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "WorkLoadView.h"

#define Btn_H 40

@interface WorkLoadView ()

@property (nonatomic, weak) UIButton *currentButton;


@end

@implementation WorkLoadView

- (NSMutableArray *)buttonArray{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *array = [NSArray arrayWithObjects:@"房源",@"客源",@"成交" ,nil];
        CGFloat btnW = 55;
        
     
        for (int i = 0; i < 3; i++) {
            UIButton *button = [[UIButton alloc]init];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.tag = i;
            [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
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
        view.backgroundColor =   [UIColor whiteColor] ;
        self.sliderView = view;
        [self addSubview:view];
        view.sd_layout
        .topSpaceToView(self,CGRectGetMaxY(_currentButton.frame) - 1)
        .centerXEqualToView(_currentButton)
        .widthIs(40)
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
    if (self.titleViewDelegate && [self.titleViewDelegate respondsToSelector:@selector(WorkLoadViewClick:andAnthorButtons:andSilderView:)]) {
        [self.titleViewDelegate WorkLoadViewClick:button andAnthorButtons:tmpArray andSilderView:self.sliderView];
    }
}


@end
