//
//  SearchView.m
//  beaver
//
//  Created by mac on 17/5/2.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SearchView.h"

@interface SearchView ()

@property (nonatomic, strong)NSArray *lables;
@property (nonatomic, strong)UIColor *color;
@property (nonatomic, strong)NSString *title;

@property (nonatomic, weak) UIView* currentLable;

@end

@implementation SearchView

-(instancetype)initWithFrame:(CGRect)frame arrayLables:(NSMutableArray *)lables lableBackGroundColor:(UIColor *)color withTitle:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        _lables =(NSArray *)lables;
        _color = color;
        _title = title;
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    CGFloat X = 20;
    CGFloat title_Y = 20;
    CGFloat lable_spcing = 10;
    CGFloat H = 25;
    //标题
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(X, title_Y, [self sizeToWith:[UIFont systemFontOfSize:15.0f] content:_title], H)];
    lable.font = [UIFont systemFontOfSize:15.0f] ;
    lable.textAlignment = NSTextAlignmentLeft;
    lable.text = _title;
    [self addSubview:lable];
    _currentLable = lable;
    for (int i = 0; i<_lables.count; i++) {
      
        UIButton *button = [[UIButton alloc]init];
        // x y
        button.tag = i;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:_lables[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];

        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.layer.cornerRadius = 12.0f;
        button.clipsToBounds = YES;
        button.backgroundColor = UIColorFromRGB(0xF5F5F5);
        CGFloat current_W =[self sizeToWith:[UIFont systemFontOfSize:14.0f] content:_lables[i]];
        if (CGRectGetMaxX(_currentLable.frame)+X+lable_spcing+ current_W>= kScreenW || i ==0) {
            //下一行
            button.frame = CGRectMake(X, CGRectGetMaxY(_currentLable.frame)+lable_spcing, [self sizeToWith:[UIFont systemFontOfSize:14.0f] content:_lables[i]], H);
        }else{
            button.frame = CGRectMake(CGRectGetMaxX(_currentLable.frame)+lable_spcing, _currentLable.top, [self sizeToWith:[UIFont systemFontOfSize:14.0f] content:_lables[i]], H);
        }
        [self addSubview:button];
        //在lable上添加手势
        _currentLable = button;
    }
}

- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width+30;
}

#pragma mark -- Method
- (void)btnClick:(UIButton *)btn{
    if (_searchViewDelegate && [_searchViewDelegate respondsToSelector:@selector(didSelected:)]) {
        [_searchViewDelegate didSelected:btn];
    }
}

@end
