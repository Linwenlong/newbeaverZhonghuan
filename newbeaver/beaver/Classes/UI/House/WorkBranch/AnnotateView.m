//
//  AnnotateView.m
//  beaver
//
//  Created by mac on 18/1/29.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "AnnotateView.h"

@interface AnnotateView ()



@end

@implementation AnnotateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    _title = [UILabel new];
    _title.textColor = LWL_DarkGrayrColor;
    _title.font = [UIFont systemFontOfSize:14.0f];
    _title.textAlignment = NSTextAlignmentLeft;
    
    _mainTextView = [UITextView new];
    
//    _mainTextView.userInteractionEnabled = NO;
    [_mainTextView setEditable:NO];
    [_mainTextView setScrollEnabled:YES];
    _mainTextView.font = [UIFont systemFontOfSize:14.0f];
    _mainTextView.backgroundColor = UIColorFromRGB(0xEBEBEB);
    _mainTextView.layer.cornerRadius = 5.0f;
    _mainTextView.clipsToBounds = YES;
    [self sd_addSubviews:@[_title,_mainTextView]];
    
    _title.sd_layout
    .topSpaceToView(self,0)
    .leftSpaceToView(self,15)
    .rightSpaceToView(self,15)
    .heightIs(15);
    
    _mainTextView.sd_layout
    .topSpaceToView(_title,17)
    .leftSpaceToView(self,15)
    .rightSpaceToView(self,15)
    .heightIs(108);
}

@end
