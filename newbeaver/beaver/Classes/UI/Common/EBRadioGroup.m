//
//  EBRadioGroup.m
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBRadioGroup.h"
#import "EBStyle.h"
#import "EBViewFactory.h"

@interface EBRadioGroup()
{
    NSInteger lines;
    CGFloat xOffset;
}
@end

@implementation EBRadioGroup

-(void)setRadios:(NSArray *)radios
{
    _radios = radios;
    for (UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }

    lines = 1;
    for (NSInteger i = 0; i < _radios.count; i++)
    {
        [self addRadioBtn:_radios[i][@"title"] tag:i+1];
    }
}


- (void)addRadioBtn:(NSString *)title tag:(NSInteger)tag
{
    CGFloat width = 50.0;
    CGFloat titleWidth = [EBViewFactory textSize:title font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    if (titleWidth > 50.0)
    {
        width = titleWidth + 22.0;
        
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, (lines - 1) * 36.0, width, 26.0)];
    if (xOffset + width > self.frame.origin.x + self.frame.size.width)
    {
        btn.frame = CGRectMake(0.0, lines * 36.0, width, 26.0);
        CGRect frame = self.frame;
        frame.size.height += 36.0;
        self.frame = frame;
        lines += 1;
    }
    xOffset = btn.frame.origin.x + btn.frame.size.width + 10;
    [btn setBackgroundImage:[[UIImage imageNamed:@"btn_radio"] stretchableImageWithLeftCapWidth:13.0 topCapHeight:0.0]
                   forState:UIControlStateSelected];
    [btn setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(radioChecked:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [btn setTitle:title forState:UIControlStateNormal];

    btn.tag = tag;
    if (tag == _selectedIndex + 1)
    {
        btn.selected = YES;
    }
    [self addSubview:btn];
}

- (void)radioChecked:(UIButton *)btn
{
   self.selectedIndex = btn.tag - 1;
   if (self.checkBlock)
   {
       _checkBlock(self.selectedIndex);
   }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    for (NSInteger i = 0; i < _radios.count; i++)
    {
        UIButton *btn = (UIButton *)[self viewWithTag:i+1];
        btn.selected = btn.tag == _selectedIndex + 1 ? YES : NO;
    }
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
