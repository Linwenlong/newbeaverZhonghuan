//
//  EBMoreBoardView.m
//  AppKeFuIMSDK
//
//  Created by jack on 13-10-19.
//  Copyright (c) 2013年 appkefu.com. All rights reserved.
//

#import "EBMoreBoardView.h"
#import "UIImage+Alpha.h"
#import "EBStyle.h"

@implementation EBMoreBoardView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        //[self setBackgroundColor:[UIColor grayColor]];
        [self setBackgroundColor:[UIColor clearColor]];

        CGFloat itemWidth = 80;
        CGFloat labelHeight = 12;
        CGFloat gap = 0.5;
        NSInteger num_row = 4;
        for (NSInteger i = 0; i < 4; i++)
        {
            NSInteger row = i / num_row;
            NSInteger col = i % num_row;

            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(col * itemWidth,
                    gap * (row + 1) + (itemWidth + labelHeight) * row, itemWidth, itemWidth)];
            btn.tag = i + 1;

            NSString *key = [NSString stringWithFormat:@"im_more_%ld", i];

            UIImage *image = [UIImage imageNamed:key];
            [btn setImage:image forState:UIControlStateNormal];
            [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(col * itemWidth,
                    (itemWidth + gap) * (row + 1) + labelHeight * row, itemWidth, labelHeight)];
            label.textColor = [EBStyle blackTextColor];
            label.font = [UIFont systemFontOfSize:12.0];
            label.text = NSLocalizedString(key, nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            [self addSubview:label];
        }
        
        //top line
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        lineView.backgroundColor = [UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:1.0];
        [self addSubview:lineView];

    }
    return self;
}

- (void)buttonPressed:(UIButton *)btn
{
   [self.delgate moreBoardView:self itemClicked:btn.tag - 1];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
