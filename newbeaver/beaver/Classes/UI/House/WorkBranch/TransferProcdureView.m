//
//  TransferProcdureView.m
//  beaver
//
//  Created by mac on 17/12/27.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "TransferProcdureView.h"

@interface TransferProcdureView ()


@end


@implementation TransferProcdureView

- (void)didClickNode:(UITapGestureRecognizer *)tap{
    NSLog(@"点击");
    NSLog(@"self.procdureViewDelegate=%@",self.procdureViewDelegate);
    NSLog(@"self.procdureViewDelegate=%d",[self.procdureViewDelegate respondsToSelector:@selector(ClickTransferProcdure:)]);
    if (self.procdureViewDelegate && [self.procdureViewDelegate respondsToSelector:@selector(ClickTransferProcdure:)]) {
        [self.procdureViewDelegate ClickTransferProcdure:tap.view.tag];
    }
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI];
        
//        // 添加节点手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickNode:)];
//        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)setUI{
    _midLineLeft = [UIView new];
    _midLineLeft.backgroundColor = LWL_BlueColor;
    
    _smallIcon = [UIImageView new];
    _smallIcon.image = [UIImage imageNamed:@"transfergreen"];
    
    _midLineRight = [UIView new];
    _midLineRight.backgroundColor = LWL_BlueColor;
    
    
    _contentLbl = [UILabel new];
    _contentLbl.text = @"乙方解压还贷";
    _contentLbl.textAlignment = NSTextAlignmentCenter;
    _contentLbl.numberOfLines = 0;
    _contentLbl.textColor = LWL_BlueColor;
    _contentLbl.font = [UIFont systemFontOfSize:13.0f];
    
    [self sd_addSubviews:@[_midLineLeft,_smallIcon,_midLineRight,_contentLbl]];

    [self addLayoutSubviews];
}

- (void)addLayoutSubviews{
    
    CGFloat lineW = (self.width-14)/2.0f;
    
    _midLineLeft.sd_layout
    .leftEqualToView(self)
    .topSpaceToView(self,33)
    .widthIs(lineW)
    .heightIs(2);
    
    _midLineRight.sd_layout
    .rightEqualToView(self)
    .topSpaceToView(self,33)
    .widthIs(lineW)
    .heightIs(2);
    
    _smallIcon.sd_layout
    .topSpaceToView(self,27)
    .centerXEqualToView(self)
    .widthIs(14)
    .heightIs(14);
    
    _contentLbl.sd_layout
    .leftSpaceToView(self,12)
    .rightSpaceToView(self,12)
    .topSpaceToView(_smallIcon,10)
    .heightIs(32);
}



@end
